import 'dart:async';
import 'dart:io';
import 'dart:convert'; // For jsonDecode in stream handling
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Secure Storage

// Core
import '../../../../../core/error/failures.dart';

// Domain Layer
import '../../../domain/entities/ai_chat_message_entity.dart';
import '../../../domain/entities/ai_conversation_entity.dart';
import '../../../domain/entities/chat_allocation_result_entity.dart';
import '../../../domain/entities/related_service_entity.dart';
import '../../../domain/usecases/allocate_chat_resource_usecase.dart';
import '../../../domain/usecases/create_conversation_usecase.dart';
import '../../../domain/usecases/delete_conversation_usecase.dart';
import '../../../domain/usecases/get_conversations_usecase.dart';
import '../../../domain/usecases/get_related_services_usecase.dart';
import '../../../domain/usecases/load_history_usecase.dart';
import '../../../domain/usecases/stream_chat_completion_usecase.dart';
import '../../../domain/usecases/transcribe_audio_usecase.dart';
import '../../../domain/usecases/upload_file_usecase.dart';

// Move Exports Before Parts
export '../../../domain/entities/ai_conversation_entity.dart'; 
export '../../../domain/entities/ai_chat_message_entity.dart'; 
export '../../../domain/entities/related_service_entity.dart'; 

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
    final userIdString = await _storage.read(key: 'user_id');
    if (userIdString != null) {
      // Parse the string to int
      return int.tryParse(userIdString);
    }
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
            add(_ReceiveStreamChunk(chunk)); 
          },
          onError: (error) {
            add(_HandleStreamError(error.toString()));
            _chatStreamSubscription = null; 
          },
          onDone: () {
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
    // 1. Set status to indicate processing (maybe still transcribing, or a new 'uploadingAudio'?) 
    // Using sendingMessage for now, maybe refine later.
    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

    // 2. Upload the audio file
    final userId = await _getCurrentUserId();
    if (userId == null) {
      emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: 'User not authenticated or invalid ID format'));
      return;
    }
    final uploadResult = await _uploadFile(UploadFileParams(file: event.audioFile));

    await uploadResult.fold(
      // 2.1 Handle Upload Failure
      (failure) async {
        print('Audio upload failed: $failure');
        // Use messageSendFailure as the final state for sending attempt
        emit(state.copyWith(
          status: AiChatStatus.messageSendFailure, 
          errorMessage: 'Failed to upload audio: ${failure.toString()}',
        ));
      },
      // 2.2 Handle Upload Success -> Add Audio Message to State
      (audioOssUrl) async {
        print('Audio uploaded: $audioOssUrl');
        
        // 3. Create the Audio Message Entity
        final audioMessage = AiChatMessageEntity(
           // Generate a temporary unique ID
           messageId: 'audio_user_${DateTime.now().millisecondsSinceEpoch}',
           sender: MessageSender.user, // Assuming user sent the voice message
           conversationId: state.selectedConversationId ?? -1, // Use current conv ID
           timestamp: DateTime.now(),
           messageType: MessageType.audio,
           // Store the URL in fileUrls list
           fileUrls: [audioOssUrl], 
           // Content can be empty or a placeholder like "[Voice Message]"
           content: '' 
        );

        // 4. Add the message to the list and reset status
        emit(state.copyWith(
           // Add to the *end* of the list, ListView will reverse it
           messages: List.from(state.messages)..add(audioMessage), 
           // Set status back to indicate success/idle after sending
           status: AiChatStatus.historyLoadSuccess, // Or messageSendSuccess?
           clearErrorMessage: true,
        ));
      },
    );
  }


  // --- Internal Stream Handlers (Updated) ---
  void _onReceiveStreamChunk(_ReceiveStreamChunk event, Emitter<AiChatState> emit) {
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
       } // else: Stream might finish due to cancellation, state already handled by _onCancelStreaming
    } else {
      // Append chunk to current generation
      final newGeneration = (state.streamingResponseText == '...' ? '' : state.streamingResponseText) + event.chunk;
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
    final result = await _getRelatedServices(GetRelatedServicesParams(
      conversationId: currentConvId,
      userId: userId,
      // limit: 10 // Optional: Add limit if needed
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
     emit(state.copyWith(status: AiChatStatus.allocatingResource, clearErrorMessage: true));

     // Construct params using parameters from the event
     final userId = await _getCurrentUserId();
     if (userId == null) {
       emit(state.copyWith(status: AiChatStatus.allocationFailure, errorMessage: 'User not authenticated or invalid ID format'));
       return;
     }
     final result = await _allocateChatResource(AllocateChatResourceParams(
        conversationId: currentConvId,
        userId: userId,
        item: event.item, // Use item from event
        limit: event.limit, // Use limit from event
        similarityThreshold: event.similarityThreshold, // Use threshold from event
     ));

     result.fold(
       (failure) => emit(state.copyWith(
         status: AiChatStatus.allocationFailure,
         errorMessage: failure.toString(),
       )),
       (allocationResult) {
         // Access the correct field from ChatAllocationResultEntity
         print('Allocation successful: ${allocationResult.summary}'); 
         emit(state.copyWith(
            status: AiChatStatus.allocationSuccess,
            // Optionally store summary or merchantId if needed
            // errorMessage: allocationResult.summary, // Example: Show summary as info message
         ));
         // Optionally transition back to a stable state
         // Future.delayed(Duration(seconds: 2), () => emit(state.copyWith(status: AiChatStatus.historyLoadSuccess))); 
       },
     );
   }

  // --- Internal Event Handlers for Stream ---

  void _onHandleStreamDone(_HandleStreamDone event, Emitter<AiChatState> emit) {
      // Add the complete streamed message as a final AI message
     _addFinalAiMessageFromStream(emit);
     // Set success state (or idle if preferred)
     emit(state.copyWith(
         status: AiChatStatus.messageSendSuccess, // Or AiChatStatus.idle
         streamingResponseText: '', // Clear stream text on completion
     ));
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