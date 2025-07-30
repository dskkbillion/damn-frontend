import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 核心依赖
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/database/app_database.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/services/file_upload_service.dart';

// 数据源
import '../data/datasources/i_order_remote_data_source.dart';
import '../data/datasources/order_remote_data_source_impl.dart';
import '../data/datasources/i_order_local_data_source.dart';
import '../data/datasources/order_local_data_source_impl.dart';
import '../data/datasources/i_order_materials_remote_data_source.dart';
import '../data/datasources/order_materials_remote_data_source_impl.dart';

// 仓库
import '../domain/repositories/i_order_repository.dart';
import '../data/repositories/order_repository_impl.dart';

// 用例 - 买家订单
import '../domain/usecases/create_order_use_case.dart';
import '../domain/usecases/get_order_list_use_case.dart';
import '../domain/usecases/get_order_detail_use_case.dart';
import '../domain/usecases/cancel_order_use_case.dart';
import '../domain/usecases/confirm_order_receipt_use_case.dart';
import '../domain/usecases/delete_order_use_case.dart';
import '../domain/usecases/submit_requirements_use_case.dart';
import '../domain/usecases/submit_evaluation_use_case.dart';
import '../domain/usecases/reject_order_use_case.dart';
import '../domain/usecases/invite_evaluation_use_case.dart';
import '../domain/usecases/deliver_order_use_case.dart';
import '../domain/usecases/delete_seller_record_use_case.dart';
import '../domain/usecases/confirm_order_acceptance_use_case.dart';
import '../domain/usecases/get_order_materials_use_case.dart';

// 用例 - 卖家订单 (从seller目录导入，使用别名避免冲突)
import '../domain/usecases/seller/seller_order_actions_use_cases.dart' as seller_actions;

// BLoC
import '../presentation/bloc/order_list_bloc.dart';
import '../presentation/bloc/order_detail_bloc.dart';
import '../presentation/seller/bloc/seller_order_list_bloc.dart';
import '../presentation/seller/bloc/seller_order_detail_bloc.dart';

/// 订单模块依赖注入
class OrdersDI {
  /// 初始化订单模块的所有依赖
  static Future<void> init(GetIt sl) async {
    print('[OrdersDI] ========== 开始初始化订单模块依赖 ==========');

    try {
      // 数据源
      _registerDataSources(sl);
      
      // 仓库
      _registerRepositories(sl);
      
      // 用例
      _registerUseCases(sl);
      
      // BLoC
      _registerBlocs(sl);

      print('[OrdersDI] ========== 订单模块依赖初始化完成 ==========');
    } catch (e) {
      print('[OrdersDI] 初始化订单模块依赖时出错: $e');
      rethrow;
    }
  }

  /// 注册数据源
  static void _registerDataSources(GetIt sl) {
    // 远程数据源
    if (!sl.isRegistered<IOrderRemoteDataSource>()) {
      sl.registerLazySingleton<IOrderRemoteDataSource>(
        () => OrderRemoteDataSourceImpl(
          coreDioClient: sl<CoreDioClient>(),
          secureStorage: sl<FlutterSecureStorage>(),
        )
      );
      print('[OrdersDI] 已注册 IOrderRemoteDataSource');
    } else {
      print('[OrdersDI] IOrderRemoteDataSource 已存在，跳过注册');
    }

    // 本地数据源
    if (!sl.isRegistered<IOrderLocalDataSource>()) {
      sl.registerLazySingleton<IOrderLocalDataSource>(
        () => OrderLocalDataSourceImpl(appDatabase: sl<AppDatabase>())
      );
      print('[OrdersDI] 已注册 IOrderLocalDataSource');
    } else {
      print('[OrdersDI] IOrderLocalDataSource 已存在，跳过注册');
    }

    // 材料数据源
    if (!sl.isRegistered<IOrderMaterialsRemoteDataSource>()) {
      sl.registerLazySingleton<IOrderMaterialsRemoteDataSource>(
        () => OrderMaterialsRemoteDataSourceImpl(sl<Dio>())
      );
      print('[OrdersDI] 已注册 IOrderMaterialsRemoteDataSource');
    } else {
      print('[OrdersDI] IOrderMaterialsRemoteDataSource 已存在，跳过注册');
    }
  }

  /// 注册仓库
  static void _registerRepositories(GetIt sl) {
    if (!sl.isRegistered<IOrderRepository>()) {
      sl.registerLazySingleton<IOrderRepository>(
        () => OrderRepositoryImpl(
          remoteDataSource: sl<IOrderRemoteDataSource>(),
          localDataSource: sl<IOrderLocalDataSource>(),
          materialsDataSource: sl<IOrderMaterialsRemoteDataSource>(),
          networkInfo: sl<NetworkInfo>(),
          fileUploadService: sl<IFileUploadService>(),
        )
      );
      print('[OrdersDI] 已注册 IOrderRepository');
    } else {
      print('[OrdersDI] IOrderRepository 已存在，跳过注册');
    }
  }

  /// 注册用例
  static void _registerUseCases(GetIt sl) {
    // 买家订单用例
    if (!sl.isRegistered<CreateOrderUseCase>()) {
      sl.registerLazySingleton<CreateOrderUseCase>(
        () => CreateOrderUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 CreateOrderUseCase');
    }

    if (!sl.isRegistered<GetOrderListUseCase>()) {
      sl.registerLazySingleton<GetOrderListUseCase>(
        () => GetOrderListUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 GetOrderListUseCase');
    }

    if (!sl.isRegistered<GetOrderDetailUseCase>()) {
      sl.registerLazySingleton<GetOrderDetailUseCase>(
        () => GetOrderDetailUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 GetOrderDetailUseCase');
    }

    if (!sl.isRegistered<CancelOrderUseCase>()) {
      sl.registerLazySingleton<CancelOrderUseCase>(
        () => CancelOrderUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 CancelOrderUseCase');
    }

    if (!sl.isRegistered<ConfirmOrderReceiptUseCase>()) {
      sl.registerLazySingleton<ConfirmOrderReceiptUseCase>(
        () => ConfirmOrderReceiptUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 ConfirmOrderReceiptUseCase');
    }

    if (!sl.isRegistered<DeleteOrderUseCase>()) {
      sl.registerLazySingleton<DeleteOrderUseCase>(
        () => DeleteOrderUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 DeleteOrderUseCase');
    }

    if (!sl.isRegistered<SubmitRequirementsUseCase>()) {
      sl.registerLazySingleton<SubmitRequirementsUseCase>(
        () => SubmitRequirementsUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 SubmitRequirementsUseCase');
    }

    if (!sl.isRegistered<SubmitEvaluationUseCase>()) {
      sl.registerLazySingleton<SubmitEvaluationUseCase>(
        () => SubmitEvaluationUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 SubmitEvaluationUseCase');
    }

    if (!sl.isRegistered<GetOrderMaterialsUseCase>()) {
      sl.registerLazySingleton<GetOrderMaterialsUseCase>(
        () => GetOrderMaterialsUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 GetOrderMaterialsUseCase');
    }

    if (!sl.isRegistered<RejectOrderUseCase>()) {
      sl.registerLazySingleton<RejectOrderUseCase>(
        () => RejectOrderUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 RejectOrderUseCase');
    }

    if (!sl.isRegistered<InviteEvaluationUseCase>()) {
      sl.registerLazySingleton<InviteEvaluationUseCase>(
        () => InviteEvaluationUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 InviteEvaluationUseCase');
    }

    // 卖家订单用例
    if (!sl.isRegistered<ConfirmOrderAcceptanceUseCase>()) {
      sl.registerLazySingleton<ConfirmOrderAcceptanceUseCase>(
        () => ConfirmOrderAcceptanceUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 ConfirmOrderAcceptanceUseCase');
    }

    if (!sl.isRegistered<DeliverOrderUseCase>()) {
      sl.registerLazySingleton<DeliverOrderUseCase>(
        () => DeliverOrderUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 DeliverOrderUseCase');
    }

    if (!sl.isRegistered<DeleteSellerRecordUseCase>()) {
      sl.registerLazySingleton<DeleteSellerRecordUseCase>(
        () => DeleteSellerRecordUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 DeleteSellerRecordUseCase');
    }

    // 卖家订单附加用例 (使用别名)
    if (!sl.isRegistered<seller_actions.AddOrderDemandUseCase>()) {
      sl.registerLazySingleton<seller_actions.AddOrderDemandUseCase>(
        () => seller_actions.AddOrderDemandUseCase(sl<IOrderRepository>())
      );
      print('[OrdersDI] 已注册 AddOrderDemandUseCase');
    }
  }

  /// 注册BLoC
  static void _registerBlocs(GetIt sl) {
    // 买家订单BLoC
    if (!sl.isRegistered<OrderListBloc>()) {
      sl.registerFactory<OrderListBloc>(
        () => OrderListBloc(
          getOrderListUseCase: sl<GetOrderListUseCase>(),
        )
      );
      print('[OrdersDI] 已注册 OrderListBloc');
    } else {
      print('[OrdersDI] OrderListBloc 已存在，跳过注册');
    }

    if (!sl.isRegistered<OrderDetailBloc>()) {
      sl.registerFactory<OrderDetailBloc>(
        () => OrderDetailBloc(
          getOrderDetailUseCase: sl<GetOrderDetailUseCase>(),
          cancelOrderUseCase: sl<CancelOrderUseCase>(),
          confirmOrderReceiptUseCase: sl<ConfirmOrderReceiptUseCase>(),
          deleteOrderUseCase: sl<DeleteOrderUseCase>(),
          paymentService: sl<IPaymentService>(),
          submitEvaluationUseCase: sl<SubmitEvaluationUseCase>(),
          submitRequirementsUseCase: sl<SubmitRequirementsUseCase>(),
          getOrderMaterialsUseCase: sl<GetOrderMaterialsUseCase>(),
        )
      );
      print('[OrdersDI] 已注册 OrderDetailBloc');
    } else {
      print('[OrdersDI] OrderDetailBloc 已存在，跳过注册');
    }

    // 卖家订单BLoC
    if (!sl.isRegistered<SellerOrderListBloc>()) {
      sl.registerFactory<SellerOrderListBloc>(
        () => SellerOrderListBloc(
          sl<GetOrderListUseCase>(),
          sl<ConfirmOrderAcceptanceUseCase>(),
          sl<RejectOrderUseCase>(),
          sl<DeliverOrderUseCase>(),
          sl<InviteEvaluationUseCase>(),
          sl<DeleteSellerRecordUseCase>(),
        )
      );
      print('[OrdersDI] 已注册 SellerOrderListBloc');
    } else {
      print('[OrdersDI] SellerOrderListBloc 已存在，跳过注册');
    }

    if (!sl.isRegistered<SellerOrderDetailBloc>()) {
      sl.registerFactory<SellerOrderDetailBloc>(
        () => SellerOrderDetailBloc(
          sl<GetOrderDetailUseCase>(),
          sl<ConfirmOrderAcceptanceUseCase>(),
          sl<RejectOrderUseCase>(),
          sl<DeliverOrderUseCase>(),
          sl<DeleteSellerRecordUseCase>(),
        )
      );
      print('[OrdersDI] 已注册 SellerOrderDetailBloc');
    } else {
      print('[OrdersDI] SellerOrderDetailBloc 已存在，跳过注册');
    }
  }
} 