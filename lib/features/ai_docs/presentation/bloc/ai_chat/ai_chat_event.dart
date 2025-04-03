part of 'ai_chat_bloc.dart';

/// Base class for all AI Chat events.
abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the chat for a specific conversation.
class InitializeChat extends AiChatEvent {
  final int conversationId;
  final int userId;
  // final String? initialMessage; // Optional: if starting a new chat with a message

  const InitializeChat({required this.conversationId, required this.userId});

  @override
  List<Object?> get props => [conversationId, userId];
}

/// Event triggered when the user scrolls to the top to load older messages.
// REMOVED - API does not support pagination yet.
// class LoadMoreHistory extends AiChatEvent {}

/// Event to fetch related service recommendations.
class FetchRelatedServices extends AiChatEvent {}

/// Event to trigger the chat allocation action.
class TriggerAllocationAction extends AiChatEvent {
  // Match parameters needed by AllocateChatResourceParams
  final Map<String, dynamic> item; // The selected service/item details
  final int limit; // Placeholder, confirm if needed
  final double similarityThreshold; // Placeholder, confirm if needed

  const TriggerAllocationAction({
    required this.item,
    this.limit = 1, // Provide default or require from UI
    this.similarityThreshold = 0.8, // Provide default or require from UI
  }); 

  @override
  List<Object?> get props => [item, limit, similarityThreshold];
}

/// Event triggered when the user finishes recording audio.
class SendVoiceMessage extends AiChatEvent {
  final File audioFile; // Changed back to File based on Bloc usage - needs path later

  const SendVoiceMessage({required this.audioFile});

  @override
  List<Object?> get props => [audioFile];
}

/// Event triggered when the user wants to stop AI generation.
class CancelStreaming extends AiChatEvent {} // Renamed from StopGeneration

/// Event to fetch related service recommendations.
class FetchRecommendations extends AiChatEvent {}

/// Event to load the list of conversations.
class LoadConversations extends AiChatEvent {}

/// Event to select a conversation.
class SelectConversation extends AiChatEvent {
  final int conversationId;
  const SelectConversation(this.conversationId);
  @override List<Object?> get props => [conversationId];
}

/// Event to create a new conversation.
class CreateNewConversation extends AiChatEvent {
   final String? title; // Optional title for the new conversation
   const CreateNewConversation({this.title});
   @override List<Object?> get props => [title];
}

/// Event to delete the currently selected conversation.
/// Alternatively, could take a conversationId to delete any conversation.
class DeleteSelectedConversation extends AiChatEvent {}

/// Event triggered when the AI stream updates the response text.
/// (Internal event dispatched by the Bloc while listening to the stream)
class StreamResponseUpdated extends AiChatEvent {
  final String chunk;

  const StreamResponseUpdated(this.chunk);

  @override
  List<Object?> get props => [chunk];
}

/// Event triggered when the AI stream finishes successfully.
/// (Internal event dispatched by the Bloc when the stream closes)
class StreamResponseCompleted extends AiChatEvent {
  const StreamResponseCompleted();
}

/// Event triggered when an error occurs in the AI stream.
/// (Internal event dispatched by the Bloc on stream error)
class StreamResponseError extends AiChatEvent {
  final Object error;

  const StreamResponseError(this.error);

  @override
  List<Object?> get props => [error];
}

/// (Internal) Event triggered when the AI stream updates the response text.
class _ReceiveStreamChunk extends AiChatEvent {
  final String chunk;
  final bool isDone; // Flag to indicate the stream has finished

  const _ReceiveStreamChunk(this.chunk, {this.isDone = false});

  @override
  List<Object?> get props => [chunk, isDone];
}

/// (Internal) Event triggered when an error occurs in the AI stream.
class _HandleStreamError extends AiChatEvent {
  final String errorMessage;

  const _HandleStreamError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// Event triggered to send a text message (potentially with an image).
class SendMessage extends AiChatEvent {
  final String message;
  final File? imageFile; 
  const SendMessage({required this.message, this.imageFile});
  @override List<Object?> get props => [message, imageFile];
} 