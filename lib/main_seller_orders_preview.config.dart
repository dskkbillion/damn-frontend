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

import 'app/di/injection_container.dart' as _i467;
import 'core/database/app_database.dart' as _i111;
import 'core/navigation/services/i_navigation_service.dart' as _i735;
import 'core/network/core_dio_client.dart' as _i831;
import 'core/network/interceptors/app_info_interceptor.dart' as _i1018;
import 'core/payment/services/i_payment_service.dart' as _i910;
import 'features/after_sales/data/datasources/after_sales_remote_data_source.dart'
    as _i504;
import 'features/after_sales/data/datasources/i_after_sales_remote_data_source.dart'
    as _i297;
import 'features/after_sales/data/repositories/after_sales_repository_impl.dart'
    as _i429;
import 'features/after_sales/domain/repositories/i_after_sales_repository.dart'
    as _i882;
import 'features/after_sales/domain/usecases/apply_for_after_sales_use_case.dart'
    as _i507;
import 'features/after_sales/domain/usecases/cancel_after_sales_use_case.dart'
    as _i607;
import 'features/after_sales/domain/usecases/delete_after_sales_use_case.dart'
    as _i557;
import 'features/after_sales/domain/usecases/get_after_sales_detail_use_case.dart'
    as _i885;
import 'features/after_sales/domain/usecases/get_after_sales_list_use_case.dart'
    as _i915;
import 'features/after_sales/presentation/bloc/after_sales_bloc.dart' as _i918;
import 'features/orders/data/datasources/i_order_local_data_source.dart'
    as _i632;
import 'features/orders/data/datasources/i_order_remote_data_source.dart'
    as _i1045;
import 'features/orders/data/datasources/order_local_data_source_impl.dart'
    as _i936;
import 'features/orders/data/datasources/order_remote_data_source_impl.dart'
    as _i814;
import 'features/orders/data/repositories/order_repository_impl.dart' as _i1010;
import 'features/orders/domain/repositories/i_order_repository.dart' as _i281;
import 'features/orders/domain/usecases/cancel_order_use_case.dart' as _i992;
import 'features/orders/domain/usecases/confirm_order_receipt_use_case.dart'
    as _i860;
import 'features/orders/domain/usecases/delete_order_use_case.dart' as _i249;
import 'features/orders/domain/usecases/get_order_detail_use_case.dart'
    as _i332;
import 'features/orders/domain/usecases/get_order_list_use_case.dart' as _i354;
import 'features/orders/domain/usecases/seller/seller_order_actions_use_cases.dart'
    as _i431;
import 'features/orders/domain/usecases/submit_evaluation_use_case.dart'
    as _i152;
import 'features/orders/domain/usecases/submit_requirements_use_case.dart'
    as _i648;
import 'features/orders/presentation/bloc/order_detail_bloc.dart' as _i768;
import 'features/orders/presentation/bloc/order_list_bloc.dart' as _i620;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
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
  gh.lazySingleton<_i111.AppDatabase>(() => registerModule.appDatabase);
  gh.lazySingleton<_i735.INavigationService>(
      () => registerModule.navigationService);
  gh.lazySingleton<_i910.IPaymentService>(() => registerModule.paymentService);
  gh.lazySingleton<_i632.IOrderLocalDataSource>(() =>
      _i936.OrderLocalDataSourceImpl(appDatabase: gh<_i111.AppDatabase>()));
  gh.factory<_i1018.AppInfoInterceptor>(
      () => _i1018.AppInfoInterceptor(gh<_i655.PackageInfo>()));
  gh.factory<_i831.CoreDioClient>(() => _i831.CoreDioClient(
        gh<String>(instanceName: 'baseUrl'),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i1018.AppInfoInterceptor>(),
      ));
  gh.lazySingleton<_i1045.IOrderRemoteDataSource>(() =>
      _i814.OrderRemoteDataSourceImpl(
          coreDioClient: gh<_i831.CoreDioClient>()));
  gh.lazySingleton<_i281.IOrderRepository>(() => _i1010.OrderRepositoryImpl(
        remoteDataSource: gh<_i1045.IOrderRemoteDataSource>(),
        localDataSource: gh<_i632.IOrderLocalDataSource>(),
      ));
  gh.factory<_i992.CancelOrderUseCase>(
      () => _i992.CancelOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i860.ConfirmOrderReceiptUseCase>(
      () => _i860.ConfirmOrderReceiptUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i249.DeleteOrderUseCase>(
      () => _i249.DeleteOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i332.GetOrderDetailUseCase>(
      () => _i332.GetOrderDetailUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i354.GetOrderListUseCase>(
      () => _i354.GetOrderListUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i152.SubmitEvaluationUseCase>(
      () => _i152.SubmitEvaluationUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i648.SubmitRequirementsUseCase>(
      () => _i648.SubmitRequirementsUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i431.IInviteEvaluationUseCase>(
      () => _i431.InviteEvaluationUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i431.IAddOrderDemandUseCase>(
      () => _i431.AddOrderDemandUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i768.OrderDetailBloc>(() => _i768.OrderDetailBloc(
        getOrderDetailUseCase: gh<_i332.GetOrderDetailUseCase>(),
        cancelOrderUseCase: gh<_i992.CancelOrderUseCase>(),
        confirmOrderReceiptUseCase: gh<_i860.ConfirmOrderReceiptUseCase>(),
        deleteOrderUseCase: gh<_i249.DeleteOrderUseCase>(),
        paymentService: gh<_i910.IPaymentService>(),
        submitEvaluationUseCase: gh<_i152.SubmitEvaluationUseCase>(),
        submitRequirementsUseCase: gh<_i648.SubmitRequirementsUseCase>(),
      ));
  gh.factory<_i431.IDeleteSellerOrderRecordUseCase>(
      () => _i431.DeleteSellerOrderRecordUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i431.IConfirmOrderAcceptanceUseCase>(
      () => _i431.ConfirmOrderAcceptanceUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i431.IDeliverOrderUseCase>(
      () => _i431.DeliverOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i620.OrderListBloc>(() => _i620.OrderListBloc(
      getOrderListUseCase: gh<_i354.GetOrderListUseCase>()));
  gh.lazySingleton<_i297.IAfterSalesRemoteDataSource>(
      () => _i504.AfterSalesRemoteDataSource(gh<_i831.CoreDioClient>()));
  gh.lazySingleton<_i882.IAfterSalesRepository>(() =>
      _i429.AfterSalesRepositoryImpl(
          remoteDataSource: gh<_i297.IAfterSalesRemoteDataSource>()));
  gh.lazySingleton<_i885.GetAfterSalesDetailUseCase>(() =>
      _i885.GetAfterSalesDetailUseCase(gh<_i882.IAfterSalesRepository>()));
  gh.factory<_i507.ApplyForAfterSalesUseCase>(
      () => _i507.ApplyForAfterSalesUseCase(gh<_i882.IAfterSalesRepository>()));
  gh.factory<_i607.CancelAfterSalesUseCase>(
      () => _i607.CancelAfterSalesUseCase(gh<_i882.IAfterSalesRepository>()));
  gh.factory<_i557.DeleteAfterSalesUseCase>(
      () => _i557.DeleteAfterSalesUseCase(gh<_i882.IAfterSalesRepository>()));
  gh.factory<_i915.GetAfterSalesListUseCase>(
      () => _i915.GetAfterSalesListUseCase(gh<_i882.IAfterSalesRepository>()));
  gh.factory<_i918.AfterSalesBloc>(() => _i918.AfterSalesBloc(
        gh<_i915.GetAfterSalesListUseCase>(),
        gh<_i885.GetAfterSalesDetailUseCase>(),
        gh<_i507.ApplyForAfterSalesUseCase>(),
        gh<_i607.CancelAfterSalesUseCase>(),
        gh<_i557.DeleteAfterSalesUseCase>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i467.RegisterModule {}
