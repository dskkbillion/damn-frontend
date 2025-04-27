// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../core/database/app_database.dart' as _i50;
import '../../core/navigation/services/i_navigation_service.dart' as _i625;
import '../../core/network/core_dio_client.dart' as _i412;
import '../../core/network/dio_http_client.dart' as _i962;
import '../../core/network/i_http_client.dart' as _i493;
import '../../core/network/interceptors/app_info_interceptor.dart' as _i405;
import '../../core/network/network_info.dart' as _i892;
import '../../core/payment/services/i_payment_service.dart' as _i395;
import '../../core/platform/network_info.dart' as _i50;
import '../../core/platform/token_validator.dart' as _i691;
import '../../core/storage/secure_storage_repository.dart' as _i822;
import '../../core/storage/secure_storage_repository_impl.dart' as _i912;
import '../../core/usecases/validate_token_usecase.dart' as _i58;
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
import '../../features/ai_docs/data/datasources/ai_chat_remote_data_source_impl.dart'
    as _i404;
import '../../features/ai_docs/data/datasources/file_upload_data_source_impl.dart'
    as _i478;
import '../../features/ai_docs/data/datasources/i_ai_chat_remote_data_source.dart'
    as _i607;
import '../../features/ai_docs/data/datasources/i_file_upload_data_source.dart'
    as _i436;
import '../../features/ai_docs/data/repositories/ai_chat_repository_impl.dart'
    as _i1012;
import '../../features/ai_docs/data/repositories/file_upload_repository_impl.dart'
    as _i43;
import '../../features/ai_docs/domain/repositories/i_ai_chat_repository.dart'
    as _i319;
import '../../features/ai_docs/domain/repositories/i_file_upload_repository.dart'
    as _i569;
import '../../features/ai_docs/domain/usecases/allocate_chat_resource_usecase.dart'
    as _i234;
import '../../features/ai_docs/domain/usecases/create_conversation_usecase.dart'
    as _i567;
import '../../features/ai_docs/domain/usecases/delete_conversation_usecase.dart'
    as _i63;
import '../../features/ai_docs/domain/usecases/get_conversations_usecase.dart'
    as _i257;
import '../../features/ai_docs/domain/usecases/get_related_services_usecase.dart'
    as _i598;
import '../../features/ai_docs/domain/usecases/load_history_usecase.dart'
    as _i830;
import '../../features/ai_docs/domain/usecases/stream_chat_completion_usecase.dart'
    as _i558;
import '../../features/ai_docs/domain/usecases/transcribe_audio_usecase.dart'
    as _i309;
import '../../features/ai_docs/domain/usecases/upload_file_usecase.dart'
    as _i798;
import '../../features/ai_docs/presentation/bloc/ai_chat/ai_chat_bloc.dart'
    as _i1040;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart'
    as _i123;
import '../../features/auth/data/datasources/user_info_remote_data_source.dart'
    as _i232;
import '../../features/auth/data/datasources/user_info_remote_data_source_impl.dart'
    as _i957;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/data/repositories/user_info_repository_impl.dart'
    as _i1015;
import '../../features/auth/domain/repositories/i_auth_repository.dart'
    as _i589;
import '../../features/auth/domain/repositories/i_user_info_repository.dart'
    as _i795;
import '../../features/auth/domain/usecases/login_with_verification_code.dart'
    as _i525;
import '../../features/auth/domain/usecases/send_verification_code.dart'
    as _i695;
import '../../features/auth/presentation/bloc/sms_login/sms_login_cubit.dart'
    as _i184;
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
import '../../features/orders/domain/usecases/confirm_order_acceptance_use_case.dart'
    as _i449;
import '../../features/orders/domain/usecases/confirm_order_receipt_use_case.dart'
    as _i708;
import '../../features/orders/domain/usecases/delete_order_use_case.dart'
    as _i577;
import '../../features/orders/domain/usecases/delete_seller_record_use_case.dart'
    as _i258;
import '../../features/orders/domain/usecases/deliver_order_use_case.dart'
    as _i176;
import '../../features/orders/domain/usecases/get_order_detail_use_case.dart'
    as _i691;
import '../../features/orders/domain/usecases/get_order_list_use_case.dart'
    as _i1015;
import '../../features/orders/domain/usecases/invite_evaluation_use_case.dart'
    as _i696;
import '../../features/orders/domain/usecases/reject_order_use_case.dart'
    as _i194;
import '../../features/orders/domain/usecases/seller/seller_order_actions_use_cases.dart'
    as _i618;
import '../../features/orders/domain/usecases/submit_evaluation_use_case.dart'
    as _i40;
import '../../features/orders/domain/usecases/submit_requirements_use_case.dart'
    as _i51;
import '../../features/orders/presentation/bloc/order_detail_bloc.dart'
    as _i549;
import '../../features/orders/presentation/bloc/order_list_bloc.dart' as _i176;
import '../../features/orders/presentation/seller/bloc/seller_order_detail_bloc.dart'
    as _i984;
import '../../features/orders/presentation/seller/bloc/seller_order_list_bloc.dart'
    as _i470;
import '../../features/seller/data/datasources/i_seller_local_data_source.dart'
    as _i30;
import '../../features/seller/data/datasources/i_seller_remote_data_source.dart'
    as _i703;
import '../../features/seller/data/datasources/seller_local_data_source_impl.dart'
    as _i507;
import '../../features/seller/data/datasources/seller_remote_data_source_impl.dart'
    as _i741;
import '../../features/seller/data/repositories/seller_repository_impl.dart'
    as _i927;
import '../../features/seller/domain/repositories/i_chat_repository.dart'
    as _i452;
import '../../features/seller/domain/repositories/i_seller_repository.dart'
    as _i203;
import '../../features/seller/domain/usecases/add_order_delivery_usecase.dart'
    as _i655;
import '../../features/seller/domain/usecases/audit_refund_usecase.dart'
    as _i363;
import '../../features/seller/domain/usecases/create_product_usecase.dart'
    as _i779;
import '../../features/seller/domain/usecases/delete_product_usecase.dart'
    as _i172;
import '../../features/seller/domain/usecases/get_authentication_status.dart'
    as _i825;
import '../../features/seller/domain/usecases/get_auto_reply_usecase.dart'
    as _i129;
import '../../features/seller/domain/usecases/get_chat_room_list_usecase.dart'
    as _i481;
import '../../features/seller/domain/usecases/get_seller_authentication_status_usecase.dart'
    as _i405;
import '../../features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart'
    as _i452;
import '../../features/seller/domain/usecases/get_seller_draft_list_usecase.dart'
    as _i725;
import '../../features/seller/domain/usecases/get_seller_notification_list_usecase.dart'
    as _i992;
import '../../features/seller/domain/usecases/get_seller_product_detail_usecase.dart'
    as _i475;
import '../../features/seller/domain/usecases/get_seller_product_list_usecase.dart'
    as _i679;
import '../../features/seller/domain/usecases/get_store_profile_usecase.dart'
    as _i714;
import '../../features/seller/domain/usecases/get_tenant_audit_list_usecase.dart'
    as _i237;
import '../../features/seller/domain/usecases/get_time_settings_usecase.dart'
    as _i1030;
import '../../features/seller/domain/usecases/get_unread_notification_count_usecase.dart'
    as _i680;
import '../../features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart'
    as _i665;
import '../../features/seller/domain/usecases/mark_notification_as_read_usecase.dart'
    as _i321;
import '../../features/seller/domain/usecases/set_auto_reply_usecase.dart'
    as _i610;
import '../../features/seller/domain/usecases/submit_authentication_application_usecase.dart'
    as _i626;
import '../../features/seller/domain/usecases/update_product_status_usecase.dart'
    as _i311;
import '../../features/seller/domain/usecases/update_product_usecase.dart'
    as _i267;
import '../../features/seller/domain/usecases/update_seller_online_status_usecase.dart'
    as _i528;
import '../../features/seller/domain/usecases/update_store_profile_usecase.dart'
    as _i172;
import '../../features/seller/domain/usecases/update_time_settings_usecase.dart'
    as _i1002;
import '../../features/seller/presentation/bloc/auth_application/auth_application_bloc.dart'
    as _i887;
import '../../features/seller/presentation/bloc/auth_management/auth_management_bloc.dart'
    as _i517;
import '../../features/seller/presentation/bloc/product_edit/product_edit_bloc.dart'
    as _i110;
import '../../features/seller/presentation/bloc/product_management/product_management_bloc.dart'
    as _i781;
import '../../features/seller/presentation/bloc/seller_home/seller_home_bloc.dart'
    as _i968;
import '../../features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart'
    as _i72;
import '../../features/seller/presentation/blocs/auto_reply/auto_reply_bloc.dart'
    as _i1060;
import '../../features/seller/presentation/blocs/notification_list/notification_list_bloc.dart'
    as _i886;
import '../../features/seller/presentation/blocs/order_delivery/order_delivery_bloc.dart'
    as _i512;
import '../../features/seller/presentation/blocs/time_management/time_management_bloc.dart'
    as _i295;
import 'injection_container.dart' as _i809;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final coreRegisterModule = _$CoreRegisterModule();
  final registerModule = _$RegisterModule();
  await gh.factoryAsync<_i655.PackageInfo>(
    () => coreRegisterModule.packageInfo,
    preResolve: true,
  );
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreRegisterModule.secureStorage);
  gh.lazySingleton<_i895.Connectivity>(() => coreRegisterModule.connectivity);
  gh.lazySingleton<_i50.AppDatabase>(() => coreRegisterModule.appDatabase);
  gh.lazySingleton<_i625.INavigationService>(
      () => coreRegisterModule.navigationService);
  gh.lazySingleton<_i395.IPaymentService>(
      () => coreRegisterModule.paymentService);
  gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => registerModule.internetConnectionChecker);
  gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
  gh.lazySingleton<_i361.Dio>(() =>
      coreRegisterModule.createDio(gh<String>(instanceName: 'backendBaseUrl')));
  gh.factory<_i30.ISellerLocalDataSource>(
      () => _i507.SellerLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i691.TokenValidator>(
      () => _i691.TokenValidatorImpl(gh<_i361.Dio>()));
  gh.lazySingleton<_i822.ISecureStorageRepository>(() =>
      _i912.SecureStorageRepositoryImpl(gh<_i558.FlutterSecureStorage>()));
  gh.lazySingleton<_i493.IHttpClient>(() => _i962.DioHttpClient());
  gh.lazySingleton<_i607.IAiChatRemoteDataSource>(
      () => _i404.AiChatRemoteDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<String>(
    () => registerModule.baseUrl,
    instanceName: 'baseUrl',
  );
  gh.factory<_i703.ISellerRemoteDataSource>(
      () => _i741.SellerRemoteDataSourceImpl(gh<_i361.Dio>()));
  gh.lazySingleton<_i319.IAiChatRepository>(() => _i1012.AiChatRepositoryImpl(
      remoteDataSource: gh<_i607.IAiChatRemoteDataSource>()));
  gh.lazySingleton<_i232.UserInfoRemoteDataSource>(
      () => _i957.UserInfoRemoteDataSourceImpl(gh<_i361.Dio>()));
  gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i123.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
  gh.lazySingleton<_i406.IOrderLocalDataSource>(() =>
      _i1016.OrderLocalDataSourceImpl(appDatabase: gh<_i50.AppDatabase>()));
  gh.lazySingleton<_i892.NetworkInfo>(
      () => _i892.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()));
  gh.factory<_i481.GetChatRoomListUseCase>(
      () => _i481.GetChatRoomListUseCase(gh<_i452.IChatRepository>()));
  gh.lazySingleton<_i234.AllocateChatResourceUseCase>(
      () => _i234.AllocateChatResourceUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i567.CreateConversationUseCase>(
      () => _i567.CreateConversationUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i63.DeleteConversationUseCase>(
      () => _i63.DeleteConversationUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i257.GetConversationsUseCase>(
      () => _i257.GetConversationsUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i598.GetRelatedServicesUseCase>(
      () => _i598.GetRelatedServicesUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i830.LoadHistoryUseCase>(
      () => _i830.LoadHistoryUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i558.StreamChatCompletionUseCase>(
      () => _i558.StreamChatCompletionUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i309.TranscribeAudioUseCase>(
      () => _i309.TranscribeAudioUseCase(gh<_i319.IAiChatRepository>()));
  gh.factory<_i405.AppInfoInterceptor>(
      () => _i405.AppInfoInterceptor(gh<_i655.PackageInfo>()));
  gh.factory<_i58.ValidateTokenUseCase>(
      () => _i58.ValidateTokenUseCase(gh<_i691.TokenValidator>()));
  gh.lazySingleton<_i795.IUserInfoRepository>(
      () => _i1015.UserInfoRepositoryImpl(
            remoteDataSource: gh<_i232.UserInfoRemoteDataSource>(),
            networkInfo: gh<_i50.NetworkInfo>(),
          ));
  gh.lazySingleton<_i436.IFileUploadDataSource>(
      () => _i478.FileUploadDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<_i569.IFileUploadRepository>(() =>
      _i43.FileUploadRepositoryImpl(
          dataSource: gh<_i436.IFileUploadDataSource>()));
  gh.lazySingleton<_i798.UploadFileUseCase>(
      () => _i798.UploadFileUseCase(gh<_i569.IFileUploadRepository>()));
  gh.factory<_i412.CoreDioClient>(() => _i412.CoreDioClient(
        gh<String>(instanceName: 'baseUrl'),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i405.AppInfoInterceptor>(),
      ));
  gh.factory<_i1040.AiChatBloc>(() => _i1040.AiChatBloc(
        gh<_i257.GetConversationsUseCase>(),
        gh<_i830.LoadHistoryUseCase>(),
        gh<_i567.CreateConversationUseCase>(),
        gh<_i63.DeleteConversationUseCase>(),
        gh<_i558.StreamChatCompletionUseCase>(),
        gh<_i798.UploadFileUseCase>(),
        gh<_i598.GetRelatedServicesUseCase>(),
        gh<_i234.AllocateChatResourceUseCase>(),
        gh<_i309.TranscribeAudioUseCase>(),
        gh<_i558.FlutterSecureStorage>(),
      ));
  gh.factory<_i203.ISellerRepository>(() => _i927.SellerRepositoryImpl(
        gh<_i703.ISellerRemoteDataSource>(),
        gh<_i30.ISellerLocalDataSource>(),
        gh<_i892.NetworkInfo>(),
      ));
  gh.lazySingleton<_i346.IOrderRemoteDataSource>(() =>
      _i230.OrderRemoteDataSourceImpl(
          coreDioClient: gh<_i412.CoreDioClient>()));
  gh.factory<_i655.AddOrderDeliveryUseCase>(() => _i655.AddOrderDeliveryUseCase(
        gh<_i203.ISellerRepository>(),
        gh<_i569.IFileUploadRepository>(),
      ));
  gh.factory<_i779.CreateProductUseCase>(() => _i779.CreateProductUseCase(
        gh<_i203.ISellerRepository>(),
        gh<_i569.IFileUploadRepository>(),
      ));
  gh.factory<_i626.SubmitAuthenticationApplicationUseCase>(
      () => _i626.SubmitAuthenticationApplicationUseCase(
            gh<_i203.ISellerRepository>(),
            gh<_i569.IFileUploadRepository>(),
          ));
  gh.factory<_i267.UpdateProductUseCase>(() => _i267.UpdateProductUseCase(
        gh<_i203.ISellerRepository>(),
        gh<_i569.IFileUploadRepository>(),
      ));
  gh.factory<_i172.UpdateStoreProfileUseCase>(
      () => _i172.UpdateStoreProfileUseCase(
            gh<_i203.ISellerRepository>(),
            gh<_i569.IFileUploadRepository>(),
          ));
  gh.lazySingleton<_i724.IOrderRepository>(() => _i376.OrderRepositoryImpl(
        remoteDataSource: gh<_i346.IOrderRemoteDataSource>(),
        localDataSource: gh<_i406.IOrderLocalDataSource>(),
      ));
  gh.factory<_i1.CancelOrderUseCase>(
      () => _i1.CancelOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i449.ConfirmOrderAcceptanceUseCase>(
      () => _i449.ConfirmOrderAcceptanceUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i708.ConfirmOrderReceiptUseCase>(
      () => _i708.ConfirmOrderReceiptUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i577.DeleteOrderUseCase>(
      () => _i577.DeleteOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i258.DeleteSellerRecordUseCase>(
      () => _i258.DeleteSellerRecordUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i176.DeliverOrderUseCase>(
      () => _i176.DeliverOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i691.GetOrderDetailUseCase>(
      () => _i691.GetOrderDetailUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i1015.GetOrderListUseCase>(
      () => _i1015.GetOrderListUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i696.InviteEvaluationUseCase>(
      () => _i696.InviteEvaluationUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i194.RejectOrderUseCase>(
      () => _i194.RejectOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i40.SubmitEvaluationUseCase>(
      () => _i40.SubmitEvaluationUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i51.SubmitRequirementsUseCase>(
      () => _i51.SubmitRequirementsUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i825.GetAuthenticationStatus>(
      () => _i825.GetAuthenticationStatus(gh<_i203.ISellerRepository>()));
  gh.lazySingleton<_i589.IAuthRepository>(() => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
        secureStorage: gh<_i822.ISecureStorageRepository>(),
        networkInfo: gh<_i50.NetworkInfo>(),
        userInfoRepository: gh<_i795.IUserInfoRepository>(),
        tokenValidator: gh<_i691.TokenValidator>(),
      ));
  gh.factory<_i887.AuthApplicationBloc>(() => _i887.AuthApplicationBloc(
      gh<_i626.SubmitAuthenticationApplicationUseCase>()));
  gh.factory<_i618.IInviteEvaluationUseCase>(
      () => _i618.InviteEvaluationUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IAddOrderDemandUseCase>(
      () => _i618.AddOrderDemandUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i512.OrderDeliveryBloc>(
      () => _i512.OrderDeliveryBloc(gh<_i655.AddOrderDeliveryUseCase>()));
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
  gh.factory<_i470.SellerOrderListBloc>(() => _i470.SellerOrderListBloc(
        gh<_i1015.GetOrderListUseCase>(),
        gh<_i449.ConfirmOrderAcceptanceUseCase>(),
        gh<_i194.RejectOrderUseCase>(),
        gh<_i176.DeliverOrderUseCase>(),
        gh<_i696.InviteEvaluationUseCase>(),
        gh<_i258.DeleteSellerRecordUseCase>(),
      ));
  gh.factory<_i984.SellerOrderDetailBloc>(() => _i984.SellerOrderDetailBloc(
        gh<_i691.GetOrderDetailUseCase>(),
        gh<_i449.ConfirmOrderAcceptanceUseCase>(),
        gh<_i194.RejectOrderUseCase>(),
        gh<_i176.DeliverOrderUseCase>(),
        gh<_i696.InviteEvaluationUseCase>(),
        gh<_i258.DeleteSellerRecordUseCase>(),
      ));
  gh.factory<_i618.IConfirmOrderAcceptanceUseCase>(
      () => _i618.ConfirmOrderAcceptanceUseCase(gh<_i724.IOrderRepository>()));
  gh.factory<_i618.IDeliverOrderUseCase>(
      () => _i618.DeliverOrderUseCase(gh<_i724.IOrderRepository>()));
  gh.lazySingleton<_i525.LoginWithVerificationCodeUseCase>(() =>
      _i525.LoginWithVerificationCodeUseCase(gh<_i589.IAuthRepository>()));
  gh.lazySingleton<_i695.SendVerificationCodeUseCase>(
      () => _i695.SendVerificationCodeUseCase(gh<_i589.IAuthRepository>()));
  gh.factory<_i176.OrderListBloc>(() => _i176.OrderListBloc(
      getOrderListUseCase: gh<_i1015.GetOrderListUseCase>()));
  gh.lazySingleton<_i253.IAfterSalesRemoteDataSource>(
      () => _i519.AfterSalesRemoteDataSource(gh<_i412.CoreDioClient>()));
  gh.factory<_i517.AuthManagementBloc>(
      () => _i517.AuthManagementBloc(gh<_i825.GetAuthenticationStatus>()));
  gh.factory<_i363.AuditRefundUseCase>(
      () => _i363.AuditRefundUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i172.DeleteProductUseCase>(
      () => _i172.DeleteProductUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i129.GetAutoReplyUseCase>(
      () => _i129.GetAutoReplyUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i405.GetSellerAuthenticationStatusUseCase>(() =>
      _i405.GetSellerAuthenticationStatusUseCase(
          gh<_i203.ISellerRepository>()));
  gh.factory<_i452.GetSellerDashboardDataUseCase>(
      () => _i452.GetSellerDashboardDataUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i725.GetSellerDraftListUseCase>(
      () => _i725.GetSellerDraftListUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i992.GetSellerNotificationListUseCase>(() =>
      _i992.GetSellerNotificationListUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i475.GetSellerProductDetailUseCase>(
      () => _i475.GetSellerProductDetailUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i679.GetSellerProductListUseCase>(
      () => _i679.GetSellerProductListUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i714.GetStoreProfileUseCase>(
      () => _i714.GetStoreProfileUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i237.GetTenantAuditListUseCase>(
      () => _i237.GetTenantAuditListUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i1030.GetTimeSettingsUseCase>(
      () => _i1030.GetTimeSettingsUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i680.GetUnreadNotificationCountUseCase>(() =>
      _i680.GetUnreadNotificationCountUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i665.MarkAllNotificationsAsReadUseCase>(() =>
      _i665.MarkAllNotificationsAsReadUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i321.MarkNotificationAsReadUseCase>(
      () => _i321.MarkNotificationAsReadUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i610.SetAutoReplyUseCase>(
      () => _i610.SetAutoReplyUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i311.UpdateProductStatusUseCase>(
      () => _i311.UpdateProductStatusUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i528.UpdateSellerOnlineStatusUseCase>(() =>
      _i528.UpdateSellerOnlineStatusUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i1002.UpdateTimeSettingsUseCase>(
      () => _i1002.UpdateTimeSettingsUseCase(gh<_i203.ISellerRepository>()));
  gh.factory<_i110.ProductEditBloc>(() => _i110.ProductEditBloc(
        gh<_i475.GetSellerProductDetailUseCase>(),
        gh<_i779.CreateProductUseCase>(),
        gh<_i267.UpdateProductUseCase>(),
      ));
  gh.factory<_i968.SellerHomeBloc>(() => _i968.SellerHomeBloc(
        gh<_i452.GetSellerDashboardDataUseCase>(),
        gh<_i714.GetStoreProfileUseCase>(),
        gh<_i625.INavigationService>(),
      ));
  gh.factory<_i184.SmsLoginCubit>(() => _i184.SmsLoginCubit(
        sendVerificationCodeUseCase: gh<_i695.SendVerificationCodeUseCase>(),
        loginWithVerificationCodeUseCase:
            gh<_i525.LoginWithVerificationCodeUseCase>(),
      ));
  gh.factory<_i781.ProductManagementBloc>(() => _i781.ProductManagementBloc(
        gh<_i679.GetSellerProductListUseCase>(),
        gh<_i725.GetSellerDraftListUseCase>(),
        gh<_i311.UpdateProductStatusUseCase>(),
        gh<_i172.DeleteProductUseCase>(),
        gh<_i625.INavigationService>(),
      ));
  gh.factory<_i1060.AutoReplyBloc>(() => _i1060.AutoReplyBloc(
        gh<_i129.GetAutoReplyUseCase>(),
        gh<_i610.SetAutoReplyUseCase>(),
      ));
  gh.factory<_i886.NotificationListBloc>(() => _i886.NotificationListBloc(
        gh<_i992.GetSellerNotificationListUseCase>(),
        gh<_i321.MarkNotificationAsReadUseCase>(),
        gh<_i665.MarkAllNotificationsAsReadUseCase>(),
        gh<_i680.GetUnreadNotificationCountUseCase>(),
      ));
  gh.lazySingleton<_i441.IAfterSalesRepository>(() =>
      _i363.AfterSalesRepositoryImpl(
          remoteDataSource: gh<_i253.IAfterSalesRemoteDataSource>()));
  gh.factory<_i72.AfterSalesReviewBloc>(() => _i72.AfterSalesReviewBloc(
        gh<_i237.GetTenantAuditListUseCase>(),
        gh<_i363.AuditRefundUseCase>(),
      ));
  gh.factory<_i295.TimeManagementBloc>(() => _i295.TimeManagementBloc(
        gh<_i1030.GetTimeSettingsUseCase>(),
        gh<_i1002.UpdateTimeSettingsUseCase>(),
      ));
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

class _$CoreRegisterModule extends _i809.CoreRegisterModule {}

class _$RegisterModule extends _i291.RegisterModule {}
