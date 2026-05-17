import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dskk_flutter_refactor/core/auth/id_resolver.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:get_it/get_it.dart';

import '../presentation/bloc/ai_chat/ai_chat_bloc.dart';
import '../domain/usecases/get_conversations_usecase.dart';
import '../domain/usecases/load_history_usecase.dart';
import '../domain/usecases/create_conversation_usecase.dart';
import '../domain/usecases/delete_conversation_usecase.dart';
import '../domain/usecases/stream_chat_completion_usecase.dart';
import '../domain/usecases/upload_file_usecase.dart';
import '../domain/usecases/get_related_services_usecase.dart';
import '../domain/usecases/allocate_chat_resource_usecase.dart';
import '../domain/usecases/get_dispatch_history_usecase.dart';
import '../domain/usecases/transcribe_audio_usecase.dart';
import '../domain/usecases/cancel_chat_generation_usecase.dart';
import '../domain/usecases/optimized_allocation_usecase.dart';
import '../domain/usecases/update_conversation_title_usecase.dart';
import '../domain/usecases/generate_conversation_title_usecase.dart';
import '../domain/repositories/i_ai_chat_repository.dart';
import '../domain/repositories/i_file_upload_repository.dart';
import '../data/repositories/ai_chat_repository_impl.dart';
import '../data/datasources/i_ai_chat_remote_data_source.dart';
import '../data/datasources/ai_chat_remote_data_source_impl.dart';
import '../data/datasources/i_file_upload_data_source.dart';
import '../data/datasources/ai_docs_file_upload_data_source_impl.dart';
import '../data/repositories/ai_docs_file_upload_repository_impl.dart';
import '../../../core/network/i_http_client.dart';
import '../../../features/chat/domain/usecases/create_chat_room.dart';
import '../../../features/chat/domain/repositories/i_chat_repository.dart';

/// AI文档模块的依赖注入类
class AiDocsDI {
  /// 初始化AI文档模块的所有依赖
  static Future<void> init(GetIt getIt) async {
    AppLogger.d('[AiDocsDI] Initializing AI Docs module dependencies');

    // 数据源
    if (!getIt.isRegistered<IAiChatRemoteDataSource>()) {
      getIt.registerLazySingleton<IAiChatRemoteDataSource>(
        () => AiChatRemoteDataSourceImpl(getIt<IHttpClient>()),
      );
      AppLogger.d('[AiDocsDI] Registered IAiChatRemoteDataSource');
    }
    
    // 文件上传数据源
    if (!getIt.isRegistered<IFileUploadDataSource>(instanceName: 'ai_docs_file_upload_data_source')) {
      getIt.registerLazySingleton<IFileUploadDataSource>(
        () => AiDocsFileUploadDataSourceImpl(getIt<IHttpClient>()),
        instanceName: 'ai_docs_file_upload_data_source'
      );
      AppLogger.d('[AiDocsDI] Registered AiDocsFileUploadDataSourceImpl as ai_docs_file_upload_data_source');
    } else {
      AppLogger.d('[AiDocsDI] Instance named ai_docs_file_upload_data_source for IFileUploadDataSource already registered.');
    }

    // 仓库
    if (!getIt.isRegistered<IAiChatRepository>()) {
      getIt.registerLazySingleton<IAiChatRepository>(
        () => AiChatRepositoryImpl(
          remoteDataSource: getIt<IAiChatRemoteDataSource>(),
        ),
      );
      AppLogger.d('[AiDocsDI] Registered IAiChatRepository');
    }
    
    // 文件上传仓库
    if (!getIt.isRegistered<IFileUploadRepository>(instanceName: 'ai_docs_file_upload_repository')) {
      getIt.registerLazySingleton<IFileUploadRepository>(
        () => AiDocsFileUploadRepositoryImpl(
          dataSource: getIt<IFileUploadDataSource>(instanceName: 'ai_docs_file_upload_data_source'),
        ),
        instanceName: 'ai_docs_file_upload_repository'
      );
      AppLogger.d('[AiDocsDI] Registered AiDocsFileUploadRepositoryImpl as ai_docs_file_upload_repository');
    } else {
      AppLogger.d('[AiDocsDI] Instance named ai_docs_file_upload_repository for IFileUploadRepository already registered.');
    }

    // 用例
    if (!getIt.isRegistered<GetConversationsUseCase>()) {
      getIt.registerLazySingleton<GetConversationsUseCase>(
        () => GetConversationsUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered GetConversationsUseCase');
    }

    if (!getIt.isRegistered<LoadHistoryUseCase>()) {
      getIt.registerLazySingleton<LoadHistoryUseCase>(
        () => LoadHistoryUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered LoadHistoryUseCase');
    }

    if (!getIt.isRegistered<CreateConversationUseCase>()) {
      getIt.registerLazySingleton<CreateConversationUseCase>(
        () => CreateConversationUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered CreateConversationUseCase');
    }

    if (!getIt.isRegistered<DeleteConversationUseCase>()) {
      getIt.registerLazySingleton<DeleteConversationUseCase>(
        () => DeleteConversationUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered DeleteConversationUseCase');
    }

    if (!getIt.isRegistered<StreamChatCompletionUseCase>()) {
      getIt.registerLazySingleton<StreamChatCompletionUseCase>(
        () => StreamChatCompletionUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered StreamChatCompletionUseCase');
    }

    if (!getIt.isRegistered<UploadFileUseCase>()) {
      getIt.registerLazySingleton<UploadFileUseCase>(
        () => UploadFileUseCase(getIt<IFileUploadRepository>(instanceName: 'ai_docs_file_upload_repository')),
      );
      AppLogger.d('[AiDocsDI] Registered UploadFileUseCase with AI Docs specific repository');
    } else {
      AppLogger.d('[AiDocsDI] UploadFileUseCase already registered.');
    }

    if (!getIt.isRegistered<GetRelatedServicesUseCase>()) {
      getIt.registerLazySingleton<GetRelatedServicesUseCase>(
        () => GetRelatedServicesUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered GetRelatedServicesUseCase');
    }

    if (!getIt.isRegistered<GetDispatchHistoryUseCase>()) {
      getIt.registerLazySingleton<GetDispatchHistoryUseCase>(
        () => GetDispatchHistoryUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered GetDispatchHistoryUseCase');
    }

    if (!getIt.isRegistered<AllocateChatResourceUseCase>()) {
      getIt.registerLazySingleton<AllocateChatResourceUseCase>(
        () => AllocateChatResourceUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered AllocateChatResourceUseCase');
    }

    if (!getIt.isRegistered<TranscribeAudioUseCase>()) {
      getIt.registerLazySingleton<TranscribeAudioUseCase>(
        () => TranscribeAudioUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered TranscribeAudioUseCase');
    }

    if (!getIt.isRegistered<CancelChatGenerationUseCase>()) {
      getIt.registerLazySingleton<CancelChatGenerationUseCase>(
        () => CancelChatGenerationUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered CancelChatGenerationUseCase');
    }

    if (!getIt.isRegistered<OptimizedAllocationUseCase>()) {
      getIt.registerLazySingleton<OptimizedAllocationUseCase>(
        () => OptimizedAllocationUseCase(
          getIt<IAiChatRepository>(),
          getIt<IChatRepository>(),
          getIt<CreateChatRoom>(),
        ),
      );
      AppLogger.d('[AiDocsDI] Registered OptimizedAllocationUseCase');
    }

    if (!getIt.isRegistered<UpdateConversationTitleUseCase>()) {
      getIt.registerLazySingleton<UpdateConversationTitleUseCase>(
        () => UpdateConversationTitleUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered UpdateConversationTitleUseCase');
    }

    if (!getIt.isRegistered<GenerateConversationTitleUseCase>()) {
      getIt.registerLazySingleton<GenerateConversationTitleUseCase>(
        () => GenerateConversationTitleUseCase(getIt<IAiChatRepository>()),
      );
      AppLogger.d('[AiDocsDI] Registered GenerateConversationTitleUseCase');
    }

    // Bloc
    if (!getIt.isRegistered<AiChatBloc>()) {
      getIt.registerFactory<AiChatBloc>(() => AiChatBloc(
            getIt<GetConversationsUseCase>(),
            getIt<LoadHistoryUseCase>(),
            getIt<CreateConversationUseCase>(),
            getIt<DeleteConversationUseCase>(),
            getIt<StreamChatCompletionUseCase>(),
            getIt<UploadFileUseCase>(),
            getIt<GetRelatedServicesUseCase>(),
            getIt<AllocateChatResourceUseCase>(),
            getIt<GetDispatchHistoryUseCase>(),
            getIt<TranscribeAudioUseCase>(),
            getIt<CancelChatGenerationUseCase>(),
            getIt<OptimizedAllocationUseCase>(),
            getIt<UpdateConversationTitleUseCase>(),
            getIt<GenerateConversationTitleUseCase>(),
            getIt<IAiChatRemoteDataSource>(),
            getIt<FlutterSecureStorage>(),
            getIt<IdResolver>(),
          ));
      AppLogger.d('[AiDocsDI] Registered AiChatBloc');
    } else {
      AppLogger.d('[AiDocsDI] AiChatBloc already registered, skipping');
    }

    AppLogger.d('[AiDocsDI] AI Docs module dependencies initialized');
  }
} 