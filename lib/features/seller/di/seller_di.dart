import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

// 核心依赖
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/i_http_client.dart';

// 文件上传
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/repositories/file_upload_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/file_upload_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/i_file_upload_data_source.dart';

// 数据源
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_remote_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/i_seller_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_local_data_source_impl.dart';

// 仓库
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/data/repositories/seller_repository_impl.dart';

// 用例 - 商品管理
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_draft_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_status_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/delete_product_usecase.dart';

// 用例 - 卖家主页
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';

// 用例 - 产品编辑
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/create_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_detail_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/save_product_draft_usecase.dart';

// 用例 - 认证管理
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_authentication_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/submit_authentication_application_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_time_settings_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_time_settings_usecase.dart';

// 用例 - 自动回复
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_auto_reply_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/set_auto_reply_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_tenant_audit_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/audit_refund_usecase.dart';

// Bloc - 卖家主页和产品管理
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_management/auth_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_application/auth_application_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/time_management/time_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auto_reply/auto_reply_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';

// 统计模块依赖注入
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';

/// 文件上传模拟实现
class MockFileUploadRepository implements IFileUploadRepository {
  @override
  Future<Either<Failure, String>> uploadFile(File file) async {
    AppLogger.d('[MockFileUploadRepository] 模拟上传文件: ${file.path}');
    // 返回模拟的成功结果，使用本地文件路径作为"上传URL"
    // 在开发/测试环境中，我们假装文件已上传并返回路径
    return Right('https://mock-upload-server.com/images/${file.path.split('/').last}');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    AppLogger.d('[MockFileUploadRepository] 调用未实现的方法: ${invocation.memberName}');
    return super.noSuchMethod(invocation);
  }
}

/// 卖家模块依赖注入
class SellerDI {
  /// 初始化卖家模块的所有依赖
  static Future<void> init(GetIt sl) async {
    AppLogger.d('[SellerDI] ========== 开始初始化卖家模块依赖 ==========');
    AppLogger.d('[SellerDI] GetIt实例状态: ${sl.isRegistered<ISellerRepository>() ? "ISellerRepository已注册" : "ISellerRepository未注册"}');

    try {
      // 数据源
      if (!sl.isRegistered<ISellerRemoteDataSource>()) {
        // 检查Dio是否已注册
        if (!sl.isRegistered<Dio>()) {
          AppLogger.d('[SellerDI] 错误: Dio未注册，需要先注册Dio');
          throw Exception('Dio dependency not registered');
        }

        sl.registerLazySingleton<ISellerRemoteDataSource>(
          () => SellerRemoteDataSourceImpl(sl<Dio>())
        );
        AppLogger.d('[SellerDI] 已注册 ISellerRemoteDataSource');
      } else {
        AppLogger.d('[SellerDI] ISellerRemoteDataSource 已存在，跳过注册');
      }

      if (!sl.isRegistered<ISellerLocalDataSource>()) {
        // 检查SharedPreferences是否已注册
        if (!sl.isRegistered<SharedPreferences>()) {
          AppLogger.d('[SellerDI] 错误: SharedPreferences未注册，需要先注册SharedPreferences');
          throw Exception('SharedPreferences dependency not registered');
        }

        sl.registerLazySingleton<ISellerLocalDataSource>(
          () => SellerLocalDataSourceImpl(sl<SharedPreferences>())
        );
        AppLogger.d('[SellerDI] 已注册 ISellerLocalDataSource');
      } else {
        AppLogger.d('[SellerDI] ISellerLocalDataSource 已存在，跳过注册');
      }

      // 仓库
      if (!sl.isRegistered<ISellerRepository>()) {
        // 检查NetworkInfo是否已注册
        if (!sl.isRegistered<NetworkInfo>()) {
          AppLogger.d('[SellerDI] 错误: NetworkInfo未注册，需要先注册NetworkInfo');
          throw Exception('NetworkInfo dependency not registered');
        }

        sl.registerLazySingleton<ISellerRepository>(
          () => SellerRepositoryImpl(
            sl<ISellerRemoteDataSource>(),
            sl<ISellerLocalDataSource>(),
            sl<NetworkInfo>(),
          )
        );
        AppLogger.d('[SellerDI] 已注册 ISellerRepository');
      } else {
        AppLogger.d('[SellerDI] ISellerRepository 已存在，跳过注册');
      }

      // 用例 - 商品管理
      if (!sl.isRegistered<GetSellerProductListUseCase>()) {
        sl.registerLazySingleton<GetSellerProductListUseCase>(
          () => GetSellerProductListUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetSellerProductListUseCase');
      }

      if (!sl.isRegistered<GetSellerDraftListUseCase>()) {
        sl.registerLazySingleton<GetSellerDraftListUseCase>(
          () => GetSellerDraftListUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetSellerDraftListUseCase');
      }

      if (!sl.isRegistered<UpdateProductStatusUseCase>()) {
        sl.registerLazySingleton<UpdateProductStatusUseCase>(
          () => UpdateProductStatusUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 UpdateProductStatusUseCase');
      }

      if (!sl.isRegistered<DeleteProductUseCase>()) {
        sl.registerLazySingleton<DeleteProductUseCase>(
          () => DeleteProductUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 DeleteProductUseCase');
      }

      // 用例 - 卖家主页
      if (!sl.isRegistered<GetSellerDashboardDataUseCase>()) {
        sl.registerLazySingleton<GetSellerDashboardDataUseCase>(
          () => GetSellerDashboardDataUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetSellerDashboardDataUseCase');
      }

      if (!sl.isRegistered<GetStoreProfileUseCase>()) {
        sl.registerLazySingleton<GetStoreProfileUseCase>(
          () => GetStoreProfileUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetStoreProfileUseCase');
      }
      
      // 用例 - 认证管理
      if (!sl.isRegistered<GetAuthenticationStatus>()) {
        sl.registerLazySingleton<GetAuthenticationStatus>(
          () => GetAuthenticationStatus(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetAuthenticationStatus');
      }

      if (!sl.isRegistered<SubmitAuthenticationApplicationUseCase>()) {
        sl.registerLazySingleton<SubmitAuthenticationApplicationUseCase>(
          () => SubmitAuthenticationApplicationUseCase(
            sl<ISellerRepository>(),
            sl<IFileUploadRepository>(),
          )
        );
        AppLogger.d('[SellerDI] 已注册 SubmitAuthenticationApplicationUseCase');
      }

      // 用例 - 时间管理
      if (!sl.isRegistered<GetTimeSettingsUseCase>()) {
        sl.registerLazySingleton<GetTimeSettingsUseCase>(
          () => GetTimeSettingsUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetTimeSettingsUseCase');
      }

      if (!sl.isRegistered<UpdateTimeSettingsUseCase>()) {
        sl.registerLazySingleton<UpdateTimeSettingsUseCase>(
          () => UpdateTimeSettingsUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 UpdateTimeSettingsUseCase');
      }

      // 用例 - 自动回复
      if (!sl.isRegistered<GetAutoReplyUseCase>()) {
        sl.registerLazySingleton<GetAutoReplyUseCase>(
          () => GetAutoReplyUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetAutoReplyUseCase');
      }

      if (!sl.isRegistered<SetAutoReplyUseCase>()) {
        sl.registerLazySingleton<SetAutoReplyUseCase>(
          () => SetAutoReplyUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 SetAutoReplyUseCase');
      }

      // 用例 - 卖家售后审核
      if (!sl.isRegistered<GetTenantAuditListUseCase>()) {
        sl.registerLazySingleton<GetTenantAuditListUseCase>(
          () => GetTenantAuditListUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetTenantAuditListUseCase');
      }

      if (!sl.isRegistered<AuditRefundUseCase>()) {
        sl.registerLazySingleton<AuditRefundUseCase>(
          () => AuditRefundUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 AuditRefundUseCase');
      }

      // 注册文件上传仓库（如果尚未注册）
      if (!sl.isRegistered<IFileUploadRepository>()) {
        // 检查是否有必要的依赖项
        if (!sl.isRegistered<IHttpClient>()) {
          AppLogger.d('[SellerDI] 错误: IHttpClient未注册，需要先注册IHttpClient');
          throw Exception('IHttpClient dependency not registered');
        }
        
        // 注册文件上传数据源
        if (!sl.isRegistered<IFileUploadDataSource>()) {
          sl.registerLazySingleton<IFileUploadDataSource>(
            () => FileUploadDataSourceImpl(sl<IHttpClient>())
          );
          AppLogger.d('[SellerDI] 已注册 FileUploadDataSourceImpl');
        }
        
        // 注册文件上传仓库
        sl.registerLazySingleton<IFileUploadRepository>(
          () => FileUploadRepositoryImpl(dataSource: sl<IFileUploadDataSource>())
        );
        AppLogger.d('[SellerDI] 已注册 FileUploadRepositoryImpl');
      } else {
        AppLogger.d('[SellerDI] IFileUploadRepository 已存在，跳过注册');
      }

      // 用例 - 产品编辑
      if (!sl.isRegistered<CreateProductUseCase>()) {
        sl.registerLazySingleton<CreateProductUseCase>(
          () => CreateProductUseCase(sl<ISellerRepository>(), sl<IFileUploadRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 CreateProductUseCase');
      }

      if (!sl.isRegistered<UpdateProductUseCase>()) {
        sl.registerLazySingleton<UpdateProductUseCase>(
          () => UpdateProductUseCase(sl<ISellerRepository>(), sl<IFileUploadRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 UpdateProductUseCase');
      }

      if (!sl.isRegistered<GetSellerProductDetailUseCase>()) {
        sl.registerLazySingleton<GetSellerProductDetailUseCase>(
          () => GetSellerProductDetailUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 GetSellerProductDetailUseCase');
      }

      if (!sl.isRegistered<SaveProductDraftUseCase>()) {
        sl.registerLazySingleton<SaveProductDraftUseCase>(
          () => SaveProductDraftUseCase(sl<ISellerRepository>())
        );
        AppLogger.d('[SellerDI] 已注册 SaveProductDraftUseCase');
      }

      // 注册BLoC工厂
      _registerBlocs(sl);
      
      // 初始化卖家统计模块
      AppLogger.d('[SellerDI] 开始初始化卖家统计模块...');
      SellerStatisticsDI.init(sl);
      AppLogger.d('[SellerDI] 卖家统计模块初始化完成');

      AppLogger.d('[SellerDI] ========== 卖家模块依赖初始化完成 ==========');
    } catch (e) {
      AppLogger.d('[SellerDI] 初始化卖家模块依赖时出错: $e');
      rethrow; // 重新抛出异常，以便上层捕获
    }
  }

  /// 注册所有BLoC
  static void _registerBlocs(GetIt sl) {
    // BLoC - 卖家主页
    if (!sl.isRegistered<SellerHomeBloc>()) {
      sl.registerLazySingleton<SellerHomeBloc>(
        () => SellerHomeBloc(
          sl<GetSellerDashboardDataUseCase>(),
          sl<GetStoreProfileUseCase>(),
        )
      );
      AppLogger.d('[SellerDI] 已注册 SellerHomeBloc (LazySingleton)');
    } else {
      AppLogger.d('[SellerDI] SellerHomeBloc 已存在，跳过注册');
    }

    // BLoC - 商品管理
    if (!sl.isRegistered<ProductManagementBloc>()) {
      sl.registerFactory<ProductManagementBloc>(
        () => ProductManagementBloc(
          sl<GetSellerProductListUseCase>(),
          sl<GetSellerDraftListUseCase>(),
          sl<UpdateProductStatusUseCase>(),
          sl<DeleteProductUseCase>(),
        )
      );
      AppLogger.d('[SellerDI] 已注册 ProductManagementBloc');
    } else {
      AppLogger.d('[SellerDI] ProductManagementBloc 已存在，跳过注册');
    }

    // BLoC - 产品编辑
    if (!sl.isRegistered<ProductEditBloc>()) {
      sl.registerFactory<ProductEditBloc>(
        () => ProductEditBloc(
          sl<GetSellerProductDetailUseCase>(),
          sl<CreateProductUseCase>(),
          sl<UpdateProductUseCase>(),
          sl<SaveProductDraftUseCase>(),
          sl<IFileUploadRepository>(),
          sl<ISellerRepository>(),
        )
      );
      AppLogger.d('[SellerDI] 已注册 ProductEditBloc');
    } else {
      AppLogger.d('[SellerDI] ProductEditBloc 已存在，跳过注册');
    }
    
    // BLoC - 认证管理
    if (!sl.isRegistered<AuthManagementBloc>()) {
      sl.registerFactory<AuthManagementBloc>(
        () => AuthManagementBloc(sl<GetAuthenticationStatus>())
      );
      AppLogger.d('[SellerDI] 已注册 AuthManagementBloc');
    } else {
      AppLogger.d('[SellerDI] AuthManagementBloc 已存在，跳过注册');
    }

    // BLoC - 认证申请
    if (!sl.isRegistered<AuthApplicationBloc>()) {
      sl.registerFactory<AuthApplicationBloc>(
        () => AuthApplicationBloc(sl<SubmitAuthenticationApplicationUseCase>())
      );
      AppLogger.d('[SellerDI] 已注册 AuthApplicationBloc');
    } else {
      AppLogger.d('[SellerDI] AuthApplicationBloc 已存在，跳过注册');
    }

    // BLoC - 时间管理
    if (!sl.isRegistered<TimeManagementBloc>()) {
      sl.registerFactory<TimeManagementBloc>(
        () => TimeManagementBloc(
          sl<GetTimeSettingsUseCase>(),
          sl<UpdateTimeSettingsUseCase>(),
        )
      );
      AppLogger.d('[SellerDI] 已注册 TimeManagementBloc');
    } else {
      AppLogger.d('[SellerDI] TimeManagementBloc 已存在，跳过注册');
    }

    // BLoC - 自动回复
    if (!sl.isRegistered<AutoReplyBloc>()) {
      sl.registerFactory<AutoReplyBloc>(
        () => AutoReplyBloc(
          sl<GetAutoReplyUseCase>(),
          sl<SetAutoReplyUseCase>(),
        )
      );
      AppLogger.d('[SellerDI] 已注册 AutoReplyBloc');
    } else {
      AppLogger.d('[SellerDI] AutoReplyBloc 已存在，跳过注册');
    }

    // BLoC - 售后审核
    if (!sl.isRegistered<AfterSalesReviewBloc>()) {
      sl.registerFactory<AfterSalesReviewBloc>(
        () => AfterSalesReviewBloc(
          sl<GetTenantAuditListUseCase>(),
          sl<AuditRefundUseCase>(),
        ),
      );
      AppLogger.d('[SellerDI] 已注册 AfterSalesReviewBloc');
    } else {
      AppLogger.d('[SellerDI] AfterSalesReviewBloc 已存在，跳过注册');
    }
  }
}
