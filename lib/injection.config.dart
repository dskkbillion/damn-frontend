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

import 'core/network/i_http_client.dart' as _i31;
import 'core/network/mock_http_client.dart' as _i1004;
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
  gh.factory<_i31.IHttpClient>(() => _i1004.MockHttpClient());
  gh.lazySingleton<_i145.IFileUploadDataSource>(
      () => _i324.FileUploadDataSourceImpl(gh<_i31.IHttpClient>()));
  gh.lazySingleton<_i748.IAiChatRemoteDataSource>(
      () => _i682.AiChatRemoteDataSourceImpl(gh<_i31.IHttpClient>()));
  gh.lazySingleton<_i172.IFileUploadRepository>(() =>
      _i362.FileUploadRepositoryImpl(
          dataSource: gh<_i145.IFileUploadDataSource>()));
  gh.lazySingleton<_i317.UploadFileUseCase>(
      () => _i317.UploadFileUseCase(gh<_i172.IFileUploadRepository>()));
  gh.lazySingleton<_i920.IAiChatRepository>(
      () => _i1065.AiChatRepositoryImpl(gh<_i748.IAiChatRemoteDataSource>()));
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
  return getIt;
}
