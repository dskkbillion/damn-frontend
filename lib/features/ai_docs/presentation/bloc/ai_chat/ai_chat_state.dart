part of 'ai_chat_bloc.dart';

/// Represents the status of AI chat operations (main chat area).
enum AiChatStatus {
  initial, // Initial state before loading
  loadingHistory, // Loading historical messages
  historyLoadSuccess, // Successfully loaded history
  historyLoadFailure, // Failed to load history
  sendingMessage, // Uploading files (if any) and sending message
  streamingResponse, // AI is generating and streaming response
  messageSendSuccess, // AI finished responding successfully
  messageSendFailure, // Failed to send message or stream response
  loadingRecommendations, // Loading related services
  recommendationsLoadSuccess, // Loaded related services
  recommendationsLoadFailure, // Failed to load related services
  allocatingResource, // Triggering allocation
  allocationSuccess, // Allocation successful
  allocationFailure, // Allocation failed
  transcribingAudio, // Transcribing audio
  transcriptionSuccess, // Transcription successful
  transcriptionFailure, // Transcription failed
}

/// Represents the status of the conversation list loading operation.
enum ConversationsStatus {
   initial,
   loading,
   loaded,
   error,
}

/// Represents the status of the recommendations loading operation.
enum RecommendationsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// {@template ai_chat_state}
/// Represents the state of the AI chat feature.
/// {@endtemplate}
class AiChatState extends Equatable {
  /// The current status of chat operations.
  final AiChatStatus status;
  /// The list of messages in the current conversation.
  final List<AiChatMessageEntity> messages;
  /// Flag indicating if there are more historical messages to load.
  final bool hasMoreHistory;
  /// The current text being streamed from the AI.
  final String streamingResponseText;
  /// An error message if the last operation failed.
  final String? errorMessage;

  /// Conversation list state
  final ConversationsStatus conversationsStatus;
  final List<AiConversationEntity> conversations;
  final int? selectedConversationId;
  final String? conversationListErrorMessage;

  /// The list of recommended services.
  final List<RelatedServiceEntity> recommendations;

  /// --- New fields for recommendations state ---
  final RecommendationsStatus recommendationsStatus;
  final String? recommendationsErrorMessage;

  /// {@macro ai_chat_state}
  const AiChatState({
    this.status = AiChatStatus.initial,
    this.messages = const [],
    this.hasMoreHistory = true, // Assume more history initially
    this.streamingResponseText = '',
    this.errorMessage,
    this.conversationsStatus = ConversationsStatus.initial,
    this.conversations = const [],
    this.selectedConversationId,
    this.conversationListErrorMessage,
    this.recommendationsStatus = RecommendationsStatus.initial,
    this.recommendations = const [],
    this.recommendationsErrorMessage,
  });

  /// Creates a copy of the current state with updated values.
  AiChatState copyWith({
    AiChatStatus? status,
    List<AiChatMessageEntity>? messages,
    bool? hasMoreHistory,
    String? streamingResponseText,
    String? errorMessage,
    ConversationsStatus? conversationsStatus,
    List<AiConversationEntity>? conversations,
    int? selectedConversationId,
    Object? selectedConversationIdOrNull = const Object(),
    String? conversationListErrorMessage,
    RecommendationsStatus? recommendationsStatus,
    List<RelatedServiceEntity>? recommendations,
    String? recommendationsErrorMessage,
    bool clearErrorMessage = false,
    bool clearConversationListErrorMessage = false,
    bool clearRecommendationsErrorMessage = false,
  }) {
    final newSelectedId = selectedConversationIdOrNull == const Object() 
                              ? this.selectedConversationId 
                              : selectedConversationIdOrNull as int?;
    return AiChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      streamingResponseText: streamingResponseText ?? this.streamingResponseText,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversations: conversations ?? this.conversations,
      selectedConversationId: newSelectedId,
      conversationListErrorMessage: clearConversationListErrorMessage 
                                        ? null 
                                        : conversationListErrorMessage ?? this.conversationListErrorMessage,
      recommendationsStatus: recommendationsStatus ?? this.recommendationsStatus,
      recommendations: recommendations ?? this.recommendations,
      recommendationsErrorMessage: clearRecommendationsErrorMessage 
                                        ? null 
                                        : recommendationsErrorMessage ?? this.recommendationsErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        hasMoreHistory,
        streamingResponseText,
        errorMessage,
        conversationsStatus,
        conversations,
        selectedConversationId,
        conversationListErrorMessage,
        recommendationsStatus,
        recommendations,
        recommendationsErrorMessage,
      ];
} 