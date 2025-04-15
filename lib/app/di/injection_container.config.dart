// dart format width=80
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
import 'package:injectable/injectable.dart' as _i526;

import '../../core/network/dio_http_client.dart' as _i962;
import '../../core/network/i_http_client.dart' as _i493;
import '../../core/platform/network_info.dart' as _i50;
import '../../core/platform/network_info_impl.dart' as _i80;
import '../../core/platform/token_validator.dart' as _i691;
import '../../core/storage/secure_storage_repository.dart' as _i822;
import '../../core/storage/secure_storage_repository_impl.dart' as _i912;
import '../../core/usecases/validate_token_usecase.dart' as _i58;
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
import 'register_module.dart' as _i291;

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
  gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage);
  gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
  gh.lazySingleton<_i691.TokenValidator>(
      () => _i691.TokenValidatorImpl(gh<_i361.Dio>()));
  gh.lazySingleton<_i493.IHttpClient>(() => _i962.DioHttpClient());
  gh.lazySingleton<_i607.IAiChatRemoteDataSource>(
      () => _i404.AiChatRemoteDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<_i232.UserInfoRemoteDataSource>(
      () => _i957.UserInfoRemoteDataSourceImpl(gh<_i361.Dio>()));
  gh.lazySingleton<_i50.NetworkInfo>(
      () => _i80.NetworkInfoImpl(gh<_i895.Connectivity>()));
  gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i123.AuthRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
  gh.lazySingleton<_i319.IAiChatRepository>(
      () => _i1012.AiChatRepositoryImpl(gh<_i607.IAiChatRemoteDataSource>()));
  gh.lazySingleton<_i822.ISecureStorageRepository>(() =>
      _i912.SecureStorageRepositoryImpl(gh<_i558.FlutterSecureStorage>()));
  gh.lazySingleton<_i257.GetConversationsUseCase>(
      () => _i257.GetConversationsUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i558.StreamChatCompletionUseCase>(
      () => _i558.StreamChatCompletionUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i309.TranscribeAudioUseCase>(
      () => _i309.TranscribeAudioUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i234.AllocateChatResourceUseCase>(
      () => _i234.AllocateChatResourceUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i598.GetRelatedServicesUseCase>(
      () => _i598.GetRelatedServicesUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i567.CreateConversationUseCase>(
      () => _i567.CreateConversationUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i63.DeleteConversationUseCase>(
      () => _i63.DeleteConversationUseCase(gh<_i319.IAiChatRepository>()));
  gh.lazySingleton<_i830.LoadHistoryUseCase>(
      () => _i830.LoadHistoryUseCase(gh<_i319.IAiChatRepository>()));
  gh.factory<_i58.ValidateTokenUseCase>(
      () => _i58.ValidateTokenUseCase(gh<_i691.TokenValidator>()));
  gh.lazySingleton<_i436.IFileUploadDataSource>(
      () => _i478.FileUploadDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<_i795.IUserInfoRepository>(
      () => _i1015.UserInfoRepositoryImpl(
            remoteDataSource: gh<_i232.UserInfoRemoteDataSource>(),
            networkInfo: gh<_i50.NetworkInfo>(),
          ));
  gh.lazySingleton<_i569.IFileUploadRepository>(() =>
      _i43.FileUploadRepositoryImpl(
          dataSource: gh<_i436.IFileUploadDataSource>()));
  gh.lazySingleton<_i798.UploadFileUseCase>(
      () => _i798.UploadFileUseCase(gh<_i569.IFileUploadRepository>()));
  gh.lazySingleton<_i589.IAuthRepository>(() => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
        secureStorage: gh<_i822.ISecureStorageRepository>(),
        networkInfo: gh<_i50.NetworkInfo>(),
        userInfoRepository: gh<_i795.IUserInfoRepository>(),
        tokenValidator: gh<_i691.TokenValidator>(),
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
      ));
  gh.lazySingleton<_i525.LoginWithVerificationCodeUseCase>(() =>
      _i525.LoginWithVerificationCodeUseCase(gh<_i589.IAuthRepository>()));
  gh.lazySingleton<_i695.SendVerificationCodeUseCase>(
      () => _i695.SendVerificationCodeUseCase(gh<_i589.IAuthRepository>()));
  gh.factory<_i184.SmsLoginCubit>(() => _i184.SmsLoginCubit(
        sendVerificationCodeUseCase: gh<_i695.SendVerificationCodeUseCase>(),
        loginWithVerificationCodeUseCase:
            gh<_i525.LoginWithVerificationCodeUseCase>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
