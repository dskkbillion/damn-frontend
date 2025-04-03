import 'dart:async';
import 'dart:io';
import 'dart:convert'; // For jsonDecode in stream handling
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

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

  // Internal state - Replace with state properties where possible
  // int? _currentConversationId; // REMOVE - Use state.selectedConversationId instead
  final int _currentUserId = 123; // TODO: Replace with actual user ID from auth service
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
    // Start with initial state containing defaults for new properties
  ) : super(const AiChatState()) { 
    // --- Register event handlers ---
    // Conversation List Management
    on<LoadConversations>(_onLoadConversations);
    on<SelectConversation>(_onSelectConversation);
    on<CreateNewConversation>(_onCreateNewConversation);
    on<DeleteSelectedConversation>(_onDeleteSelectedConversation);
    // Chat Interactions
    on<SendMessage>(_onSendMessage);
    on<SendVoiceMessage>(_onSendVoiceMessage); 
    on<CancelStreaming>(_onCancelStreaming); 
    on<FetchRecommendations>(_onFetchRecommendations); 
    on<TriggerAllocationAction>(_onTriggerAllocationAction); 
    // Internal Stream Handling
    on<_ReceiveStreamChunk>(_onReceiveStreamChunk); 
    on<_HandleStreamError>(_onHandleStreamError); 
  }

  // --- Conversation List Handlers ---

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<AiChatState> emit,
  ) async {
     // Indicate loading state for the conversation list
     emit(state.copyWith(conversationsStatus: ConversationsStatus.loading));
     final result = await _getConversations(GetConversationsParams(userId: _currentUserId));
     result.fold(
       (failure) => emit(state.copyWith(
           conversationsStatus: ConversationsStatus.error,
           // Use the dedicated error message field for conversation list errors
           conversationListErrorMessage: failure.toString(),
        )),
       (conversations) => emit(state.copyWith(
           conversationsStatus: ConversationsStatus.loaded,
           conversations: conversations,
           // Clear conversation list error on success
           clearConversationListErrorMessage: true,
       )),
     );
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
    final historyResult = await _loadHistory(LoadHistoryParams(
      conversationId: event.conversationId,
      userId: _currentUserId,
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
    final result = await _createConversation(CreateConversationParams(userId: _currentUserId, title: event.title));

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
    final result = await _deleteConversation(DeleteConversationParams(conversationId: idToDelete, userId: _currentUserId));

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
       // Optionally emit a temporary state or just ignore
       return;
     }

    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

    String? uploadedImageUrl;
    if (event.imageFile != null) {
      final uploadResult = await _uploadFile(UploadFileParams(file: event.imageFile!));
      bool uploadOk = false;
      uploadResult.fold(
        (failure) {
          emit(state.copyWith(status: AiChatStatus.messageSendFailure, errorMessage: 'File upload failed: ${failure.toString()}'));
        },
        (url) {
          uploadedImageUrl = url;
          uploadOk = true;
          print("File uploaded successfully: $url");
        },
      );
      if (!uploadOk) return; // Stop if upload failed
    }

    // Optimistic UI update for user message
    final userMessage = AiChatMessageEntity(
        messageId: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
        content: event.message,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        conversationId: currentConversationId,
        fileUrls: uploadedImageUrl == null ? null : [uploadedImageUrl!], 
    );
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: AiChatStatus.streamingResponse, 
      streamingResponseText: '...',
    ));

    // Call streaming use case
    await _chatStreamSubscription?.cancel();
    final streamResult = await _streamChatCompletion(StreamChatCompletionParams(
      conversationId: currentConversationId,
      userId: _currentUserId,
      message: event.message,
      fileUrls: uploadedImageUrl == null ? [] : [uploadedImageUrl!], 
    ));

    streamResult.fold(
      (failure) {
         add(_HandleStreamError('Error initiating stream: ${failure.toString()}'));
      },
      (stream) {
        _chatStreamSubscription = stream.listen(
          (chunk) {
              try {
                 final decoded = jsonDecode(chunk);
                 final content = decoded['chunk'] ?? ''; 
                 add(_ReceiveStreamChunk(content));
              } catch (e) {
                 print("Error decoding stream chunk: $e. Chunk: $chunk");
                 add(_HandleStreamError("Error processing stream data.")); 
              }
          },
          onError: (error) {
             add(_HandleStreamError(error.toString()));
          },
          onDone: () {
             add(const _ReceiveStreamChunk('', isDone: true)); 
          },
          cancelOnError: true,
        );
      },
    );
  }

  Future<void> _onSendVoiceMessage(
    SendVoiceMessage event,
    Emitter<AiChatState> emit,
  ) async {
    // 1. Set status to indicate processing (maybe still transcribing, or a new 'uploadingAudio'?) 
    // Using sendingMessage for now, maybe refine later.
    emit(state.copyWith(status: AiChatStatus.sendingMessage, clearErrorMessage: true));

    // 2. Upload the audio file
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
     // Reset streaming state and show error
     emit(state.copyWith(
        status: AiChatStatus.messageSendFailure,
        streamingResponseText: '', 
        errorMessage: 'Streaming error: ${event.errorMessage}',
      ));
     _chatStreamSubscription?.cancel(); 
     _chatStreamSubscription = null;
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
    final result = await _getRelatedServices(GetRelatedServicesParams(
      conversationId: currentConvId,
      userId: _currentUserId,
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
     final result = await _allocateChatResource(AllocateChatResourceParams(
        conversationId: currentConvId,
        userId: _currentUserId,
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


  // --- Cleanup ---
  @override
  Future<void> close() {
    _chatStreamSubscription?.cancel();
    print("AiChatBloc closed");
    return super.close();
  }
} 