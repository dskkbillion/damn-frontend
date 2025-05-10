import 'dart:async';
import 'dart:io';
import 'dart:convert'; // For jsonDecode in stream handling
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Secure Storage
import 'package:dio/dio.dart';

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
    on<FetchRecommendations>(_onFetchRecommendations); 
    on<TriggerAllocationAction>(_onTriggerAllocationAction); 
    // Internal Stream Handling
    on<_ReceiveStreamChunk>(_onReceiveStreamChunk); 
    on<_HandleStreamError>(_onHandleStreamError); 
    on<_HandleStreamDone>(_onHandleStreamDone); 
    // Image Handling - Add handler for removal
    on<RemovePendingImage>(_onRemovePendingImage);
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
    final idToDelete = state.selectedConversationId;
    if (idToDelete == null) return; // Nothing selected

    // Indicate loading in the conversation list sidebar
    emit(state.copyWith(conversationsStatus: ConversationsStatus.loading));
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(conversationsStatus: ConversationsStatus.error, conversationListErrorMessage: 'User not authenticated or invalid ID format'));
      return;
    }
    final result = await _deleteConversation(DeleteConversationParams(conversationId: idToDelete, userId: userId));

    result.fold(
      (failure) => emit(state.copyWith(
        conversationsStatus: ConversationsStatus.error,
        conversationListErrorMessage: 'Failed to delete conversation: ${failure.toString()}',
      )),
      (_) {
        // Successfully deleted, clear selection and main chat area
        emit(state.copyWith(
          selectedConversationIdOrNull: null, // Clear selection
          status: AiChatStatus.initial, // Reset main chat status
          messages: [], 
          recommendations: [],
          streamingResponseText: '',
          clearErrorMessage: true,
          // Keep conversation list status loading until refreshed
        ));
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
    // --- Require non-empty text message --- 
    if (event.message.trim().isEmpty) {
        print("Cannot send empty message text.");
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
    // 1. Set status to indicate processing
    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

    // 获取文件大小并记录
    final fileSize = await event.audioFile.length();
    print('准备上传的音频文件大小: ${fileSize / 1024} KB, 路径: ${event.audioFile.path}');
    
    // 检查文件大小，如果过大则给出警告
    if (fileSize > 3 * 1024 * 1024) { // 超过3MB
      print('警告: 音频文件大小超过3MB，可能导致上传超时');
    }

    // 2. 获取用户ID
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: '用户ID未找到，无法上传音频'));
      return;
    }

    // 3. 上传音频文件 - 添加重试逻辑
    int retryCount = 0;
    const maxRetries = 2;
    late Either<Failure, String> uploadResult;
    
    while (retryCount <= maxRetries) {
      if (retryCount > 0) {
        print('正在重试音频上传 (${retryCount}/${maxRetries})...');
        emit(state.copyWith(status: AiChatStatus.sendingMessage, errorMessage: '正在重试音频上传 (${retryCount}/${maxRetries})...'));
        // 在重试前等待一段时间
        await Future.delayed(Duration(seconds: 1));
      }
      
      try {
        // 尝试上传文件
        uploadResult = await _uploadFile(UploadFileParams(file: event.audioFile));

        // 如果上传成功，跳出循环
        if (uploadResult.isRight()) {
          break;
        } else {
          // 如果是超时错误，重试
          final failure = uploadResult.fold(
            (failure) => failure,
            (_) => null, // 不可能运行到这里
          );
          
          if (failure.toString().contains('系统请求超时') || 
              failure.toString().contains('timeout') ||
              failure.toString().contains('500')) {
            print('音频上传超时，准备重试');
            retryCount++;
            continue;
          } else {
            // 其他类型的错误不重试
            break;
          }
        }
      } catch (e) {
        print('音频上传异常: $e');
        uploadResult = Left(GeneralFailure(message: e.toString()));
        retryCount++;
        continue;
      }
    }

    // 4. 处理上传结果
    await uploadResult.fold(
      // 4.1 处理上传失败
      (failure) async {
        print('音频上传失败: $failure');
        
        // 显示友好的错误提示
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
          errorMessage: errorMessage,
        ));
      },
      // 4.2 处理上传成功
      (audioOssUrl) async {
        print('音频上传成功，URL: $audioOssUrl');
        
        // 创建音频消息实体
        final audioMessage = AiChatMessageEntity(
           messageId: 'audio_user_${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.user,
          conversationId: state.selectedConversationId ?? -1,
           timestamp: DateTime.now(),
           messageType: MessageType.audio,
           fileUrls: [audioOssUrl], 
          content: '[语音消息]' // 添加占位符文本
        );

        // 更新UI显示音频消息
        emit(state.copyWith(
           messages: List.from(state.messages)..add(audioMessage), 
          status: AiChatStatus.historyLoadSuccess,
           clearErrorMessage: true,
        ));
        
        // 可选：尝试调用语音转文字服务
        // TODO: 实现语音转文字
      },
    );
  }


  // --- Internal Stream Handlers (Updated) ---
  void _onReceiveStreamChunk(_ReceiveStreamChunk event, Emitter<AiChatState> emit) {
    print("[AiChatBloc] 收到流式数据块: ${event.chunk}");
    
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
      // Append chunk to current generation
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
     final currentConvId = state.selectedConversationId;
     if (currentConvId == null) {
       emit(state.copyWith(status: AiChatStatus.allocationFailure, errorMessage: 'No conversation selected for allocation'));
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
       updatedAllocationStatus[event.serviceId] = AllocationStatus.failure;
       
       emit(state.copyWith(
         status: AiChatStatus.allocationFailure, 
         errorMessage: 'User not authenticated or invalid ID format',
         serviceAllocationStatus: updatedAllocationStatus
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

     result.fold(
       (failure) {
         // 更新分发状态为失败
         final updatedStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
         updatedStatus[event.serviceId] = AllocationStatus.failure;
         
         emit(state.copyWith(
         status: AiChatStatus.allocationFailure,
         errorMessage: failure.toString(),
           serviceAllocationStatus: updatedStatus
         ));
       },
       (allocationResult) async {
         // 分发成功，更新状态
         final updatedStatus = Map<int, AllocationStatus>.from(state.serviceAllocationStatus);
         updatedStatus[event.serviceId] = AllocationStatus.success;
         
         // 获取AI生成的专业需求总结
         final summary = allocationResult.summary;
         print('Allocation successful: $summary'); 
         
         emit(state.copyWith(
            status: AiChatStatus.allocationSuccess,
            serviceAllocationStatus: updatedStatus,
            errorMessage: '服务已成功分发给商家'
         ));
         
         // 在这里调用消息发送API给商家
         String finalMessage = '服务已成功分发给商家';
         
         try {
           print('准备发送消息给商家ID: ${event.merchantId}, 商品: ${event.item['name']}');
           
           // 创建新的Dio实例并设置基础URL
           final dio = Dio();
           dio.options.baseUrl = "http://app.duoshaokankan.com/prod-api";
           
           // 获取认证令牌
           final String? authToken = await _storage.read(key: 'auth_token');
           if (authToken == null || authToken.isEmpty) {
             throw Exception('认证令牌不存在或为空');
           }
           
           // 添加必要的请求头信息 (关键修复)
           final options = Options(
             contentType: Headers.jsonContentType,
             responseType: ResponseType.json,
             headers: {
               'Content-Type': 'application/json',
               'clienttype': '1',  // 添加必要的请求头
               'client': Platform.isAndroid ? 'android' : 'ios',
               'version': '100',
               'packageName': 'com.duoshaokankan.dskk', // 包名添加到请求头
               'versionCode': '1.0.0', // 版本号添加到请求头
               'versionName': '1.0.0', // 版本名称添加到请求头
               'Authorization': 'Bearer $authToken', // 添加认证令牌
             },
           );
           
           // 第一步：创建聊天室
           print("发送创建聊天室请求...");
           
           // 构建创建聊天室的请求参数 (只保留必要参数)
           final createRoomParams = {
             'doctorId': event.merchantId.toString(),
             'type': 'MEMBER',
           };
           
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
             
             final chatId = createRoomResponse.data['data'];
             print('成功创建聊天室，ID: $chatId');
             
             // 第二步：发送消息
             print("发送消息请求...");
             
             // 构建一个更丰富的消息，包含服务名称和AI分析的总结
             String messageContent = "用户对\"${event.item['name']}\"服务感兴趣。\n\n专业需求分析:\n$summary";
             
             // 构建发送消息的请求参数
             final sendMessageParams = {
               'chatId': chatId,
               'context': messageContent, // 使用分发返回的专业总结作为消息内容
               'type': 'text',
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
               finalMessage = '消息已发送到商家的聊天窗口，请到"聊天"页面查看';
             } else {
               print('发送消息API返回错误: ${sendMsgResponse.data}');
               finalMessage = '分发成功，但发送消息失败: ${sendMsgResponse.data?['msg'] ?? '未知错误'}';
             }
           } else {
             print('创建聊天室API返回错误: ${createRoomResponse.data}');
             finalMessage = '分发成功，但创建聊天失败: ${createRoomResponse.data?['msg'] ?? '未知错误'}';
           }
         } catch (e) {
           print('向商家发送消息失败: $e');
           finalMessage = '分发成功，但发送消息时发生错误: $e';
         }
         
         // 只有当emitter没有完成时才发送最终状态
         if (!emit.isDone) {
           emit(state.copyWith(
             status: AiChatStatus.allocationSuccess,
             errorMessage: finalMessage
           ));
         }
       },
     );
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
} 