// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:package_info_plus/package_info_plus.dart' as _i655;

import '../../core/database/app_database.dart' as _i50;
import '../../core/navigation/services/i_navigation_service.dart' as _i625;
import '../../core/network/core_dio_client.dart' as _i412;
import '../../core/network/interceptors/app_info_interceptor.dart' as _i405;
import '../../core/payment/services/i_payment_service.dart' as _i395;
import '../../features/after_sales/data/datasources/after_sales_remote_data_source.dart'
    as _i519;
import '../../features/after_sales/data/datasources/i_after_sales_remote_data_source.dart'
    as _i253;
import '../../features/after_sales/data/repositories/after_sales_repository_impl.dart'
    as _i363;
import '../../features/after_sales/domain/repositories/i_after_sales_repository.dart'
    as _i441;
import '../../features/after_sales/domain/usecases/apply_for_after_sales_use_case.dart'
    as _i970;
import '../../features/after_sales/domain/usecases/cancel_after_sales_use_case.dart'
    as _i773;
import '../../features/after_sales/domain/usecases/delete_after_sales_use_case.dart'
    as _i88;
import '../../features/after_sales/domain/usecases/get_after_sales_detail_use_case.dart'
    as _i1057;
import '../../features/after_sales/domain/usecases/get_after_sales_list_use_case.dart'
    as _i953;
import '../../features/after_sales/presentation/bloc/after_sales_bloc.dart'
    as _i59;
import '../../features/orders/data/datasources/i_order_local_data_source.dart'
    as _i406;
import '../../features/orders/data/datasources/i_order_remote_data_source.dart'
    as _i346;
import '../../features/orders/data/datasources/order_local_data_source_impl.dart'
    as _i1016;
import '../../features/orders/data/datasources/order_remote_data_source_impl.dart'
    as _i230;
import '../../features/orders/data/repositories/order_repository_impl.dart'
    as _i376;
import '../../features/orders/domain/repositories/i_order_repository.dart'
    as _i724;
import '../../features/orders/domain/usecases/cancel_order_use_case.dart'
    as _i1;
import '../../features/orders/domain/usecases/confirm_order_receipt_use_case.dart'
    as _i708;
import '../../features/orders/domain/usecases/delete_order_use_case.dart'
    as _i577;
import '../../features/orders/domain/usecases/get_order_detail_use_case.dart'
    as _i691;
import '../../features/orders/domain/usecases/get_order_list_use_case.dart'
    as _i1015;
import '../../features/orders/domain/usecases/seller/seller_order_actions_use_cases.dart'
    as _i618;
import '../../features/orders/domain/usecases/submit_evaluation_use_case.dart'
    as _i40;
import '../../features/orders/domain/usecases/submit_requirements_use_case.dart'
    as _i51;
import '../../features/orders/presentation/bloc/order_detail_bloc.dart'
    as _i549;
import '../../features/orders/presentation/bloc/order_list_bloc.dart' as _i176;
import 'injection_container.dart' as _i809;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i50.AppDatabase>(() => registerModule.appDatabase);
  gh.lazySingleton<_i625.INavigationService>(
      () => registerModule.navigationService);
  gh.lazySingleton<_i395.IPaymentService>(() => registerModule.paymentService);
  gh.lazySingleton<_i406.IOrderLocalDataSource>(() =>
      _i1016.OrderLocalDataSourceImpl(appDatabase: gh<_i50.AppDatabase>()));
  gh.factory<_i405.AppInfoInterceptor>(
      () => _i405.AppInfoInterceptor(gh<_i655.PackageInfo>()));
  gh.factory<_i412.CoreDioClient>(() => _i412.CoreDioClient(
        gh<String>(instanceName: 'baseUrl'),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i405.AppInfoInterceptor>(),
      ));
  gh.lazySingleton<_i346.IOrderRemoteDataSource>(() =>
      _i230.OrderRemoteDataSourceImpl(
          coreDioClient: gh<_i412.CoreDioClient>()));
  gh.lazySingleton<_i724.IOrderRepository>(() => _i376.OrderRepositoryImpl(
        remoteDataSource: gh<_i346.IOrderRemoteDataSource>(),
        localDataSource: gh<_i406.IOrderLocalDataSource>(),
      ));
  gh.factory<_i1.CancelOrderUseCase>(
      () => _i1.CancelOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i708.ConfirmOrderReceiptUseCase>(
      () => _i708.ConfirmOrderReceiptUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i577.DeleteOrderUseCase>(
      () => _i577.DeleteOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i691.GetOrderDetailUseCase>(
      () => _i691.GetOrderDetailUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i1015.GetOrderListUseCase>(
      () => _i1015.GetOrderListUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i40.SubmitEvaluationUseCase>(
      () => _i40.SubmitEvaluationUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i51.SubmitRequirementsUseCase>(
      () => _i51.SubmitRequirementsUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IInviteEvaluationUseCase>(
      () => _i618.InviteEvaluationUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IAddOrderDemandUseCase>(
      () => _i618.AddOrderDemandUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i549.OrderDetailBloc>(() => _i549.OrderDetailBloc(
        getOrderDetailUseCase: gh<_i691.GetOrderDetailUseCase>(),
        cancelOrderUseCase: gh<_i1.CancelOrderUseCase>(),
        confirmOrderReceiptUseCase: gh<_i708.ConfirmOrderReceiptUseCase>(),
        deleteOrderUseCase: gh<_i577.DeleteOrderUseCase>(),
        paymentService: gh<_i395.IPaymentService>(),
        submitEvaluationUseCase: gh<_i40.SubmitEvaluationUseCase>(),
        submitRequirementsUseCase: gh<_i51.SubmitRequirementsUseCase>(),
      ));
  gh.factory<_i618.IDeleteSellerOrderRecordUseCase>(
      () => _i618.DeleteSellerOrderRecordUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IConfirmOrderAcceptanceUseCase>(
      () => _i618.ConfirmOrderAcceptanceUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IDeliverOrderUseCase>(
      () => _i618.DeliverOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i176.OrderListBloc>(() => _i176.OrderListBloc(
      getOrderListUseCase: gh<_i1015.GetOrderListUseCase>()));
  gh.lazySingleton<_i253.IAfterSalesRemoteDataSource>(
      () => _i519.AfterSalesRemoteDataSource(gh<_i412.CoreDioClient>()));
  gh.lazySingleton<_i441.IAfterSalesRepository>(() =>
      _i363.AfterSalesRepositoryImpl(
          remoteDataSource: gh<_i253.IAfterSalesRemoteDataSource>()));
  gh.lazySingleton<_i1057.GetAfterSalesDetailUseCase>(() =>
      _i1057.GetAfterSalesDetailUseCase(gh<_i441.IAfterSalesRepository>()));
  gh.factory<_i970.ApplyForAfterSalesUseCase>(
      () => _i970.ApplyForAfterSalesUseCase(gh<_i441.IAfterSalesRepository>()));
  gh.factory<_i773.CancelAfterSalesUseCase>(
      () => _i773.CancelAfterSalesUseCase(gh<_i441.IAfterSalesRepository>()));
  gh.factory<_i88.DeleteAfterSalesUseCase>(
      () => _i88.DeleteAfterSalesUseCase(gh<_i441.IAfterSalesRepository>()));
  gh.factory<_i953.GetAfterSalesListUseCase>(
      () => _i953.GetAfterSalesListUseCase(gh<_i441.IAfterSalesRepository>()));
  gh.factory<_i59.AfterSalesBloc>(() => _i59.AfterSalesBloc(
        gh<_i953.GetAfterSalesListUseCase>(),
        gh<_i1057.GetAfterSalesDetailUseCase>(),
        gh<_i970.ApplyForAfterSalesUseCase>(),
        gh<_i773.CancelAfterSalesUseCase>(),
        gh<_i88.DeleteAfterSalesUseCase>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i809.RegisterModule {}
