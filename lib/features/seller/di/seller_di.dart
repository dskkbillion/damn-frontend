import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 核心依赖
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';

// 文件上传
import 'package:dskk_flutter_refactor/features/ai_docs/domain/repositories/i_file_upload_repository.dart';

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

// Bloc - 卖家主页和产品管理
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_edit/product_edit_bloc.dart';

// 统计模块依赖注入
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';

/// 文件上传模拟实现
class MockFileUploadRepository implements IFileUploadRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    print('[MockFileUploadRepository] 调用未实现的方法: ${invocation.memberName}');
    return super.noSuchMethod(invocation);
  }
}

/// 卖家模块依赖注入
class SellerDI {
  /// 初始化卖家模块的所有依赖
  static Future<void> init(GetIt sl) async {
    print('[SellerDI] ========== 开始初始化卖家模块依赖 ==========');
    print('[SellerDI] GetIt实例状态: ${sl.isRegistered<ISellerRepository>() ? "ISellerRepository已注册" : "ISellerRepository未注册"}');

    try {
      // 数据源
      if (!sl.isRegistered<ISellerRemoteDataSource>()) {
        // 检查Dio是否已注册
        if (!sl.isRegistered<Dio>()) {
          print('[SellerDI] 错误: Dio未注册，需要先注册Dio');
          throw Exception('Dio dependency not registered');
        }

        sl.registerLazySingleton<ISellerRemoteDataSource>(
          () => SellerRemoteDataSourceImpl(sl<Dio>())
        );
        print('[SellerDI] 已注册 ISellerRemoteDataSource');
      } else {
        print('[SellerDI] ISellerRemoteDataSource 已存在，跳过注册');
      }

      if (!sl.isRegistered<ISellerLocalDataSource>()) {
        // 检查SharedPreferences是否已注册
        if (!sl.isRegistered<SharedPreferences>()) {
          print('[SellerDI] 错误: SharedPreferences未注册，需要先注册SharedPreferences');
          throw Exception('SharedPreferences dependency not registered');
        }

        sl.registerLazySingleton<ISellerLocalDataSource>(
          () => SellerLocalDataSourceImpl(sl<SharedPreferences>())
        );
        print('[SellerDI] 已注册 ISellerLocalDataSource');
      } else {
        print('[SellerDI] ISellerLocalDataSource 已存在，跳过注册');
      }

      // 仓库
      if (!sl.isRegistered<ISellerRepository>()) {
        // 检查NetworkInfo是否已注册
        if (!sl.isRegistered<NetworkInfo>()) {
          print('[SellerDI] 错误: NetworkInfo未注册，需要先注册NetworkInfo');
          throw Exception('NetworkInfo dependency not registered');
        }

        sl.registerLazySingleton<ISellerRepository>(
          () => SellerRepositoryImpl(
            sl<ISellerRemoteDataSource>(),
            sl<ISellerLocalDataSource>(),
            sl<NetworkInfo>(),
          )
        );
        print('[SellerDI] 已注册 ISellerRepository');
      } else {
        print('[SellerDI] ISellerRepository 已存在，跳过注册');
      }

      // 用例 - 商品管理
      if (!sl.isRegistered<GetSellerProductListUseCase>()) {
        sl.registerLazySingleton<GetSellerProductListUseCase>(
          () => GetSellerProductListUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 GetSellerProductListUseCase');
      }

      if (!sl.isRegistered<GetSellerDraftListUseCase>()) {
        sl.registerLazySingleton<GetSellerDraftListUseCase>(
          () => GetSellerDraftListUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 GetSellerDraftListUseCase');
      }

      if (!sl.isRegistered<UpdateProductStatusUseCase>()) {
        sl.registerLazySingleton<UpdateProductStatusUseCase>(
          () => UpdateProductStatusUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 UpdateProductStatusUseCase');
      }

      if (!sl.isRegistered<DeleteProductUseCase>()) {
        sl.registerLazySingleton<DeleteProductUseCase>(
          () => DeleteProductUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 DeleteProductUseCase');
      }

      // 用例 - 卖家主页
      if (!sl.isRegistered<GetSellerDashboardDataUseCase>()) {
        sl.registerLazySingleton<GetSellerDashboardDataUseCase>(
          () => GetSellerDashboardDataUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 GetSellerDashboardDataUseCase');
      }

      if (!sl.isRegistered<GetStoreProfileUseCase>()) {
        sl.registerLazySingleton<GetStoreProfileUseCase>(
          () => GetStoreProfileUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 GetStoreProfileUseCase');
      }

      // 注册文件上传仓库（如果尚未注册）
      if (!sl.isRegistered<IFileUploadRepository>()) {
        print('[SellerDI] 警告: IFileUploadRepository未注册，使用模拟实现');
        sl.registerLazySingleton<IFileUploadRepository>(() => MockFileUploadRepository());
        print('[SellerDI] 已注册临时的 MockFileUploadRepository');
      }

      // 用例 - 产品编辑
      if (!sl.isRegistered<CreateProductUseCase>()) {
        sl.registerLazySingleton<CreateProductUseCase>(
          () => CreateProductUseCase(sl<ISellerRepository>(), sl<IFileUploadRepository>())
        );
        print('[SellerDI] 已注册 CreateProductUseCase');
      }

      if (!sl.isRegistered<UpdateProductUseCase>()) {
        sl.registerLazySingleton<UpdateProductUseCase>(
          () => UpdateProductUseCase(sl<ISellerRepository>(), sl<IFileUploadRepository>())
        );
        print('[SellerDI] 已注册 UpdateProductUseCase');
      }

      if (!sl.isRegistered<GetSellerProductDetailUseCase>()) {
        sl.registerLazySingleton<GetSellerProductDetailUseCase>(
          () => GetSellerProductDetailUseCase(sl<ISellerRepository>())
        );
        print('[SellerDI] 已注册 GetSellerProductDetailUseCase');
      }

      // 注册BLoC工厂
      _registerBlocs(sl);
      
      // 初始化卖家统计模块
      print('[SellerDI] 开始初始化卖家统计模块...');
      SellerStatisticsDI.init(sl);
      print('[SellerDI] 卖家统计模块初始化完成');

      print('[SellerDI] ========== 卖家模块依赖初始化完成 ==========');
    } catch (e) {
      print('[SellerDI] 初始化卖家模块依赖时出错: $e');
      rethrow; // 重新抛出异常，以便上层捕获
    }
  }

  /// 注册所有BLoC
  static void _registerBlocs(GetIt sl) {
    // BLoC - 卖家主页
    if (!sl.isRegistered<SellerHomeBloc>()) {
      sl.registerFactory<SellerHomeBloc>(
        () => SellerHomeBloc(
          sl<GetSellerDashboardDataUseCase>(),
          sl<GetStoreProfileUseCase>(),
        )
      );
      print('[SellerDI] 已注册 SellerHomeBloc');
    } else {
      print('[SellerDI] SellerHomeBloc 已存在，跳过注册');
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
      print('[SellerDI] 已注册 ProductManagementBloc');
    } else {
      print('[SellerDI] ProductManagementBloc 已存在，跳过注册');
    }

    // BLoC - 产品编辑
    if (!sl.isRegistered<ProductEditBloc>()) {
      sl.registerFactory<ProductEditBloc>(
        () => ProductEditBloc(
          sl<GetSellerProductDetailUseCase>(),
          sl<CreateProductUseCase>(),
          sl<UpdateProductUseCase>(),
        )
      );
      print('[SellerDI] 已注册 ProductEditBloc');
    } else {
      print('[SellerDI] ProductEditBloc 已存在，跳过注册');
    }
  }
} 