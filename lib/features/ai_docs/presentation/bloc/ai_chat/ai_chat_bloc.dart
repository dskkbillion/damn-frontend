import 'dart:async';
import 'package:dskk_flutter_refactor/core/auth/id_resolver.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:io';
// For jsonDecode in stream handling
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Secure Storage
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/utils/haptic_utils.dart'; // 导入震动工具类


// Core
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Use package import

// Domain Layer - Use package imports
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_conversation_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/allocated_item_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/allocate_chat_resource_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_dispatch_history_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/create_conversation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/delete_conversation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_conversations_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_related_services_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/load_history_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/stream_chat_completion_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/upload_file_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/cancel_chat_generation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/optimized_allocation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/update_conversation_title_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/generate_conversation_title_usecase.dart';

// Data source import for rate limit access
import 'package:dskk_flutter_refactor/features/ai_docs/data/datasources/i_ai_chat_remote_data_source.dart';

// Move Exports Before Parts - Use package imports
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_conversation_entity.dart'; 
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart'; 
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart';
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/allocated_item_entity.dart'; 

// Parts (No Duplicates)
part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

/// {@template ai_chat_bloc}
/// Bloc responsible for managing the state of the AI chat interface.
/// {@endtemplate}
@injectable
class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {

  // --- Use Cases Dependencies ---
  final GetConversationsUseCase _getConversations;
  final LoadHistoryUseCase _loadHistory;
  final CreateConversationUseCase _createConversation;
  final DeleteConversationUseCase _deleteConversation;
  final StreamChatCompletionUseCase _streamChatCompletion;
  final UploadFileUseCase _uploadFile;
  final GetRelatedServicesUseCase _getRelatedServices;
  final AllocateChatResourceUseCase _allocateChatResource;
  final GetDispatchHistoryUseCase _getDispatchHistory;
  // #368 deleted TranscribeAudioUseCase field — omni 直接理解音频 (#360)
  final CancelChatGenerationUseCase _cancelChatGeneration;
  final OptimizedAllocationUseCase _optimizedAllocation;
  final UpdateConversationTitleUseCase _updateConversationTitle;
  final GenerateConversationTitleUseCase _generateConversationTitle;

  // --- Data Source for Rate Limit Access ---
  final IAiChatRemoteDataSource _remoteDataSource;

  // --- Inject Secure Storage ---
  final FlutterSecureStorage _storage;

  // --- ID 语义解析 (#358) ---
  final IdResolver _idResolver;

  // Internal state - Replace with state properties where possible
  // int? _currentConversationId; // REMOVE - Use state.selectedConversationId instead
  StreamSubscription<String>? _chatStreamSubscription;
  


  AiChatBloc(
    this._getConversations,
    this._loadHistory,
    this._createConversation,
    this._deleteConversation,
    this._streamChatCompletion,
    this._uploadFile,
    this._getRelatedServices,
    this._allocateChatResource,
    this._getDispatchHistory,
    this._cancelChatGeneration,
    this._optimizedAllocation,
    this._updateConversationTitle,
    this._generateConversationTitle,
    this._remoteDataSource, // Add data source to constructor
    this._storage, // Add storage to constructor
    this._idResolver, // #358 ID 语义解析
    // Start with initial state containing defaults for new properties
  ) : super(const AiChatState()) {
    // --- Register event handlers ---
    // Conversation List Management
    on<LoadConversations>(_onLoadConversations);
    on<LoadMoreConversations>(_onLoadMoreConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<SelectConversation>(_onSelectConversation);
    on<CreateNewConversation>(_onCreateNewConversation);
    on<DeleteSelectedConversation>(_onDeleteSelectedConversation);
    on<CreateNewConversationAndSendMessage>(_onCreateNewConversationAndSendMessage);
    on<CreateNewConversationAndSendVoiceMessage>(_onCreateNewConversationAndSendVoiceMessage);
    // Pagination Events - 新增
    on<LoadMoreHistory>(_onLoadMoreHistory);
    on<ScrollToBottom>(_onScrollToBottom);
    // Image Handling
    on<PickImage>(_onPickImage);
    on<_ImageUploadSuccess>(_onImageUploadSuccess);
    on<_ImageUploadFailure>(_onImageUploadFailure);
    // Chat Interactions
    on<SendMessage>(_onSendMessage);
    on<SendVoiceMessage>(_onSendVoiceMessage); 
    on<CancelStreaming>(_onCancelStreaming); 
    on<CancelChatGeneration>(_onCancelChatGeneration);
    on<FetchRecommendations>(_onFetchRecommendations);
    on<FetchDispatchHistory>(_onFetchDispatchHistory);
    on<TriggerAllocationAction>(_onTriggerAllocationAction); 
    on<TriggerOptimizedAllocation>(_onTriggerOptimizedAllocation);
    // Internal Stream Handling
    on<_ReceiveStreamChunk>(_onReceiveStreamChunk); 
    on<_HandleStreamError>(_onHandleStreamError); 
    on<_HandleStreamDone>(_onHandleStreamDone); 
    // Image Handling - Add handler for removal
    on<RemovePendingImage>(_onRemovePendingImage);
    // Title Operations
    on<UpdateConversationTitle>(_onUpdateConversationTitle);
    on<GenerateConversationTitle>(_onGenerateConversationTitle);
    // Rate Limit Operations
    on<FetchRateLimitStatus>(_onFetchRateLimitStatus);
    on<ResetRateLimit>(_onResetRateLimit);
  }

  // --- Helper to get current user ID (common_user_id) ---
  // ID 解析 — 走 IdResolver,不再直接 read storage(#358)
  // 见 docs/dev/id_schema_cn.md §2 跨端契约清单
  Future<int?> _getCurrentUserId() => _idResolver.commonUserId();
  Future<int?> _getMemberUserId() => _idResolver.memberIdForBackend();

  // --- Conversation List Handlers ---

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<AiChatState> emit,
  ) async {
     AppLogger.d("[AiChatBloc] _onLoadConversations triggered.");
     
     // 重置分页状态并设置加载状态
     emit(state.copyWith(
       conversationsStatus: ConversationsStatus.loading,
       isLoadingMoreConversations: false,
       conversationsCurrentPage: 1,
       conversationsHasMore: true,
     ));
     
     final userId = await _getCurrentUserId();
     AppLogger.d("[AiChatBloc] _onLoadConversations: Retrieved userId = $userId");

     if (userId == null) {
       AppLogger.d("[AiChatBloc] _onLoadConversations: userId is null. Emitting error.");
       emit(state.copyWith(conversationsStatus: ConversationsStatus.error, conversationListErrorMessage: "User not authenticated or invalid ID format"));
       return;
     }

     AppLogger.d("[AiChatBloc] _onLoadConversations: Calling _getConversations with userId: $userId");
     // 使用事件提供的页码或默认第1页
     final page = event.page ?? 1;
     final result = await _getConversations(GetConversationsParams(userId: userId, page: page)); 
     AppLogger.d("[AiChatBloc] _onLoadConversations: _getConversations result: $result");

     result.fold(
       (failure) {
         AppLogger.d("[AiChatBloc] _onLoadConversations: Failure - $failure. Emitting error state.");
         emit(state.copyWith(
             conversationsStatus: ConversationsStatus.error,
             conversationListErrorMessage: failure.toString(),
          ));
       },
       (conversationsResult) {
         AppLogger.d("[AiChatBloc] _onLoadConversations: Success - Received ${conversationsResult.conversations.length} conversations. Emitting loaded state.");
         emit(state.copyWith(
             conversationsStatus: ConversationsStatus.loaded,
             conversations: conversationsResult.conversations,
             conversationsCurrentPage: conversationsResult.currentPage,
             conversationsTotalPages: conversationsResult.totalPages,
             totalConversationsCount: conversationsResult.totalConversations,
             conversationsHasMore: conversationsResult.hasMore,
             clearConversationListErrorMessage: true,
         ));
       },
     );
     // Log the final emitted state for debugging
     AppLogger.d("[AiChatBloc] _onLoadConversations: Final emitted state status = ${state.conversationsStatus}, count = ${state.conversations.length}"); 
  }

  Future<void> _onLoadMoreConversations(
    LoadMoreConversations event,
    Emitter<AiChatState> emit,
  ) async {
    // 防止重复加载
    if (state.isLoadingMoreConversations || !state.conversationsHasMore) {
      AppLogger.d("[AiChatBloc] LoadMoreConversations ignored: isLoading=${state.isLoadingMoreConversations}, hasMore=${state.conversationsHasMore}");
      return;
    }

    AppLogger.d("[AiChatBloc] Loading more conversations, current page: ${state.conversationsCurrentPage}");
    
    emit(state.copyWith(isLoadingMoreConversations: true));
    
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        isLoadingMoreConversations: false,
        conversationsStatus: ConversationsStatus.error, 
        conversationListErrorMessage: 'User not authenticated or invalid ID format'
      ));
      return;
    }

    // 计算要加载的页码
    final nextPage = event.page ?? (state.conversationsCurrentPage + 1);
    
    final result = await _getConversations(GetConversationsParams(
      userId: userId, 
      page: nextPage
    ));

    result.fold(
      (failure) {
        AppLogger.d("[AiChatBloc] LoadMoreConversations failed: $failure");
        emit(state.copyWith(
          isLoadingMoreConversations: false,
          conversationsStatus: ConversationsStatus.error,
          conversationListErrorMessage: 'Failed to load more conversations: ${failure.toString()}',
        ));
      },
      (conversationsResult) {
        AppLogger.d("[AiChatBloc] LoadMoreConversations success: loaded ${conversationsResult.conversations.length} conversations");
        
        // 将新对话插入到现有列表
        final allConversations = <AiConversationEntity>[];
        allConversations.addAll(state.conversations);
        allConversations.addAll(conversationsResult.conversations);
        
        emit(state.copyWith(
          isLoadingMoreConversations: false,
          conversations: allConversations,
          conversationsHasMore: conversationsResult.hasMore,
          conversationsCurrentPage: nextPage,
          conversationsTotalPages: conversationsResult.totalPages,
          totalConversationsCount: conversationsResult.totalConversations,
          conversationsStatus: ConversationsStatus.loaded,
        ));
      },
    );
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<AiChatState> emit,
  ) async {
    AppLogger.d("[AiChatBloc] Refreshing conversations");
    
    // 刷新时重置到第一页
    add(const LoadConversations(page: 1));
  }

   Future<void> _onSelectConversation(
    SelectConversation event,
    Emitter<AiChatState> emit,
  ) async {
    // If same conversation selected, do nothing (or maybe reload history?)
    if (state.selectedConversationId == event.conversationId) return;

    AppLogger.d("[AiChatBloc] Selecting conversation: ${event.conversationId}");

    // Immediately update selected ID and clear messages/status for the main chat area
    emit(state.copyWith(
      selectedConversationIdOrNull: event.conversationId,
      status: AiChatStatus.loadingHistory, // Indicate history loading for main area
      messages: [], // Clear previous messages
      recommendations: [], // Clear related services
      streamingResponseText: '', // Clear generation
      clearErrorMessage: true, // Clear main chat area error
      // 重置分页状态
      currentPage: 1,
      totalPages: 0,
      totalMessages: 0,
      hasMoreHistory: true,
      isLoadingMoreHistory: false,
    ));

    // Load history for the selected conversation using new pagination
    final userId = await _getCurrentUserId();
    if (userId == null) {
       emit(state.copyWith(
         status: AiChatStatus.historyLoadFailure, 
         errorMessage: 'User not authenticated or invalid ID format'
       ));
       return;
    }
    
    final historyResult = await _loadHistory(LoadHistoryParams(
      conversationId: event.conversationId,
      userId: userId,
      page: 1, // 从第一页开始
      pageSize: 50,
      orderBy: 'desc', // 最新消息在前
    ));

    historyResult.fold(
      (failure) {
        AppLogger.d("[AiChatBloc] Failed to load history: $failure");
        emit(state.copyWith(
          status: AiChatStatus.historyLoadFailure, // Update main area status
          errorMessage: 'Failed to load history: ${failure.toString()}',
        ));
      },
      (historyData) {
        AppLogger.d("[AiChatBloc] Loaded ${historyData.messages.length} messages for conversation ${event.conversationId}");
        
        // 由于orderBy='desc'，需要反转消息顺序以保持时间正序显示
        final orderedMessages = historyData.messages.reversed.toList();
        
        emit(state.copyWith(
          status: AiChatStatus.historyLoadSuccess, // Update main area status
          messages: orderedMessages,
          hasMoreHistory: historyData.hasMore,
          currentPage: 1,
          totalPages: historyData.totalPages,
          totalMessages: historyData.totalMessages,
          // 加载完成后触发滚动到底部
          shouldScrollToBottom: true,
          // 切到新会话时清空旧历史,触发 AppBar 按钮状态刷新
          clearDispatchHistory: true,
          dispatchHistoryStatus: DispatchHistoryStatus.initial,
        ));

        // 立即重置滚动标志
        emit(state.copyWith(shouldScrollToBottom: false));

        // #347 异步拉取本会话的已分发历史,驱动 AppBar 按钮空/置灰状态
        add(FetchDispatchHistory());
      },
    );
  }

  Future<void> _onCreateNewConversation(
    CreateNewConversation event,
    Emitter<AiChatState> emit,
  ) async {
     // Indicate loading in the conversation list sidebar
     emit(state.copyWith(conversationsStatus: ConversationsStatus.loading)); 
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(conversationsStatus: ConversationsStatus.error, conversationListErrorMessage: 'User not authenticated or invalid ID format'));
      return;
    }
    final result = await _createConversation(CreateConversationParams(userId: userId, title: event.title));

    result.fold(
      (failure) => emit(state.copyWith(
        conversationsStatus: ConversationsStatus.error,
        conversationListErrorMessage: 'Failed to create conversation: ${failure.toString()}',
      )),
      (newConversationId) {
        // Successfully created, now select it and clear main chat area
        emit(state.copyWith(
          conversationsStatus: ConversationsStatus.loaded, // List status back to loaded (will be updated by LoadConversations)
          selectedConversationIdOrNull: newConversationId,
          status: AiChatStatus.historyLoadSuccess, // Set main area status to success (no history yet)
          messages: [], // Clear previous messages
          streamingResponseText: '', // Clear any streaming text
          recommendations: [], // Clear related services
          clearErrorMessage: true, // Clear main chat area error
        ));

        // Reload the conversation list to show the new conversation
        add(const LoadConversations()); 
      },
    );
  }

  Future<void> _onCreateNewConversationAndSendMessage(
    CreateNewConversationAndSendMessage event,
    Emitter<AiChatState> emit,
  ) async {
     // 设置状态为创建对话中
     emit(state.copyWith(conversationsStatus: ConversationsStatus.loading)); 
     
     // 获取用户ID
     final userId = await _getCurrentUserId();
     if (userId == null) {
       emit(state.copyWith(
         conversationsStatus: ConversationsStatus.error, 
         conversationListErrorMessage: '用户未认证或ID格式无效'
       ));
       return;
     }
     
     // 创建新对话
     final result = await _createConversation(CreateConversationParams(userId: userId));
     
     await result.fold(
       (failure) {
         // 创建对话失败
         emit(state.copyWith(
           conversationsStatus: ConversationsStatus.error,
           conversationListErrorMessage: '创建对话失败: ${failure.toString()}',
         ));
       },
       (newConversationId) async {
         // 创建对话成功，设置为当前选中的对话
         emit(state.copyWith(
           conversationsStatus: ConversationsStatus.loaded,
           selectedConversationIdOrNull: newConversationId,
           status: AiChatStatus.historyLoadSuccess, // 设置为历史加载成功状态
           messages: [], // 清空消息列表
           streamingResponseText: '', // 清空流式响应文本
           recommendations: [], // 清空推荐服务
           clearErrorMessage: true, // 清除错误消息
         ));
         
         // 重新加载对话列表
         add(const LoadConversations());
         
         // 立即发送消息
         add(SendMessage(message: event.message));
       },
     );
  }

  Future<void> _onCreateNewConversationAndSendVoiceMessage(
    CreateNewConversationAndSendVoiceMessage event,
    Emitter<AiChatState> emit,
  ) async {
     // 设置状态为创建对话中
     emit(state.copyWith(conversationsStatus: ConversationsStatus.loading)); 
     
     // 获取用户ID
     final userId = await _getCurrentUserId();
     if (userId == null) {
       emit(state.copyWith(
         conversationsStatus: ConversationsStatus.error, 
         conversationListErrorMessage: '用户未认证或ID格式无效'
       ));
       return;
     }
     
     // 创建新对话
     final result = await _createConversation(CreateConversationParams(userId: userId));
     
     await result.fold(
       (failure) {
         // 创建对话失败
         emit(state.copyWith(
           conversationsStatus: ConversationsStatus.error,
           conversationListErrorMessage: '创建对话失败: ${failure.toString()}',
         ));
       },
       (newConversationId) async {
         // 创建对话成功，设置为当前选中的对话
         emit(state.copyWith(
           conversationsStatus: ConversationsStatus.loaded,
           selectedConversationIdOrNull: newConversationId,
           status: AiChatStatus.historyLoadSuccess, // 设置为历史加载成功状态
           messages: [], // 清空消息列表
           streamingResponseText: '', // 清空流式响应文本
           recommendations: [], // 清空推荐服务
           clearErrorMessage: true, // 清除错误消息
         ));
         
         // 重新加载对话列表
         add(const LoadConversations());
         
         // 立即发送语音消息
         add(SendVoiceMessage(audioFile: event.audioFile));
      },
    );
  }

  Future<void> _onDeleteSelectedConversation(
    DeleteSelectedConversation event,
    Emitter<AiChatState> emit,
  ) async {
    // 使用传入的conversationId，如果没有则使用当前选中的
    final idToDelete = event.conversationId ?? state.selectedConversationId;
    if (idToDelete == null) return; // Nothing to delete

    // Indicate loading in the conversation list sidebar
    emit(state.copyWith(conversationsStatus: ConversationsStatus.loading));
    
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        conversationsStatus: ConversationsStatus.error, 
        conversationListErrorMessage: 'User not authenticated or invalid ID format'
      ));
      return;
    }
    
    final result = await _deleteConversation(DeleteConversationParams(
      conversationId: idToDelete, 
      userId: userId
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        conversationsStatus: ConversationsStatus.error,
        conversationListErrorMessage: 'Failed to delete conversation: ${failure.toString()}',
      )),
      (_) {
        // Successfully deleted
        // 只有当删除的是当前选中的对话时，才清空主聊天区域
        if (state.selectedConversationId == idToDelete) {
          emit(state.copyWith(
            selectedConversationIdOrNull: null, // Clear selection
            status: AiChatStatus.initial, // Reset main chat status
            messages: [], 
            recommendations: [],
            streamingResponseText: '',
            clearErrorMessage: true,
          ));
        }
        // 如果删除的不是当前选中的对话，保持当前状态不变
        
        // Refresh conversation list to remove the deleted one
        add(const LoadConversations()); 
      },
    );
  }

  // --- 分页处理方法 ---
  
  Future<void> _onLoadMoreHistory(
    LoadMoreHistory event,
    Emitter<AiChatState> emit,
  ) async {
    // 防止重复加载
    if (state.isLoadingMoreHistory || !state.hasMoreHistory) {
      AppLogger.d("[AiChatBloc] LoadMoreHistory ignored: isLoading=${state.isLoadingMoreHistory}, hasMore=${state.hasMoreHistory}");
      return;
    }

    final conversationId = state.selectedConversationId;
    if (conversationId == null) {
      AppLogger.d("[AiChatBloc] LoadMoreHistory ignored: no conversation selected");
      return;
    }

    AppLogger.d("[AiChatBloc] Loading more history for conversation $conversationId, current page: ${state.currentPage}");
    
    emit(state.copyWith(isLoadingMoreHistory: true));
    
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        isLoadingMoreHistory: false,
        status: AiChatStatus.historyLoadFailure, 
        errorMessage: 'User not authenticated or invalid ID format'
      ));
      return;
    }

    // 计算要加载的页码
    final nextPage = event.page ?? (state.currentPage + 1);
    
    final historyResult = await _loadHistory(LoadHistoryParams(
      conversationId: conversationId,
      userId: userId,
      page: nextPage,
      pageSize: 50, // 可以从配置中读取
      orderBy: 'desc', // 最新的在前面，但是我们要追加到列表前面
    ));

    historyResult.fold(
      (failure) {
        AppLogger.d("[AiChatBloc] LoadMoreHistory failed: $failure");
        emit(state.copyWith(
          isLoadingMoreHistory: false,
          status: AiChatStatus.historyLoadFailure,
          errorMessage: 'Failed to load more history: ${failure.toString()}',
        ));
      },
      (historyData) {
        AppLogger.d("[AiChatBloc] LoadMoreHistory success: loaded ${historyData.messages.length} messages");
        
        // 由于orderBy='desc'，新加载的消息需要插入到现有消息的前面
        // 但要保持时间顺序正确
        final newMessages = <AiChatMessageEntity>[];
        
        // 如果是第一页数据，直接使用
        if (state.messages.isEmpty) {
          newMessages.addAll(historyData.messages.reversed); // 反转以保持时间正序
        } else {
          // 不是第一页，将新消息插入到前面
          newMessages.addAll(historyData.messages.reversed);
          newMessages.addAll(state.messages);
        }
        
        emit(state.copyWith(
          isLoadingMoreHistory: false,
          messages: newMessages,
          hasMoreHistory: historyData.hasMore,
          currentPage: nextPage,
          totalPages: historyData.totalPages,
          totalMessages: historyData.totalMessages,
          status: AiChatStatus.historyLoadSuccess,
        ));
      },
    );
  }

  void _onScrollToBottom(ScrollToBottom event, Emitter<AiChatState> emit) {
    AppLogger.d("[AiChatBloc] ScrollToBottom triggered");
    emit(state.copyWith(shouldScrollToBottom: true));
    // 立即重置标志，避免重复触发
    emit(state.copyWith(shouldScrollToBottom: false));
  }

  // --- Image Handling Handlers ---

  Future<void> _onPickImage(
    PickImage event,
    Emitter<AiChatState> emit,
  ) async {
    final imageFile = event.imageFile;
    final imagePath = imageFile.path;

    // 1. Add image to pending list & set state to uploading
    final currentPending = List<File>.from(state.pendingImageFiles ?? []);
    // Avoid adding duplicates if user picks the same file again
    if (!currentPending.any((file) => file.path == imagePath)) {
      currentPending.add(imageFile);
    }
    // Create a mutable copy of the map
    final currentUploadStates = Map<String, ImageUploadState>.from(state.imageUploadStates ?? {}); 
    currentUploadStates[imagePath] = const ImageUploadState.uploading();

    emit(state.copyWith(
      pendingImageFiles: currentPending,
      imageUploadStates: currentUploadStates,
    ));

    // 2. Start background upload
    AppLogger.d("[Bloc] Starting upload for: $imagePath");
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: 'User not authenticated or invalid ID format'));
        return;
      }
      final uploadResult = await _uploadFile(UploadFileParams(file: imageFile));
      uploadResult.fold(
        (failure) {
          AppLogger.d("[Bloc] Upload failed for $imagePath: $failure");
          // Dispatch internal failure event using path
          add(_ImageUploadFailure(originalFilePath: imagePath, error: failure.toString()));
        },
        (url) {
          AppLogger.d("[Bloc] Upload success for $imagePath: $url");
          // Dispatch internal success event using path
          add(_ImageUploadSuccess(originalFilePath: imagePath, uploadedUrl: url));
        },
      );
    } catch (e) {
       AppLogger.d("[Bloc] Exception during upload for $imagePath: $e");
       add(_ImageUploadFailure(originalFilePath: imagePath, error: 'Upload exception: ${e.toString()}'));
    }
  }

  void _onImageUploadSuccess(
    _ImageUploadSuccess event,
    Emitter<AiChatState> emit,
  ) {
    // Update the state for the specific image path
    final currentUploadStates = Map<String, ImageUploadState>.from(state.imageUploadStates ?? {});
    // Check if the key exists before updating (it should, but good practice)
    if (currentUploadStates.containsKey(event.originalFilePath)) {
        currentUploadStates[event.originalFilePath] = ImageUploadState.success(event.uploadedUrl);
        emit(state.copyWith(imageUploadStates: currentUploadStates));
    } else {
        AppLogger.d("[Bloc] Warning: Received upload success for path not in state: ${event.originalFilePath}");
    }
  }

  void _onImageUploadFailure(
    _ImageUploadFailure event,
    Emitter<AiChatState> emit,
  ) {
    // Update the state for the specific image path
     final currentUploadStates = Map<String, ImageUploadState>.from(state.imageUploadStates ?? {});
     if (currentUploadStates.containsKey(event.originalFilePath)) {
        currentUploadStates[event.originalFilePath] = ImageUploadState.failure(event.error);
        emit(state.copyWith(imageUploadStates: currentUploadStates));
     } else {
        AppLogger.d("[Bloc] Warning: Received upload failure for path not in state: ${event.originalFilePath}");
     }
     AppLogger.d("Image upload failed for ${event.originalFilePath}: ${event.error}");
  }

  // Updated handler for removing a pending image using path
  void _onRemovePendingImage(
    RemovePendingImage event,
    Emitter<AiChatState> emit,
  ) {
    final imagePathToRemove = event.imagePathToRemove;
    
    // Remove from pending files list
    final currentPending = List<File>.from(state.pendingImageFiles ?? []);
    currentPending.removeWhere((file) => file.path == imagePathToRemove);
    
    // Remove from upload states map
    final currentUploadStates = Map<String, ImageUploadState>.from(state.imageUploadStates ?? {});
    currentUploadStates.remove(imagePathToRemove);

    emit(state.copyWith(
      pendingImageFiles: currentPending,
      imageUploadStates: currentUploadStates,
    ));

    AppLogger.d("[Bloc] Removed pending image: $imagePathToRemove");
    // TODO: Consider cancelling ongoing upload task if needed
  }

  // --- Chat Interaction Handlers (Updated) ---

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiChatState> emit,
  ) async {
    final currentConversationId = state.selectedConversationId;
    if (currentConversationId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: "No conversation selected"));
      return;
    }
    if (state.status == AiChatStatus.streamingResponse) {
      AppLogger.d("Cannot send message while streaming");
      return;
    }

    // --- 检查是否有内容可发送（文本或图片） --- 
    final hasText = event.message.trim().isNotEmpty;
    final hasPendingImages = state.pendingImageFiles?.isNotEmpty == true;
    
    if (!hasText && !hasPendingImages) {
        AppLogger.d("Cannot send empty message (no text and no images).");
        // Optionally show snackbar feedback from here or rely on UI logic
        return; 
    }

    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

    // 🎯 重置震动反馈计数器
    HapticUtils.resetStreamingFeedback();

    // --- Collect successfully uploaded image URLs for the CURRENT pending images ---
    final List<String> urlsToSend = [];
    final currentPendingPaths = state.pendingImageFiles?.map((f) => f.path).toList() ?? [];
    final currentUploadStates = state.imageUploadStates ?? {};

    for (final path in currentPendingPaths) {
      final uploadState = currentUploadStates[path];
      if (uploadState != null && uploadState.status == ImageUploadStatus.success) {
          // Ensure url is not null, though factory guarantees it for success state
          if (uploadState.url != null) { 
             urlsToSend.add(uploadState.url!); 
          } else {
             AppLogger.d("[Bloc] Warning: ImageUploadState.success for $path has null URL.");
          }
      } 
      // Ignore images that are uploading or failed
      else if (uploadState?.status == ImageUploadStatus.uploading) {
           AppLogger.d("[Bloc] Image still uploading, not included in message: $path");
      } else if (uploadState?.status == ImageUploadStatus.failure) {
           AppLogger.d("[Bloc] Image upload failed, not included in message: $path");
      }
    }

    // --- Add user message optimistically ---
    // 修复: AI聊天系统内部API需要使用common_user_id，而不是member.id
    // 因为对话、历史消息等都是用common_user_id创建和查询的
    // 只有推荐系统API才需要使用member.id (关联Product.tenant_id)
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: 'User not authenticated or invalid ID format'));
      return;
    }
    final userMessage = AiChatMessageEntity(
      messageId: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentConversationId,
      sender: MessageSender.user,
      content: event.message, // Use the text from the event
      timestamp: DateTime.now(),
      fileUrls: urlsToSend.isNotEmpty ? urlsToSend : null, 
      messageType: urlsToSend.isNotEmpty ? MessageType.image : MessageType.text,
    );

    // Emit state with user message added, waiting for response,
    // AND clear all pending image states as they've been processed for this message.
    emit(state.copyWith(
      status: AiChatStatus.waitingForResponse,
      messages: List.from(state.messages)..add(userMessage),
      streamingResponseText: '',
      clearPendingImages: true, // Clear the list of files
      clearImageUploadStates: true, // Clear the map of upload states
    ));
    // --- End of optimistic UI update & state cleanup ---

    // --- Cancel previous stream subscription if any ---
    await _chatStreamSubscription?.cancel();
    _chatStreamSubscription = null;
    // Note: streamingResponseText is already cleared above
    // --- End of cancellation ---

    // --- Initiate the actual streaming call --- 
    final streamResult = await _streamChatCompletion(StreamChatCompletionParams(
      conversationId: currentConversationId,
      userId: userId,
      message: event.message,
      fileUrls: urlsToSend, // Pass ONLY the successfully uploaded URLs
    ));

    streamResult.fold(
      (failure) {
        // Handle error initiating the stream
        AppLogger.d("[Bloc] Error initiating stream: $failure");
        emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: failure.toString()));
        // Note: Image state was already cleared optimistically. Consider if rollback is needed.
      },
      (contentStream) {
        // Successfully initiated stream, start listening
        AppLogger.d("[Bloc] Stream initiated successfully. Listening...");
        

        
        emit(state.copyWith(
          status: AiChatStatus.streamingResponse,
        )); // Update status
        
        _chatStreamSubscription = contentStream.listen(
          (chunk) {
            if (isClosed) return;
            AppLogger.d("[Bloc] Received stream chunk: '$chunk'");
            add(_ReceiveStreamChunk(chunk));
          },
          onError: (error) {
            if (isClosed) return;
            AppLogger.d("[Bloc] Stream error: $error");
            add(_HandleStreamError(error.toString()));
            _chatStreamSubscription = null;
          },
          onDone: () {
            if (isClosed) return;
            AppLogger.d("[Bloc] Stream completed");
            add(const _HandleStreamDone());
             _chatStreamSubscription = null;
          },
        );
      },
    );
     // --- End of stream initiation --- 
  }

  Future<void> _onSendVoiceMessage(
    SendVoiceMessage event,
    Emitter<AiChatState> emit,
  ) async {
    // 1. 获取基础信息
    // 修复: AI聊天系统内部API需要使用common_user_id，而不是member.id
    // 因为对话、历史消息等都是用common_user_id创建和查询的
    // 只有推荐系统API才需要使用member.id (关联Product.tenant_id)
    final userId = await _getCurrentUserId();
    final currentConversationId = state.selectedConversationId;

    if (userId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: '用户ID未找到，无法上传音频'));
      return;
    }
    
    if (currentConversationId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: '请先选择一个对话'));
      return;
    }

    // 2. 立即创建并显示语音消息（转录中状态）
    final tempVoiceMessageId = 'temp_voice_${DateTime.now().millisecondsSinceEpoch}';
    final voiceMessage = AiChatMessageEntity(
      messageId: tempVoiceMessageId,
      conversationId: currentConversationId,
      sender: MessageSender.user,
      content: "转录中...", // 初始显示转录中
      messageType: MessageType.audio, // 明确设置为音频类型
      timestamp: DateTime.now(),
      fileUrls: null, // 转录中时先不设置URL
      isTranscribing: true, // 设置转录中状态
    );
    
    final currentMessages = List<AiChatMessageEntity>.from(state.messages);
    currentMessages.add(voiceMessage);
    
    // 3. 设置转录中状态，显示语音消息
    emit(state.copyWith(
      status: AiChatStatus.transcribingAudio,
      messages: currentMessages,
      clearErrorMessage: true,
    ));

    // 4. 上传音频文件
    final fileSize = await event.audioFile.length();
    AppLogger.d('准备上传的音频文件大小: ${fileSize / 1024} KB, 路径: ${event.audioFile.path}');
    
    // 添加重试逻辑
    int retryCount = 0;
    const maxRetries = 2;
    late Either<Failure, String> uploadResult;
    
    while (retryCount <= maxRetries) {
      if (retryCount > 0) {
        AppLogger.d('正在重试音频上传 ($retryCount/$maxRetries)...');
        // 在重试时不改变消息状态，保持转录中状态
        await Future.delayed(const Duration(seconds: 1));
      }
      
      try {
        uploadResult = await _uploadFile(UploadFileParams(file: event.audioFile));
        if (uploadResult.isRight()) {
          break;
        } else {
          final failure = uploadResult.fold((failure) => failure, (_) => null);
          if (failure.toString().contains('系统请求超时') || 
              failure.toString().contains('timeout') ||
              failure.toString().contains('500')) {
            retryCount++;
            continue;
          } else {
            break;
          }
        }
      } catch (e) {
        uploadResult = Left(GeneralFailure(message: e.toString()));
        retryCount++;
        continue;
      }
    }

    await uploadResult.fold(
      // 5. 上传失败
      (failure) async {
        AppLogger.d('音频上传失败: $failure');
        
        // 更新消息状态为上传失败
        final updatedMessages = state.messages.map((msg) {
          if (msg.messageId == tempVoiceMessageId) {
            return msg.copyWith(
              content: '[语音上传失败]',
              isTranscribing: false,
            );
          }
          return msg;
        }).toList();
        
        String errorMessage;
        if (failure.toString().contains('系统请求超时') || failure.toString().contains('timeout')) {
          errorMessage = '上传超时，请尝试录制更短的语音';
        } else if (failure.toString().contains('500')) {
          errorMessage = '服务器错误，请稍后再试';
        } else {
          errorMessage = '上传失败: ${failure.toString()}';
        }
        
        emit(state.copyWith(
          status: AiChatStatus.messageSendFailure,
          messages: updatedMessages,
          errorMessage: errorMessage,
        ));
      },
      // 6. 上传成功 — omni 直接理解音频 (#360 + #368)
      (audioOssUrl) async {
        AppLogger.d('音频上传成功，URL: $audioOssUrl');

        // #368 直接走 omni 路径, 前端不再调 /model/chat/audio (ASR endpoint 2026-06-04 下线)
        // content 默认 '[语音消息]' 占位符。#371 实施后由后端 SSE 回写真实 transcript
        final updatedMessages = state.messages.map((msg) {
          if (msg.messageId == tempVoiceMessageId) {
            return msg.copyWith(
              content: '[语音消息]',
              fileUrls: [audioOssUrl],
              messageType: MessageType.audio,
              isTranscribing: false,
            );
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          status: AiChatStatus.sendingMessage,
          messages: updatedMessages,
          clearErrorMessage: true,
        ));

        AppLogger.d('[#368] omni 直接处理音频, 不再 ASR 预转录');
        await _sendVoiceToBackend(currentConversationId, userId, audioOssUrl, null, emit);
      },
    );
  }

  // 新增辅助方法：发送语音消息到后端
  Future<void> _sendVoiceToBackend(
    int conversationId,
    int userId,
    String audioUrl,
    String? transcription,
    Emitter<AiChatState> emit,
  ) async {
    final streamResult = await _streamChatCompletion(StreamChatCompletionParams(
      conversationId: conversationId,
      userId: userId,
      message: transcription ?? '[语音消息]',
      fileUrls: const [],
      audioUrls: [audioUrl],
      transcription: transcription,
    ));
    
    streamResult.fold(
      (failure) {
        AppLogger.d('音频消息发送失败: $failure');
        emit(state.copyWith(
          status: AiChatStatus.messageSendFailure,
          errorMessage: '音频消息发送失败: ${failure.toString()}',
        ));
      },
      (contentStream) {
        AppLogger.d('音频消息发送成功，开始AI响应');
        emit(state.copyWith(status: AiChatStatus.streamingResponse));
        
        _chatStreamSubscription = contentStream.listen(
          (chunk) { if (!isClosed) add(_ReceiveStreamChunk(chunk)); },
          onError: (error) { if (!isClosed) add(_HandleStreamError(error.toString())); },
          onDone: () { if (!isClosed) add(const _HandleStreamDone()); },
        );
      },
    );
  }

  // --- Internal Stream Handlers (Updated) ---
  void _onReceiveStreamChunk(_ReceiveStreamChunk event, Emitter<AiChatState> emit) {
    AppLogger.d("[AiChatBloc] 收到流式数据块: ${event.chunk}");
    
    // 检查是否是特殊控制标记
    final chunk = event.chunk.trim();
    
    // 处理跳过用户消息显示的标识
    if (chunk == '[SKIP_USER_MESSAGE]') {
      AppLogger.d("[AiChatBloc] 收到跳过用户消息显示标识");
      // 对于语音消息，我们已经在前端显示了语音消息气泡（包含转录状态和结果）
      // 这个标识只是确认后端已经处理了用户消息，不需要额外显示
      // 我们只需要继续等待AI响应即可
      return;
    }

    // #371 处理 omni 回写用户音频转写文本: 把最近一条 type=audio 且 content='[语音消息]' 的消息 patch 为真实转写
    if (chunk.startsWith('[USER_AUDIO_TRANSCRIPT]')) {
      final transcript = chunk.substring('[USER_AUDIO_TRANSCRIPT]'.length);
      AppLogger.d('[AiChatBloc] #371 收到 user audio transcript, 长度=${transcript.length}');
      final updatedMessages = state.messages.map((msg) {
        if (msg.messageType == MessageType.audio &&
            msg.sender == MessageSender.user &&
            (msg.content == '[语音消息]' || msg.content.isEmpty)) {
          return msg.copyWith(content: transcript);
        }
        return msg;
      }).toList();
      emit(state.copyWith(messages: updatedMessages));
      return;
    }
    
    // 过滤特殊标记，这些标记用于内部控制，不应显示给用户
    if (chunk == '[COMPLETED]' || 
        chunk == '[DONE]' || 
        chunk == '[CANCELLED]') {
      AppLogger.d("[AiChatBloc] 收到控制标记: $chunk，完成流式响应");
      

      
      // 这些标记表示流完成，直接完成消息而不添加内容
      if (state.status == AiChatStatus.streamingResponse) {
        final currentMessages = List<AiChatMessageEntity>.from(state.messages);
        // 只有当有实际内容时才添加消息
        if (state.streamingResponseText.isNotEmpty && 
            state.streamingResponseText != '...' &&
            !state.streamingResponseText.contains('[COMPLETED]') &&
            !state.streamingResponseText.contains('[DONE]') &&
            !state.streamingResponseText.contains('[CANCELLED]')) {
          final aiMessage = AiChatMessageEntity(
            messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}', 
            content: state.streamingResponseText,
            sender: MessageSender.ai,
            timestamp: DateTime.now(),
            conversationId: state.selectedConversationId!, 
          );
          currentMessages.add(aiMessage);
        }
                  emit(state.copyWith(
            status: AiChatStatus.messageSendSuccess,
            streamingResponseText: '',
            messages: currentMessages,
          ));
        AppLogger.d("[AiChatBloc] 流式响应完成，添加最终消息到列表");
      }
      return;
    }
    
    if (event.isDone) {
       // Finalize the AI message only if streaming was in progress
       if (state.status == AiChatStatus.streamingResponse) {
            final currentMessages = List<AiChatMessageEntity>.from(state.messages);
            // Add the complete AI message if generation happened
            if (state.streamingResponseText.isNotEmpty && state.streamingResponseText != '...') {
                final aiMessage = AiChatMessageEntity(
                    messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}', 
                    content: state.streamingResponseText,
                    sender: MessageSender.ai,
                    timestamp: DateTime.now(),
                    // Use the actual selected ID from state
                    conversationId: state.selectedConversationId!, 
                );
                currentMessages.add(aiMessage);
            }
            emit(state.copyWith(
                status: AiChatStatus.messageSendSuccess, // End state for message send
                streamingResponseText: '', // Clear placeholder
                messages: currentMessages,
            ));
            AppLogger.d("[AiChatBloc] 流式响应结束，添加最终消息到列表");
       } // else: Stream might finish due to cancellation, state already handled by _onCancelStreaming
    } else {
      // 直接添加到流式响应文本（恢复简单的逐字符输出）
      if (!isClosed) {
        final updatedText = state.streamingResponseText + event.chunk;
        
        // 🎯 添加流式输出震动反馈
        HapticUtils.streamingTextFeedback();
        
        emit(state.copyWith(
          streamingResponseText: updatedText,
          status: AiChatStatus.streamingResponse,
        ));
      }
    }
  }

  void _onHandleStreamError(_HandleStreamError event, Emitter<AiChatState> emit) {
     // Add the partially streamed message (if any) before showing error
     _addFinalAiMessageFromStream(emit);
     // Set error state
     emit(state.copyWith(
       status: AiChatStatus.messageSendFailure,
       errorMessage: "Error during streaming: ${event.errorMessage ?? 'Unknown error'}", 
       streamingResponseText: '', // Clear stream text on error
       
     ));
  }

   // --- Other Action Handlers (Updated) ---
   void _onCancelStreaming(CancelStreaming event, Emitter<AiChatState> emit) {
     if (state.status == AiChatStatus.streamingResponse) {
        AppLogger.d("Cancelling stream...");
        _chatStreamSubscription?.cancel();
        _chatStreamSubscription = null;
        
        // Add the partially generated message as a final message
        final currentMessages = List<AiChatMessageEntity>.from(state.messages);
        if (state.streamingResponseText.isNotEmpty && state.streamingResponseText != '...') {
            final aiMessage = AiChatMessageEntity(
                messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}_cancelled', 
                content: "${state.streamingResponseText} (cancelled)", 
                sender: MessageSender.ai,
                timestamp: DateTime.now(),
                conversationId: state.selectedConversationId!,
            );
            currentMessages.add(aiMessage);
        }

        // Reset status after cancellation
        emit(state.copyWith(
          status: AiChatStatus.messageSendSuccess, // Or a different status like 'cancelled'?
          streamingResponseText: '',
          messages: currentMessages,
        ));
     }
   }

   Future<void> _onCancelChatGeneration(
     CancelChatGeneration event,
     Emitter<AiChatState> emit,
   ) async {
     // 只有在正在流式响应时才能取消
     if (state.status != AiChatStatus.streamingResponse) {
       AppLogger.d("[AiChatBloc] Cannot cancel: not in streaming state. Current status: ${state.status}");
       return;
     }

     final currentConversationId = state.selectedConversationId;
     if (currentConversationId == null) {
       AppLogger.d("[AiChatBloc] Cannot cancel: no conversation selected");
       return;
     }

     // 设置取消状态
     emit(state.copyWith(status: AiChatStatus.cancellingGeneration));

     try {
       // 获取用户ID
       final userId = await _getCurrentUserId();
       if (userId == null) {
         emit(state.copyWith(
           status: AiChatStatus.messageSendFailure,
           errorMessage: 'User not authenticated or invalid ID format'
         ));
         return;
       }

       // 调用取消聊天生成用例
       final result = await _cancelChatGeneration(CancelChatGenerationParams(
         conversationId: currentConversationId,
         userId: userId,
       ));

       result.fold(
         (failure) {
           AppLogger.d("[AiChatBloc] Cancel chat generation failed: $failure");
           // 如果取消失败，恢复到流式响应状态
           emit(state.copyWith(
             status: AiChatStatus.streamingResponse,
             errorMessage: 'Failed to cancel generation: ${failure.toString()}'
           ));
         },
         (_) {
           AppLogger.d("[AiChatBloc] Chat generation cancelled successfully");
           
           // 取消本地流订阅
           _chatStreamSubscription?.cancel();
           _chatStreamSubscription = null;
           
           // 添加部分生成的消息（如果有的话）
           final currentMessages = List<AiChatMessageEntity>.from(state.messages);
           if (state.streamingResponseText.isNotEmpty && state.streamingResponseText != '...') {
             final aiMessage = AiChatMessageEntity(
               messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}_cancelled',
               content: "${state.streamingResponseText} (用户取消)",
               sender: MessageSender.ai,
               timestamp: DateTime.now(),
               conversationId: currentConversationId,
               messageType: MessageType.text,
             );
             currentMessages.add(aiMessage);
           }

           // 设置成功状态
           emit(state.copyWith(
             status: AiChatStatus.messageSendSuccess,
                       streamingResponseText: '',
             messages: currentMessages,
             clearErrorMessage: true,
           ));
         }
       );
     } catch (e) {
       AppLogger.d("[AiChatBloc] Exception while cancelling chat generation: $e");
       emit(state.copyWith(
         status: AiChatStatus.messageSendFailure,
         errorMessage: 'Exception while cancelling: ${e.toString()}'
       ));
     }
   }

   Future<void> _onFetchRecommendations(
     FetchRecommendations event,
     Emitter<AiChatState> emit,
   ) async {
    final currentConvId = state.selectedConversationId;
    if (currentConvId == null) {
      emit(state.copyWith(
        recommendationsStatus: RecommendationsStatus.error,
        recommendationsErrorMessage: "No conversation selected.",
      ));
      return;
    }

    emit(state.copyWith(
      recommendationsStatus: RecommendationsStatus.loading,
      clearRecommendationsErrorMessage: true,
    ));

    // 修复Issue #172: 推荐系统需要member.id而不是common_user_id
    // 因为Product.tenant_id对应的是Member.id
    final userId = await _getMemberUserId();
    if (userId == null) {
      emit(state.copyWith(
        recommendationsStatus: RecommendationsStatus.error,
        recommendationsErrorMessage: "User not authenticated or invalid ID format.",
      ));
      return;
    }

    // 🆕 获取最新消息的ID - 后端要求必须传递message_id，否则返回空推荐
    int? latestMessageId;
    if (state.messages.isNotEmpty) {
      // 找到最后一条AI消息的ID（因为推荐是基于AI的回复）
      final latestAiMessage = state.messages.lastWhere(
        (msg) => msg.sender == MessageSender.ai,
        orElse: () => state.messages.last, // 如果没有AI消息，使用最后一条
      );

      // 将String类型的messageId转换为int（去掉"local_ai_"等前缀）
      latestMessageId = int.tryParse(latestAiMessage.messageId);
      AppLogger.d('[推荐] 获取最新消息ID: ${latestAiMessage.messageId} -> $latestMessageId');

      if (latestMessageId == null) {
        AppLogger.d('[推荐] ⚠️ 无法解析messageId，可能是本地临时ID');
      }
    } else {
      AppLogger.d('[推荐] ⚠️ 消息列表为空，无法获取messageId');
    }

    final result = await _getRelatedServices(
      GetRelatedServicesParams(
        conversationId: currentConvId,
        userId: userId,
        limit: 10,
        messageId: latestMessageId, // ✅ 传递消息ID
      ),
    );

    result.fold(
      (failure) {
        // 检查是否是频率限制错误
        if (failure.toString().contains('429') || failure.toString().contains('频繁')) {
          emit(state.copyWith(
            recommendationsStatus: RecommendationsStatus.error,
            recommendationsErrorMessage: failure.toString(),
            rateLimitStatus: RateLimitStatus.limitExceeded,
          ));
        } else {
          emit(state.copyWith(
            recommendationsStatus: RecommendationsStatus.error,
            recommendationsErrorMessage: failure.toString(),
          ));
        }
      },
      (services) {
        emit(state.copyWith(
          recommendationsStatus: RecommendationsStatus.loaded,
          recommendations: services,
          clearRecommendationsErrorMessage: true,
        ));
        
        // 如果获取推荐成功，也重新获取频率限制状态
        add(FetchRateLimitStatus(userId: userId));
      },
    );
  }

  /// 拉取当前 conversation 的已分发商品历史(#347)。
  /// 后端 user_id 字段语义同 allocate(走 common_user_id,验权用 verify_conversation_access)。
  Future<void> _onFetchDispatchHistory(
    FetchDispatchHistory event,
    Emitter<AiChatState> emit,
  ) async {
    final currentConvId = state.selectedConversationId;
    if (currentConvId == null) {
      return;
    }
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        dispatchHistoryStatus: DispatchHistoryStatus.error,
        dispatchHistoryErrorMessage: '未登录或用户 ID 无效',
      ));
      return;
    }
    emit(state.copyWith(dispatchHistoryStatus: DispatchHistoryStatus.loading));

    final result = await _getDispatchHistory(GetDispatchHistoryParams(
      conversationId: currentConvId,
      userId: userId,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        dispatchHistoryStatus: DispatchHistoryStatus.error,
        dispatchHistoryErrorMessage: failure.toString(),
      )),
      (history) => emit(state.copyWith(
        dispatchHistoryStatus: DispatchHistoryStatus.loaded,
        dispatchHistory: history,
      )),
    );
  }

  // --- Handler for Allocation Action ---
  Future<void> _onTriggerAllocationAction(
    TriggerAllocationAction event,
    Emitter<AiChatState> emit,
  ) async {
    try {
    final currentConvId = state.selectedConversationId;
    if (currentConvId == null) {
        emit(state.copyWith(
          status: AiChatStatus.allocationFailure, 
          errorMessage: 'No conversation selected for allocation'
        ));
      return;
    }
    
    // 更新特定服务的分发状态为加载中
    final updatedAllocationStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
    updatedAllocationStatus[event.serviceId] = AllocationStatus.loading;
    
    emit(state.copyWith(
      status: AiChatStatus.allocatingResource, 
      clearErrorMessage: true,
      serviceAllocationStatus: updatedAllocationStatus
    ));

    // 获取用户ID - 分发接口使用member user_id而不是common_user_id
    final userId = await _getMemberUserId();
    if (userId == null) {
      // 更新分发状态为失败
        final failureStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
        failureStatus[event.serviceId] = AllocationStatus.failure;

      emit(state.copyWith(
        status: AiChatStatus.allocationFailure,
          errorMessage: '用户未认证或ID格式无效',
          serviceAllocationStatus: failureStatus
        ));
      return;
    }

    // 调用分配资源用例
    final result = await _allocateChatResource(AllocateChatResourceParams(
       conversationId: currentConvId,
       userId: userId,
       item: event.item,
       merchantId: event.merchantId,
    ));

      // 处理结果
      if (result.isLeft()) {
        // 处理失败情况
        final failure = result.fold(
          (l) => l,
          (r) => null,
        );
        
        // 更新分发状态为失败
        final failureStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
        failureStatus[event.serviceId] = AllocationStatus.failure;
        
        emit(state.copyWith(
        status: AiChatStatus.allocationFailure,
        errorMessage: failure.toString(),
          serviceAllocationStatus: failureStatus
        ));
      } else {
        // 处理成功情况
        final allocationResult = result.fold(
          (l) => null,
          (r) => r,
        );
        
        if (allocationResult == null) {
          throw Exception("结果处理错误");
        }
        
        // 分发成功，触发中度双震
        await HapticUtils.allocationSuccessFeedback();
        
        // 立即更新成功状态，确保UI更新
        final successStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
        successStatus[event.serviceId] = AllocationStatus.success;
        
        // 获取AI生成的专业需求总结
        final summary = allocationResult.summary;
        AppLogger.d('Allocation successful: $summary'); 
        
        // 发射成功状态
        emit(state.copyWith(
           status: AiChatStatus.allocationSuccess,
          serviceAllocationStatus: successStatus,
           // errorMessage: '服务已成功分发给商家'
        ));

        // #347 分发成功后刷新历史,AppBar 按钮立即点亮
        add(FetchDispatchHistory());

        // 后台异步处理发送消息，不再使用结果更新UI状态
        _sendAllocationMessageToMerchant(
          event.merchantId,
          event.item,
          summary
        ).catchError((e) {
          AppLogger.d('向商家发送消息失败(不影响UI状态): $e');
        });
      }
    } catch (e, stackTrace) {
      AppLogger.d('分发处理中发生未处理异常: $e');
      AppLogger.d(stackTrace);
      
      // 异常情况下，确保按钮状态正确
      final errorStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
      errorStatus[event.serviceId] = AllocationStatus.failure;
      
      emit(state.copyWith(
        status: AiChatStatus.allocationFailure,
        serviceAllocationStatus: errorStatus,
        errorMessage: '服务分发过程中发生错误: $e'
      ));
    }
  }

  // --- Internal Event Handlers for Stream ---

  void _onHandleStreamDone(_HandleStreamDone event, Emitter<AiChatState> emit) {
      AppLogger.d("[AiChatBloc] 流式响应结束，当前状态: ${state.status}, 文本长度: ${state.streamingResponseText.length}");
      
      // Add the complete streamed message as a final AI message
     _addFinalAiMessageFromStream(emit);
      
     // Set success state (or idle if preferred)
     emit(state.copyWith(
         status: AiChatStatus.messageSendSuccess, // Or AiChatStatus.idle
         streamingResponseText: '', // Clear stream text on completion
     ));
      
      AppLogger.d("[AiChatBloc] 流式响应处理完成，最终状态: ${state.status}, 消息数: ${state.messages.length}");
  }

  // Helper to add the final AI message from the accumulated stream text
  void _addFinalAiMessageFromStream(Emitter<AiChatState> emit) {
     if (state.streamingResponseText.isNotEmpty && state.selectedConversationId != null) {
       final aiMessage = AiChatMessageEntity(
         messageId: 'local_ai_${DateTime.now().millisecondsSinceEpoch}',
         conversationId: state.selectedConversationId!,
         sender: MessageSender.ai,
         content: state.streamingResponseText,
         timestamp: DateTime.now(),
         messageType: MessageType.text, // Assuming stream is always text
       );
       // Emit state with the final AI message added
       // Avoid changing the 'status' here, let the calling handler set the final status
       emit(state.copyWith(
         messages: List.from(state.messages)..add(aiMessage),
         streamingResponseText: '', // Clear stream text after adding message
       ));
     } else {
        // If stream was empty or cancelled immediately, just clear the text
        emit(state.copyWith(streamingResponseText: ''));
     }
  }

  // --- Cleanup ---
  @override
  Future<void> close() {
    _chatStreamSubscription?.cancel();
    AppLogger.d("AiChatBloc closed, stream subscription cancelled.");
    return super.close();
   }
   
   // 提取发送消息给商家的逻辑到单独的方法
   Future<void> _sendAllocationMessageToMerchant(
     int merchantId, 
     Map<String, dynamic> item,
     String summary
   ) async {
     try {
       AppLogger.d('准备发送消息给商家ID: $merchantId, 商品: ${item['name']}');
           
      // 创建新的Dio实例并设置基础URL和超时配置
      final baseUrl = dotenv.env['BACKEND_BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BACKEND_BASE_URL environment variable is not set');
      }
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30), // 连接超时30秒
        receiveTimeout: const Duration(seconds: 30), // 接收超时30秒
        sendTimeout: const Duration(seconds: 30), // 发送超时30秒
      ));
           
           // 获取认证令牌
           final String? authToken = await _storage.read(key: 'auth_token');
           if (authToken == null || authToken.isEmpty) {
             throw Exception('认证令牌不存在或为空');
           }
           
       // 添加必要的请求头信息
           final options = Options(
             contentType: Headers.jsonContentType,
             responseType: ResponseType.json,
             headers: {
               'Content-Type': 'application/json',
           'clienttype': '1',
               'client': Platform.isAndroid ? 'android' : 'ios',
               'version': '100',
           'packageName': 'com.duoshaokankan.dskk',
           'versionCode': '1.0.0',
           'versionName': '1.0.0',
           'Authorization': 'Bearer $authToken',
             },
           );
           
           // 第一步：创建聊天室
           AppLogger.d("发送创建聊天室请求...");
           
       // 构建创建聊天室的请求参数
           final createRoomParams = {
         'doctorId': merchantId.toString(),
             'type': 'MEMBER',
           };
           
      // 如果item中包含商品ID，添加到请求参数中
      if (item['id'] != null) {
        createRoomParams['productId'] = item['id'];
      }
           
           AppLogger.d("创建聊天室请求参数: $createRoomParams");
           
           final createRoomResponse = await dio.post(
             '/api/chat/addChat',
             data: createRoomParams,
             options: options
           );
           
           AppLogger.d("创建聊天室响应状态码: ${createRoomResponse.statusCode}");
           AppLogger.d("创建聊天室响应数据: ${createRoomResponse.data}");
           
           if (createRoomResponse.statusCode == 200 && 
               createRoomResponse.data != null && 
               createRoomResponse.data['code'] == 200) {
             
        final chatRoomData = createRoomResponse.data['data'];
        final chatId = chatRoomData['id']; // 从聊天室对象中提取id字段
             AppLogger.d('成功创建聊天室，ID: $chatId');
             
             // 第二步：发送消息
             AppLogger.d("发送消息请求...");
             
             // 构建一个更丰富的消息，包含服务名称和AI分析的总结
         String messageContent = summary;
             
             // 构建发送消息的请求参数
             final sendMessageParams = {
               'chatId': chatId,
           'context': messageContent,
               'type': 'allocate',
             };
             
             AppLogger.d("发送消息请求参数: $sendMessageParams");
             
             final sendMsgResponse = await dio.post(
               '/common/chat/message/add',
               data: sendMessageParams,
               options: options
             );
             
             AppLogger.d("发送消息响应状态码: ${sendMsgResponse.statusCode}");
             AppLogger.d("发送消息响应数据: ${sendMsgResponse.data}");
             
             if (sendMsgResponse.statusCode == 200 && 
                 sendMsgResponse.data != null && 
                 sendMsgResponse.data['code'] == 200) {
               AppLogger.d('消息已成功发送给商家!');
             } else {
               AppLogger.d('发送消息API返回错误: ${sendMsgResponse.data}');
             }
           } else {
             AppLogger.d('创建聊天室API返回错误: ${createRoomResponse.data}');
           }
         } catch (e) {
           AppLogger.d('向商家发送消息失败: $e');
     }
   }

  // --- Handler for Optimized Allocation Action ---
  Future<void> _onTriggerOptimizedAllocation(
    TriggerOptimizedAllocation event,
    Emitter<AiChatState> emit,
  ) async {
    AppLogger.d('[优化分发] 开始处理分发事件 - serviceId: ${event.serviceId}, merchantId: ${event.merchantId}');
    AppLogger.d('[优化分发] 商品数据: ${event.item}');

    try {
      final currentConvId = state.selectedConversationId;
      AppLogger.d('[优化分发] 当前conversationId: $currentConvId');

      if (currentConvId == null) {
        AppLogger.d('[优化分发] ❌ conversationId为空，无法进行分发');
        emit(state.copyWith(
          status: AiChatStatus.allocationFailure,
          errorMessage: 'No conversation selected for allocation'
        ));
        return;
      }
      
      // 更新特定服务的分发状态为加载中
      final updatedAllocationStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
      updatedAllocationStatus[event.serviceId] = AllocationStatus.loading;
      
      emit(state.copyWith(
        status: AiChatStatus.allocatingResource,
        clearErrorMessage: true,
        serviceAllocationStatus: updatedAllocationStatus
      ));

      // 获取用户ID
      // 修复：应该使用common_user_id，因为AI对话系统使用的是common_user_id
      // conversation是用common_user_id创建的，分发API也必须使用相同的ID
      final userId = await _getCurrentUserId(); // ✅ 改为使用common_user_id
      AppLogger.d('[优化分发] 获取到的userId (common_user_id): $userId');

      if (userId == null) {
        AppLogger.d('[优化分发] ❌ userId为空，用户未认证或ID格式无效');
        final failureStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
        failureStatus[event.serviceId] = AllocationStatus.failure;

     emit(state.copyWith(
          status: AiChatStatus.allocationFailure,
          errorMessage: '用户未认证或ID格式无效',
          serviceAllocationStatus: failureStatus
        ));
        return;
      }

      AppLogger.d('[优化分发] ✅ 准备调用OptimizedAllocation - conversationId: $currentConvId, userId: $userId (common_user_id), merchantId: ${event.merchantId}');

      // 调用优化分配用例
      final result = await _optimizedAllocation(OptimizedAllocationParams(
        conversationId: currentConvId,
        userId: userId,
        item: event.item,
        merchantId: event.merchantId,
      ));

      AppLogger.d('[优化分发] OptimizedAllocation调用完成，结果: ${result.isRight() ? "成功" : "失败"}');

      // 处理结果
      result.fold(
        (failure) {
          // 处理失败情况
          final failureStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
          failureStatus[event.serviceId] = AllocationStatus.failure;
          
          emit(state.copyWith(
            status: AiChatStatus.allocationFailure,
            errorMessage: failure.toString(),
            serviceAllocationStatus: failureStatus
          ));
        },
        (optimizedResult) {
          // 处理成功情况
          final successStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
          successStatus[event.serviceId] = AllocationStatus.success;
          
          // 触发震动反馈
          HapticUtils.allocationSuccessFeedback();
          
          // 更新状态，包括创建的聊天室ID
          emit(state.copyWith(
            status: AiChatStatus.allocationSuccess,
            serviceAllocationStatus: successStatus,
            createdChatRoomId: optimizedResult.chatRoomId,
            errorMessage: optimizedResult.allocationSuccess 
              ? '聊天室已创建，AI分发成功！点击进入聊天' 
              : '聊天室已创建，但AI分发失败。您仍可以直接与商家聊天',
          ));
          
          // 如果AI分发成功，后台发送消息
          if (optimizedResult.allocationSuccess) {
            _sendAllocationMessageToMerchant(
              event.merchantId, 
              event.item, 
              optimizedResult.summary
            ).catchError((e) {
              AppLogger.d('向商家发送消息失败(不影响UI状态): $e');
            });
          }
        }
      );
    } catch (e, stackTrace) {
      AppLogger.d('优化分发处理中发生未处理异常: $e');
      AppLogger.d(stackTrace);
      
      final errorStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
      errorStatus[event.serviceId] = AllocationStatus.failure;
      
      emit(state.copyWith(
        status: AiChatStatus.allocationFailure,
        serviceAllocationStatus: errorStatus,
        errorMessage: '服务分发过程中发生错误: $e'
      ));
    }
  }

  // --- Title Operations Handlers ---

  Future<void> _onUpdateConversationTitle(
    UpdateConversationTitle event,
    Emitter<AiChatState> emit,
  ) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        titleStatus: TitleStatus.failure, 
        titleErrorMessage: 'User not authenticated or invalid ID format'
      ));
      return;
    }

    // 更新特定会话的标题状态为更新中
    final updatedTitleStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
    updatedTitleStatus[event.conversationId] = TitleStatus.updating;
    
    emit(state.copyWith(
      titleStatus: TitleStatus.updating,
      conversationTitleStatus: updatedTitleStatus,
      clearTitleErrorMessage: true,
    ));

    final result = await _updateConversationTitle(UpdateConversationTitleParams(
      conversationId: event.conversationId,
      userId: userId,
      title: event.title,
    ));

    result.fold(
      (failure) {
        // 更新失败
        final failureStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
        failureStatus[event.conversationId] = TitleStatus.failure;
        
        emit(state.copyWith(
          titleStatus: TitleStatus.failure,
          titleErrorMessage: failure.toString(),
          conversationTitleStatus: failureStatus,
        ));
      },
      (updatedTitle) {
        // 更新成功
        final successStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
        successStatus[event.conversationId] = TitleStatus.success;
        
        // 更新会话列表中对应会话的标题
        final updatedConversations = state.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return AiConversationEntity(
              id: conv.id,
              title: updatedTitle,
              createdAt: conv.createdAt,
              updatedAt: conv.updatedAt,
            );
          }
          return conv;
        }).toList();
        
       emit(state.copyWith(
          titleStatus: TitleStatus.success,
          conversationTitleStatus: successStatus,
          conversations: updatedConversations,
          clearTitleErrorMessage: true,
        ));
        
        AppLogger.d('[AiChatBloc] 标题更新成功: ${event.conversationId} -> $updatedTitle');
      },
    );
  }

  Future<void> _onGenerateConversationTitle(
    GenerateConversationTitle event,
    Emitter<AiChatState> emit,
  ) async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(
        titleStatus: TitleStatus.failure, 
        titleErrorMessage: 'User not authenticated or invalid ID format'
      ));
      return;
    }

    // 更新特定会话的标题状态为生成中
    final updatedTitleStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
    updatedTitleStatus[event.conversationId] = TitleStatus.generating;
    
    emit(state.copyWith(
      titleStatus: TitleStatus.generating,
      conversationTitleStatus: updatedTitleStatus,
      clearTitleErrorMessage: true,
    ));

    final result = await _generateConversationTitle(GenerateConversationTitleParams(
      conversationId: event.conversationId,
      userId: userId,
    ));

    result.fold(
      (failure) {
        // 生成失败
        final failureStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
        failureStatus[event.conversationId] = TitleStatus.failure;
        
        emit(state.copyWith(
          titleStatus: TitleStatus.failure,
          titleErrorMessage: failure.toString(),
          conversationTitleStatus: failureStatus,
        ));
      },
      (generatedTitle) {
        // 生成成功
        final successStatus = Map<int, TitleStatus>.from(state.conversationTitleStatus);
        successStatus[event.conversationId] = TitleStatus.success;
        
        // 更新会话列表中对应会话的标题
        final updatedConversations = state.conversations.map((conv) {
          if (conv.id == event.conversationId) {
            return AiConversationEntity(
              id: conv.id,
              title: generatedTitle,
              createdAt: conv.createdAt,
              updatedAt: conv.updatedAt,
            );
          }
          return conv;
        }).toList();
        
        emit(state.copyWith(
          titleStatus: TitleStatus.success,
          conversationTitleStatus: successStatus,
          conversations: updatedConversations,
          clearTitleErrorMessage: true,
        ));
        
        AppLogger.d('[AiChatBloc] AI标题生成成功: ${event.conversationId} -> $generatedTitle');
      },
    );
  }

  // --- Rate Limit Handlers ---

  Future<void> _onFetchRateLimitStatus(
    FetchRateLimitStatus event,
    Emitter<AiChatState> emit,
  ) async {
    emit(state.copyWith(rateLimitStatus: RateLimitStatus.loading));
    
    try {
      if (event.userId <= 0) {
        emit(state.copyWith(
          rateLimitStatus: RateLimitStatus.error,
          rateLimitErrorMessage: 'User not authenticated or invalid ID format',
        ));
        return;
      }

      final result = await _remoteDataSource.getRateLimitStatus(
        userId: event.userId,
      );
      
      AppLogger.d('[AiChatBloc] Rate limit API result for userId=${event.userId}: $result');
      
      // result已经是API响应的data部分，不需要再访问result['data']
      final conversationData = result['conversation'] as Map<String, dynamic>?;
      final personalizedData = result['personalized'] as Map<String, dynamic>?;
      
      final conversationLimit = _parseServiceLimitInfo(conversationData);
      final personalizedLimit = _parseServiceLimitInfo(personalizedData);
      
      AppLogger.d('[AiChatBloc] Parsed conversation limit: $conversationLimit');
      AppLogger.d('[AiChatBloc] Parsed personalized limit: $personalizedLimit');
      
      emit(state.copyWith(
        rateLimitStatus: RateLimitStatus.loaded,
        conversationRateLimit: conversationLimit,
        personalizedRateLimit: personalizedLimit,
        clearRateLimitErrorMessage: true,
      ));
      
    } catch (e) {
      AppLogger.d('[AiChatBloc] Failed to fetch rate limit status: $e');
      emit(state.copyWith(
        rateLimitStatus: RateLimitStatus.error,
        rateLimitErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetRateLimit(
    ResetRateLimit event,
    Emitter<AiChatState> emit,
  ) async {
    try {
      if (event.userId <= 0) {
        emit(state.copyWith(
          rateLimitStatus: RateLimitStatus.error,
          rateLimitErrorMessage: 'User not authenticated or invalid ID format',
        ));
        return;
      }

      await _remoteDataSource.resetUserRateLimit(
        userId: event.userId,
        serviceType: event.serviceType,
        ruleName: event.ruleName,
      );
      
      // 重置成功后，重新获取状态
      add(FetchRateLimitStatus(userId: event.userId));
      
    } catch (e) {
      AppLogger.d('[AiChatBloc] Failed to reset rate limit: $e');
      emit(state.copyWith(
        rateLimitStatus: RateLimitStatus.error,
        rateLimitErrorMessage: e.toString(),
      ));
    }
  }

  // 解析服务限制信息的辅助方法
  RateLimitInfo? _parseServiceLimitInfo(Map<String, dynamic>? serviceData) {
    if (serviceData == null || serviceData['enabled'] != true) {
      return null;
    }
    
    final rules = serviceData['rules'] as Map<String, dynamic>?;
    if (rules == null) return null;
    
    // 找到剩余次数最少的规则作为主要显示
    int minRemaining = 999999;
    int maxResetTime = 0;
    final ruleStatuses = <RuleStatus>[];
    
    rules.forEach((ruleName, ruleData) {
      final remaining = ruleData['remaining'] ?? 0;
      final resetTime = ruleData['reset_in_seconds'] ?? 0;
      
      if (remaining < minRemaining) {
        minRemaining = remaining;
      }
      if (resetTime > maxResetTime) {
        maxResetTime = resetTime;
      }
      
      ruleStatuses.add(RuleStatus(
        name: ruleName,
        currentCount: ruleData['current_count'] ?? 0,
        limit: ruleData['limit'] ?? 0,
        remaining: remaining,
        windowMinutes: ruleData['window_minutes'] ?? 0,
      ));
    });
    
    return RateLimitInfo(
      remaining: minRemaining,
      resetInSeconds: maxResetTime,
      rulesStatus: ruleStatuses,
    );
  }
} 
