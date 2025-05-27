import 'dart:async';
import 'dart:io';
import 'dart:convert'; // For jsonDecode in stream handling
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Secure Storage
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/haptic_utils.dart'; // 导入震动工具类

// Core
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Use package import

// Domain Layer - Use package imports
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_conversation_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/chat_allocation_result_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/allocate_chat_resource_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/create_conversation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/delete_conversation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_conversations_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/get_related_services_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/load_history_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/stream_chat_completion_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/transcribe_audio_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/upload_file_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/cancel_chat_generation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/optimized_allocation_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/update_conversation_title_usecase.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/usecases/generate_conversation_title_usecase.dart';

// Move Exports Before Parts - Use package imports
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_conversation_entity.dart'; 
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart'; 
export 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/related_service_entity.dart'; 

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
  final TranscribeAudioUseCase _transcribeAudio;
  final CancelChatGenerationUseCase _cancelChatGeneration;
  final OptimizedAllocationUseCase _optimizedAllocation;
  final UpdateConversationTitleUseCase _updateConversationTitle;
  final GenerateConversationTitleUseCase _generateConversationTitle;

  // --- Inject Secure Storage --- 
  final FlutterSecureStorage _storage;

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
    this._transcribeAudio,
    this._cancelChatGeneration,
    this._optimizedAllocation,
    this._updateConversationTitle,
    this._generateConversationTitle,
    this._storage, // Add storage to constructor
    // Start with initial state containing defaults for new properties
  ) : super(const AiChatState()) { 
    // --- Register event handlers ---
    // Conversation List Management
    on<LoadConversations>(_onLoadConversations);
    on<SelectConversation>(_onSelectConversation);
    on<CreateNewConversation>(_onCreateNewConversation);
    on<DeleteSelectedConversation>(_onDeleteSelectedConversation);
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
  }

  // --- Helper to get current user ID --- 
  // Returns null if not found or not an int
  Future<int?> _getCurrentUserId() async {
    // 修改：使用common_user_id而不是user_id
    final commonUserIdString = await _storage.read(key: 'common_user_id');
    
    // 调试日志
    final userIdString = await _storage.read(key: 'user_id');
    print("[AiChatBloc] 用户ID信息: user_id = $userIdString, common_user_id = $commonUserIdString");
    
    if (commonUserIdString != null) {
      // 转换为整数并返回
      return int.tryParse(commonUserIdString);
    }
    
    // 不再回退使用user_id，如果没有common_user_id则直接返回null（错误）
    print("[AiChatBloc] 错误: 未找到common_user_id，AI聊天功能需要正确的common_user_id");
    return null;
  }

  // --- Conversation List Handlers ---

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<AiChatState> emit,
  ) async {
     print("[AiChatBloc] _onLoadConversations triggered.");
     // Indicate loading state for the conversation list
     emit(state.copyWith(conversationsStatus: ConversationsStatus.loading));
     final userId = await _getCurrentUserId();
     print("[AiChatBloc] _onLoadConversations: Retrieved userId = $userId");

     if (userId == null) {
       print("[AiChatBloc] _onLoadConversations: userId is null. Emitting error.");
       emit(state.copyWith(conversationsStatus: ConversationsStatus.error, conversationListErrorMessage: "User not authenticated or invalid ID format"));
       return;
     }

     print("[AiChatBloc] _onLoadConversations: Calling _getConversations with userId: $userId");
     // Pass int userId to Params
     final result = await _getConversations(GetConversationsParams(userId: userId)); 
     print("[AiChatBloc] _onLoadConversations: _getConversations result: $result");

     result.fold(
       (failure) {
         print("[AiChatBloc] _onLoadConversations: Failure - $failure. Emitting error state.");
         emit(state.copyWith(
             conversationsStatus: ConversationsStatus.error,
             // Use the dedicated error message field for conversation list errors
             conversationListErrorMessage: failure.toString(),
          ));
       },
       (conversations) {
         print("[AiChatBloc] _onLoadConversations: Success - Received ${conversations.length} conversations. Emitting loaded state.");
         emit(state.copyWith(
             conversationsStatus: ConversationsStatus.loaded,
             conversations: conversations,
             // Clear conversation list error on success
             clearConversationListErrorMessage: true,
         ));
       },
     );
     // Log the final emitted state for debugging
     print("[AiChatBloc] _onLoadConversations: Final emitted state status = ${state.conversationsStatus}, count = ${state.conversations.length}"); 
  }

   Future<void> _onSelectConversation(
    SelectConversation event,
    Emitter<AiChatState> emit,
  ) async {
    // If same conversation selected, do nothing (or maybe reload history?)
    if (state.selectedConversationId == event.conversationId) return;

    // Immediately update selected ID and clear messages/status for the main chat area
    emit(state.copyWith(
      selectedConversationIdOrNull: event.conversationId,
      status: AiChatStatus.loadingHistory, // Indicate history loading for main area
      messages: [], // Clear previous messages
      recommendations: [], // Clear related services
      streamingResponseText: '', // Clear generation
      clearErrorMessage: true, // Clear main chat area error
    ));

    // Load history for the selected conversation
    final userId = await _getCurrentUserId();
    if (userId == null) {
       emit(state.copyWith(status: AiChatStatus.historyLoadFailure, errorMessage: 'User not authenticated or invalid ID format'));
       return;
    }
    final historyResult = await _loadHistory(LoadHistoryParams(
      conversationId: event.conversationId,
      userId: userId,
    ));

    historyResult.fold(
      (failure) => emit(state.copyWith(
        status: AiChatStatus.historyLoadFailure, // Update main area status
        errorMessage: 'Failed to load history: ${failure.toString()}',
      )),
      (messages) => emit(state.copyWith(
        status: AiChatStatus.historyLoadSuccess, // Update main area status
        messages: messages,
        hasMoreHistory: messages.length >= 50, // Example: Assume more if limit reached
      )),
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
          status: AiChatStatus.historyLoadSuccess, // New chat is ready (empty history loaded successfully)
          messages: [],
          recommendations: [],
          streamingResponseText: '', 
          clearErrorMessage: true,
          clearConversationListErrorMessage: true,
        ));
        // Refresh the conversation list to include the new one
        add(LoadConversations()); 
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
        add(LoadConversations()); 
      },
    );
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
    print("[Bloc] Starting upload for: $imagePath");
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: 'User not authenticated or invalid ID format'));
        return;
      }
      final uploadResult = await _uploadFile(UploadFileParams(file: imageFile));
      uploadResult.fold(
        (failure) {
          print("[Bloc] Upload failed for $imagePath: $failure");
          // Dispatch internal failure event using path
          add(_ImageUploadFailure(originalFilePath: imagePath, error: failure.toString()));
        },
        (url) {
          print("[Bloc] Upload success for $imagePath: $url");
          // Dispatch internal success event using path
          add(_ImageUploadSuccess(originalFilePath: imagePath, uploadedUrl: url));
        },
      );
    } catch (e) {
       print("[Bloc] Exception during upload for $imagePath: $e");
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
        print("[Bloc] Warning: Received upload success for path not in state: ${event.originalFilePath}");
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
        print("[Bloc] Warning: Received upload failure for path not in state: ${event.originalFilePath}");
     }
     print("Image upload failed for ${event.originalFilePath}: ${event.error}");
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

    print("[Bloc] Removed pending image: $imagePathToRemove");
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
      print("Cannot send message while streaming");
      return;
    }

    // --- 检查是否有内容可发送（文本或图片） --- 
    final hasText = event.message.trim().isNotEmpty;
    final hasPendingImages = state.pendingImageFiles?.isNotEmpty == true;
    
    if (!hasText && !hasPendingImages) {
        print("Cannot send empty message (no text and no images).");
        // Optionally show snackbar feedback from here or rely on UI logic
        return; 
    }

    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

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
             print("[Bloc] Warning: ImageUploadState.success for $path has null URL.");
          }
      } 
      // Ignore images that are uploading or failed
      else if (uploadState?.status == ImageUploadStatus.uploading) {
           print("[Bloc] Image still uploading, not included in message: $path");
      } else if (uploadState?.status == ImageUploadStatus.failure) {
           print("[Bloc] Image upload failed, not included in message: $path");
      }
    }

    // --- Add user message optimistically --- 
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
        print("[Bloc] Error initiating stream: $failure");
        emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: failure.toString()));
        // Note: Image state was already cleared optimistically. Consider if rollback is needed.
      },
      (contentStream) {
        // Successfully initiated stream, start listening
        print("[Bloc] Stream initiated successfully. Listening...");
        emit(state.copyWith(status: AiChatStatus.streamingResponse)); // Update status
        
        _chatStreamSubscription = contentStream.listen(
          (chunk) {
            print("[Bloc] Received stream chunk: '$chunk'");
            add(_ReceiveStreamChunk(chunk)); 
          },
          onError: (error) {
            print("[Bloc] Stream error: $error");
            add(_HandleStreamError(error.toString()));
            _chatStreamSubscription = null; 
          },
          onDone: () {
            print("[Bloc] Stream completed");
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
    print('准备上传的音频文件大小: ${fileSize / 1024} KB, 路径: ${event.audioFile.path}');
    
    // 添加重试逻辑
    int retryCount = 0;
    const maxRetries = 2;
    late Either<Failure, String> uploadResult;
    
    while (retryCount <= maxRetries) {
      if (retryCount > 0) {
        print('正在重试音频上传 (${retryCount}/${maxRetries})...');
        // 在重试时不改变消息状态，保持转录中状态
        await Future.delayed(Duration(seconds: 1));
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
        print('音频上传失败: $failure');
        
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
      // 6. 上传成功
      (audioOssUrl) async {
        print('音频上传成功，URL: $audioOssUrl');
        
        // 5. 转录成功，更新语音消息显示转录结果
        final updatedMessages = state.messages.map((msg) {
          if (msg.messageId == tempVoiceMessageId) {
            print('[语音消息] 更新消息 - 设置音频URL: $audioOssUrl');
            return msg.copyWith(
              content: "转录中...", // 上传成功后显示转录中状态
              fileUrls: [audioOssUrl], // 设置音频URL到fileUrls
              messageType: MessageType.audio, // 确保类型正确
              isTranscribing: true, // 保持转录中状态
            );
          }
          return msg;
        }).toList();
        
        emit(state.copyWith(
          status: AiChatStatus.sendingMessage,
          messages: updatedMessages,
          clearErrorMessage: true,
        ));
        
        // 8. 开始转录
        print('开始调用语音转文字服务, URL: $audioOssUrl');
        final transcriptionResult = await _transcribeAudio(
          TranscribeAudioParams(
            audioOssUrl: audioOssUrl,
            userId: userId,
          )
        );
        
        await transcriptionResult.fold(
          // 转录失败
          (failure) async {
            print('语音转录失败: $failure');
            
            // 更新消息状态为转录失败
            final updatedMessages = state.messages.map((msg) {
              if (msg.messageId == tempVoiceMessageId) {
                return msg.copyWith(
                  content: '[转录失败，但可播放原音频]', // 显示转录失败信息
                  isTranscribing: false, // 清除转录中状态
                  messageType: MessageType.audio, // 保持音频类型
                );
              }
              return msg;
            }).toList();
            
            emit(state.copyWith(
              status: AiChatStatus.transcriptionFailure,
              messages: updatedMessages,
              errorMessage: '语音转录失败',
            ));
            
            // 仍然尝试发送音频消息到后端（不带转录）
            await _sendVoiceToBackend(currentConversationId, userId, audioOssUrl, null, emit);
          },
          // 转录成功
          (transcription) async {
            print('语音转录成功: $transcription');
            
            // 更新消息显示转录结果 - content设置为转录文本，保持音频类型
            final updatedMessages = state.messages.map((msg) {
              if (msg.messageId == tempVoiceMessageId) {
                return msg.copyWith(
                  content: transcription, // 设置转录文本到content
                  messageType: MessageType.audio, // 保持音频类型
                  isTranscribing: false, // 清除转录中状态
                  // fileUrls已经在上传成功时设置，保持不变
                );
              }
              return msg;
            }).toList();
            
            emit(state.copyWith(
              status: AiChatStatus.transcriptionSuccess,
              messages: updatedMessages,
            ));
            
            // 发送音频消息到后端（带转录）
            await _sendVoiceToBackend(currentConversationId, userId, audioOssUrl, transcription, emit);
          },
        );
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
        print('音频消息发送失败: $failure');
        emit(state.copyWith(
          status: AiChatStatus.messageSendFailure,
          errorMessage: '音频消息发送失败: ${failure.toString()}',
        ));
      },
      (contentStream) {
        print('音频消息发送成功，开始AI响应');
        emit(state.copyWith(status: AiChatStatus.streamingResponse));
        
        _chatStreamSubscription = contentStream.listen(
          (chunk) => add(_ReceiveStreamChunk(chunk)),
          onError: (error) => add(_HandleStreamError(error.toString())),
          onDone: () => add(const _HandleStreamDone()),
        );
      },
    );
  }

  // --- Internal Stream Handlers (Updated) ---
  void _onReceiveStreamChunk(_ReceiveStreamChunk event, Emitter<AiChatState> emit) {
    print("[AiChatBloc] 收到流式数据块: ${event.chunk}");
    
    // 检查是否是特殊控制标记
    final chunk = event.chunk.trim();
    
    // 处理跳过用户消息显示的标识
    if (chunk == '[SKIP_USER_MESSAGE]') {
      print("[AiChatBloc] 收到跳过用户消息显示标识");
      // 对于语音消息，我们已经在前端显示了语音消息气泡（包含转录状态和结果）
      // 这个标识只是确认后端已经处理了用户消息，不需要额外显示
      // 我们只需要继续等待AI响应即可
      return;
    }
    
    // 过滤特殊标记，这些标记用于内部控制，不应显示给用户
    if (chunk == '[COMPLETED]' || 
        chunk == '[DONE]' || 
        chunk == '[CANCELLED]') {
      print("[AiChatBloc] 收到控制标记: $chunk，完成流式响应");
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
        print("[AiChatBloc] 流式响应完成，添加最终消息到列表");
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
            print("[AiChatBloc] 流式响应结束，添加最终消息到列表");
       } // else: Stream might finish due to cancellation, state already handled by _onCancelStreaming
    } else {
      // 只添加非控制标记的内容
      final newGeneration = (state.streamingResponseText == '...' ? '' : state.streamingResponseText) + event.chunk;
      print("[AiChatBloc] 更新流式文本: '$newGeneration'");
      emit(state.copyWith(
        streamingResponseText: newGeneration,
        status: AiChatStatus.streamingResponse, // Ensure status remains streaming
      ));
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
        print("Cancelling stream...");
        _chatStreamSubscription?.cancel();
        _chatStreamSubscription = null;
        
        // Add the partially generated message as a final message
        final currentMessages = List<AiChatMessageEntity>.from(state.messages);
        if (state.streamingResponseText.isNotEmpty && state.streamingResponseText != '...') {
            final aiMessage = AiChatMessageEntity(
                messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}_cancelled', 
                content: state.streamingResponseText + " (cancelled)", 
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
       print("[AiChatBloc] Cannot cancel: not in streaming state. Current status: ${state.status}");
       return;
     }

     final currentConversationId = state.selectedConversationId;
     if (currentConversationId == null) {
       print("[AiChatBloc] Cannot cancel: no conversation selected");
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
           print("[AiChatBloc] Cancel chat generation failed: $failure");
           // 如果取消失败，恢复到流式响应状态
           emit(state.copyWith(
             status: AiChatStatus.streamingResponse,
             errorMessage: 'Failed to cancel generation: ${failure.toString()}'
           ));
         },
         (_) {
           print("[AiChatBloc] Chat generation cancelled successfully");
           
           // 取消本地流订阅
           _chatStreamSubscription?.cancel();
           _chatStreamSubscription = null;
           
           // 添加部分生成的消息（如果有的话）
           final currentMessages = List<AiChatMessageEntity>.from(state.messages);
           if (state.streamingResponseText.isNotEmpty && state.streamingResponseText != '...') {
             final aiMessage = AiChatMessageEntity(
               messageId: 'ai_${DateTime.now().millisecondsSinceEpoch}_cancelled',
               content: state.streamingResponseText + " (用户取消)",
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
       print("[AiChatBloc] Exception while cancelling chat generation: $e");
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
    // Check if a conversation is selected
    final currentConvId = state.selectedConversationId;
    if (currentConvId == null) {
      // Cannot fetch recommendations without a selected conversation
      emit(state.copyWith(
         recommendationsStatus: RecommendationsStatus.error,
         recommendationsErrorMessage: 'Please select a conversation first.',
         clearRecommendationsErrorMessage: false // Ensure flag is handled correctly
       ));
      return;
    }

    // Emit loading state
    emit(state.copyWith(
       recommendationsStatus: RecommendationsStatus.loading,
       clearRecommendationsErrorMessage: true // Clear previous error
    ));

    // Call the use case
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(recommendationsStatus: RecommendationsStatus.error, recommendationsErrorMessage: 'User not authenticated or invalid ID format'));
      return;
    }
    
    // 获取当前会话的最新消息ID
    int? latestMessageId;
    if (state.messages.isNotEmpty) {
      // 尝试从消息列表中获取最新的消息ID
      for (var msg in state.messages.reversed) {
        // 检查messageId是否可以转换为整数
        if (msg.messageId != null && int.tryParse(msg.messageId!) != null) {
          latestMessageId = int.parse(msg.messageId!);
          break;
        }
      }
    }
    
    print("[AiChatBloc] 推荐请求参数: userId=$userId, conversationId=$currentConvId, messageId=$latestMessageId");
    
    final result = await _getRelatedServices(GetRelatedServicesParams(
      conversationId: currentConvId,
      userId: userId,
      // 如果有最新消息ID，就用它，否则不传
      messageId: latestMessageId,
      limit: 10 // 设置默认限制
    ));

    // Handle the result
    result.fold(
      (failure) => emit(state.copyWith(
         recommendationsStatus: RecommendationsStatus.error,
         recommendationsErrorMessage: failure.toString(), // Use failure message
         clearRecommendationsErrorMessage: false
       )),
      (recommendations) => emit(state.copyWith(
         recommendationsStatus: RecommendationsStatus.loaded,
         recommendations: recommendations, // Update the list
         clearRecommendationsErrorMessage: true // Clear error on success
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

     // 获取用户ID
     final userId = await _getCurrentUserId();
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
         print('Allocation successful: $summary'); 
         
         // 发射成功状态
         emit(state.copyWith(
            status: AiChatStatus.allocationSuccess,
           serviceAllocationStatus: successStatus,
            // errorMessage: '服务已成功分发给商家'
         ));
         
         // 后台异步处理发送消息，不再使用结果更新UI状态
         _sendAllocationMessageToMerchant(
           event.merchantId, 
           event.item, 
           summary
         ).catchError((e) {
           print('向商家发送消息失败(不影响UI状态): $e');
         });
       }
     } catch (e, stackTrace) {
       print('分发处理中发生未处理异常: $e');
       print(stackTrace);
       
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
      print("[AiChatBloc] 流式响应结束，当前状态: ${state.status}, 文本长度: ${state.streamingResponseText.length}");
      
      // Add the complete streamed message as a final AI message
     _addFinalAiMessageFromStream(emit);
      
     // Set success state (or idle if preferred)
     emit(state.copyWith(
         status: AiChatStatus.messageSendSuccess, // Or AiChatStatus.idle
         streamingResponseText: '', // Clear stream text on completion
     ));
      
      print("[AiChatBloc] 流式响应处理完成，最终状态: ${state.status}, 消息数: ${state.messages.length}");
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
    print("AiChatBloc closed, stream subscription cancelled.");
    return super.close();
  }

  // 提取发送消息给商家的逻辑到单独的方法
  Future<void> _sendAllocationMessageToMerchant(
    int merchantId, 
    Map<String, dynamic> item,
    String summary
  ) async {
    try {
      print('准备发送消息给商家ID: $merchantId, 商品: ${item['name']}');
           
      // 创建新的Dio实例并设置基础URL和超时配置
      final dio = Dio(BaseOptions(
        baseUrl: "http://app.duoshaokankan.com/prod-api",
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
      print("发送创建聊天室请求...");
           
      // 构建创建聊天室的请求参数
      final createRoomParams = {
        'doctorId': merchantId.toString(),
        'type': 'MEMBER',
      };
           
      // 如果item中包含商品ID，添加到请求参数中
      if (item['id'] != null) {
        createRoomParams['productId'] = item['id'];
      }
           
      print("创建聊天室请求参数: $createRoomParams");
           
      final createRoomResponse = await dio.post(
        '/api/chat/addChat',
        data: createRoomParams,
        options: options
      );
           
      print("创建聊天室响应状态码: ${createRoomResponse.statusCode}");
      print("创建聊天室响应数据: ${createRoomResponse.data}");
           
      if (createRoomResponse.statusCode == 200 && 
          createRoomResponse.data != null && 
          createRoomResponse.data['code'] == 200) {
           
        final chatRoomData = createRoomResponse.data['data'];
        final chatId = chatRoomData['id']; // 从聊天室对象中提取id字段
        print('成功创建聊天室，ID: $chatId');
           
        // 第二步：发送消息
        print("发送消息请求...");
           
        // 构建一个更丰富的消息，包含服务名称和AI分析的总结
        String messageContent = summary;
           
        // 构建发送消息的请求参数
        final sendMessageParams = {
          'chatId': chatId,
          'context': messageContent,
          'type': 'allocate',
        };
           
        print("发送消息请求参数: $sendMessageParams");
           
        final sendMsgResponse = await dio.post(
          '/common/chat/message/add',
          data: sendMessageParams,
          options: options
        );
           
        print("发送消息响应状态码: ${sendMsgResponse.statusCode}");
        print("发送消息响应数据: ${sendMsgResponse.data}");
           
        if (sendMsgResponse.statusCode == 200 && 
            sendMsgResponse.data != null && 
            sendMsgResponse.data['code'] == 200) {
          print('消息已成功发送给商家!');
        } else {
          print('发送消息API返回错误: ${sendMsgResponse.data}');
        }
      } else {
        print('创建聊天室API返回错误: ${createRoomResponse.data}');
      }
    } catch (e) {
      print('向商家发送消息失败: $e');
    }
  }

  // --- Handler for Optimized Allocation Action ---
  Future<void> _onTriggerOptimizedAllocation(
    TriggerOptimizedAllocation event,
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

      // 获取用户ID
      final userId = await _getCurrentUserId();
      if (userId == null) {
        final failureStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
        failureStatus[event.serviceId] = AllocationStatus.failure;
      
        emit(state.copyWith(
          status: AiChatStatus.allocationFailure, 
          errorMessage: '用户未认证或ID格式无效',
          serviceAllocationStatus: failureStatus
        ));
        return;
      }
      
      // 调用优化分配用例
      final result = await _optimizedAllocation(OptimizedAllocationParams(
        conversationId: currentConvId,
        userId: userId,
        item: event.item,
        merchantId: event.merchantId,
      ));

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
              print('向商家发送消息失败(不影响UI状态): $e');
            });
          }
        }
      );
    } catch (e, stackTrace) {
      print('优化分发处理中发生未处理异常: $e');
      print(stackTrace);
      
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
        
        print('[AiChatBloc] 标题更新成功: ${event.conversationId} -> $updatedTitle');
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
        
        print('[AiChatBloc] AI标题生成成功: ${event.conversationId} -> $generatedTitle');
      },
    );
  }
} 