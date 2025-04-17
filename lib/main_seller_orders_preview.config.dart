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
import 'core/network/dio_http_client.dart' as _i1030;
import 'core/network/i_http_client.dart' as _i31;
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
import 'features/ai_docs/data/datasources/ai_chat_remote_data_source_impl.dart'
    as _i682;
import 'features/ai_docs/data/datasources/file_upload_data_source_impl.dart'
    as _i324;
import 'features/ai_docs/data/datasources/i_ai_chat_remote_data_source.dart'
    as _i748;
import 'features/ai_docs/data/datasources/i_file_upload_data_source.dart'
    as _i145;
import 'features/ai_docs/data/repositories/ai_chat_repository_impl.dart'
    as _i1065;
import 'features/ai_docs/data/repositories/file_upload_repository_impl.dart'
    as _i362;
import 'features/ai_docs/domain/repositories/i_ai_chat_repository.dart'
    as _i920;
import 'features/ai_docs/domain/repositories/i_file_upload_repository.dart'
    as _i172;
import 'features/ai_docs/domain/usecases/allocate_chat_resource_usecase.dart'
    as _i57;
import 'features/ai_docs/domain/usecases/create_conversation_usecase.dart'
    as _i16;
import 'features/ai_docs/domain/usecases/delete_conversation_usecase.dart'
    as _i182;
import 'features/ai_docs/domain/usecases/get_conversations_usecase.dart'
    as _i437;
import 'features/ai_docs/domain/usecases/get_related_services_usecase.dart'
    as _i67;
import 'features/ai_docs/domain/usecases/load_history_usecase.dart' as _i209;
import 'features/ai_docs/domain/usecases/stream_chat_completion_usecase.dart'
    as _i562;
import 'features/ai_docs/domain/usecases/transcribe_audio_usecase.dart'
    as _i266;
import 'features/ai_docs/domain/usecases/upload_file_usecase.dart' as _i317;
import 'features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart' as _i959;
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
import 'features/orders/domain/usecases/confirm_order_acceptance_use_case.dart'
    as _i87;
import 'features/orders/domain/usecases/confirm_order_receipt_use_case.dart'
    as _i860;
import 'features/orders/domain/usecases/delete_order_use_case.dart' as _i249;
import 'features/orders/domain/usecases/delete_seller_record_use_case.dart'
    as _i326;
import 'features/orders/domain/usecases/deliver_order_use_case.dart' as _i2;
import 'features/orders/domain/usecases/get_order_detail_use_case.dart'
    as _i332;
import 'features/orders/domain/usecases/get_order_list_use_case.dart' as _i354;
import 'features/orders/domain/usecases/invite_evaluation_use_case.dart'
    as _i323;
import 'features/orders/domain/usecases/reject_order_use_case.dart' as _i539;
import 'features/orders/domain/usecases/seller/seller_order_actions_use_cases.dart'
    as _i431;
import 'features/orders/domain/usecases/submit_evaluation_use_case.dart'
    as _i152;
import 'features/orders/domain/usecases/submit_requirements_use_case.dart'
    as _i648;
import 'features/orders/presentation/bloc/order_detail_bloc.dart' as _i768;
import 'features/orders/presentation/bloc/order_list_bloc.dart' as _i620;
import 'features/orders/presentation/seller/bloc/seller_order_detail_bloc.dart'
    as _i263;
import 'features/orders/presentation/seller/bloc/seller_order_list_bloc.dart'
    as _i1008;

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
  gh.lazySingleton<_i31.IHttpClient>(() => _i1030.DioHttpClient());
  gh.lazySingleton<_i748.IAiChatRemoteDataSource>(
      () => _i682.AiChatRemoteDataSourceImpl(gh<_i31.IHttpClient>()));
  gh.lazySingleton<_i920.IAiChatRepository>(
      () => _i1065.AiChatRepositoryImpl(gh<_i748.IAiChatRemoteDataSource>()));
  gh.lazySingleton<_i632.IOrderLocalDataSource>(() =>
      _i936.OrderLocalDataSourceImpl(appDatabase: gh<_i111.AppDatabase>()));
  gh.lazySingleton<_i57.AllocateChatResourceUseCase>(
      () => _i57.AllocateChatResourceUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i16.CreateConversationUseCase>(
      () => _i16.CreateConversationUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i182.DeleteConversationUseCase>(
      () => _i182.DeleteConversationUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i437.GetConversationsUseCase>(
      () => _i437.GetConversationsUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i67.GetRelatedServicesUseCase>(
      () => _i67.GetRelatedServicesUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i209.LoadHistoryUseCase>(
      () => _i209.LoadHistoryUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i562.StreamChatCompletionUseCase>(
      () => _i562.StreamChatCompletionUseCase(gh<_i920.IAiChatRepository>()));
  gh.lazySingleton<_i266.TranscribeAudioUseCase>(
      () => _i266.TranscribeAudioUseCase(gh<_i920.IAiChatRepository>()));
  gh.factory<_i1018.AppInfoInterceptor>(
      () => _i1018.AppInfoInterceptor(gh<_i655.PackageInfo>()));
  gh.lazySingleton<_i145.IFileUploadDataSource>(
      () => _i324.FileUploadDataSourceImpl(gh<_i31.IHttpClient>()));
  gh.lazySingleton<_i172.IFileUploadRepository>(() =>
      _i362.FileUploadRepositoryImpl(
          dataSource: gh<_i145.IFileUploadDataSource>()));
  gh.lazySingleton<_i317.UploadFileUseCase>(
      () => _i317.UploadFileUseCase(gh<_i172.IFileUploadRepository>()));
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
  gh.factory<_i87.ConfirmOrderAcceptanceUseCase>(
      () => _i87.ConfirmOrderAcceptanceUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i860.ConfirmOrderReceiptUseCase>(
      () => _i860.ConfirmOrderReceiptUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i249.DeleteOrderUseCase>(
      () => _i249.DeleteOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i326.DeleteSellerRecordUseCase>(
      () => _i326.DeleteSellerRecordUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i2.DeliverOrderUseCase>(
      () => _i2.DeliverOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i332.GetOrderDetailUseCase>(
      () => _i332.GetOrderDetailUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i354.GetOrderListUseCase>(
      () => _i354.GetOrderListUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i323.InviteEvaluationUseCase>(
      () => _i323.InviteEvaluationUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i539.RejectOrderUseCase>(
      () => _i539.RejectOrderUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i152.SubmitEvaluationUseCase>(
      () => _i152.SubmitEvaluationUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i648.SubmitRequirementsUseCase>(
      () => _i648.SubmitRequirementsUseCase(gh<_i281.IOrderRepository>()));
  gh.factory<_i959.AiChatBloc>(() => _i959.AiChatBloc(
        gh<_i437.GetConversationsUseCase>(),
        gh<_i209.LoadHistoryUseCase>(),
        gh<_i16.CreateConversationUseCase>(),
        gh<_i182.DeleteConversationUseCase>(),
        gh<_i562.StreamChatCompletionUseCase>(),
        gh<_i317.UploadFileUseCase>(),
        gh<_i67.GetRelatedServicesUseCase>(),
        gh<_i57.AllocateChatResourceUseCase>(),
        gh<_i266.TranscribeAudioUseCase>(),
      ));
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
  gh.factory<_i1008.SellerOrderListBloc>(() => _i1008.SellerOrderListBloc(
        gh<_i354.GetOrderListUseCase>(),
        gh<_i87.ConfirmOrderAcceptanceUseCase>(),
        gh<_i539.RejectOrderUseCase>(),
        gh<_i2.DeliverOrderUseCase>(),
        gh<_i323.InviteEvaluationUseCase>(),
        gh<_i326.DeleteSellerRecordUseCase>(),
      ));
  gh.factory<_i263.SellerOrderDetailBloc>(() => _i263.SellerOrderDetailBloc(
        gh<_i332.GetOrderDetailUseCase>(),
        gh<_i87.ConfirmOrderAcceptanceUseCase>(),
        gh<_i539.RejectOrderUseCase>(),
        gh<_i2.DeliverOrderUseCase>(),
        gh<_i323.InviteEvaluationUseCase>(),
        gh<_i326.DeleteSellerRecordUseCase>(),
      ));
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
