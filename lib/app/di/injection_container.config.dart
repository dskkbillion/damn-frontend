// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/network/dio_http_client.dart' as _i962;
import '../../core/network/i_http_client.dart' as _i493;
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
  gh.lazySingleton<_i493.IHttpClient>(() => _i962.DioHttpClient());
  gh.lazySingleton<_i607.IAiChatRemoteDataSource>(
      () => _i404.AiChatRemoteDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<_i319.IAiChatRepository>(
      () => _i1012.AiChatRepositoryImpl(gh<_i607.IAiChatRemoteDataSource>()));
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
  gh.lazySingleton<_i436.IFileUploadDataSource>(
      () => _i478.FileUploadDataSourceImpl(gh<_i493.IHttpClient>()));
  gh.lazySingleton<_i569.IFileUploadRepository>(() =>
      _i43.FileUploadRepositoryImpl(
          dataSource: gh<_i436.IFileUploadDataSource>()));
  gh.lazySingleton<_i798.UploadFileUseCase>(
      () => _i798.UploadFileUseCase(gh<_i569.IFileUploadRepository>()));
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
  return getIt;
}
