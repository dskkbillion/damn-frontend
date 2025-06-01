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
class LoadMoreHistory extends AiChatEvent {
  final int? page; // 可选的页码，如果不提供则使用当前页+1
  
  const LoadMoreHistory({this.page});
  
  @override
  List<Object?> get props => [page];
}

/// Event to scroll to bottom of chat
class ScrollToBottom extends AiChatEvent {
  const ScrollToBottom();
}

/// Event to fetch related service recommendations.
class FetchRelatedServices extends AiChatEvent {}

/// Event to trigger the chat allocation action.
class TriggerAllocationAction extends AiChatEvent {
  // 只保留需要的参数
  final Map<String, dynamic> item; // 服务/商品详情
  final int merchantId; // 商家ID
  final int serviceId; // 服务ID，用于状态追踪

  const TriggerAllocationAction({
    required this.item,
    required this.merchantId,
    required this.serviceId,
  }); 

  @override
  List<Object?> get props => [item, merchantId, serviceId];
}

/// Event to trigger the optimized allocation action (create chat room first, then AI allocation).
class TriggerOptimizedAllocation extends AiChatEvent {
  final Map<String, dynamic> item; // 服务/商品详情
  final int merchantId; // 商家ID
  final int serviceId; // 服务ID，用于状态追踪

  const TriggerOptimizedAllocation({
    required this.item,
    required this.merchantId,
    required this.serviceId,
  }); 

  @override
  List<Object?> get props => [item, merchantId, serviceId];
}

/// Event triggered when the user finishes recording audio.
class SendVoiceMessage extends AiChatEvent {
  final File audioFile; // Changed back to File based on Bloc usage - needs path later

  const SendVoiceMessage({required this.audioFile});

  @override
  List<Object?> get props => [audioFile];
}

/// Event triggered when the user wants to cancel ongoing chat generation.
class CancelChatGeneration extends AiChatEvent {
  const CancelChatGeneration();
}

/// Event triggered when the user wants to stop AI generation.
class CancelStreaming extends AiChatEvent {} // Renamed from StopGeneration

/// Event to fetch related service recommendations.
class FetchRecommendations extends AiChatEvent {}

/// Event to load the list of conversations.
class LoadConversations extends AiChatEvent {
  final int? page; // 可选的页码，如果不提供则使用第1页
  
  const LoadConversations({this.page});
  
  @override
  List<Object?> get props => [page];
}

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

/// Event to delete a conversation by ID.
/// If no conversationId is provided, deletes the currently selected conversation.
class DeleteSelectedConversation extends AiChatEvent {
  final int? conversationId; // 添加可选的conversationId参数
  
  const DeleteSelectedConversation({this.conversationId});
  
  @override
  List<Object?> get props => [conversationId];
}

/// Event to create a new conversation and immediately send a message.
class CreateNewConversationAndSendMessage extends AiChatEvent {
  final String message;
  
  const CreateNewConversationAndSendMessage({required this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Event to create a new conversation and immediately send a voice message.
class CreateNewConversationAndSendVoiceMessage extends AiChatEvent {
  final File audioFile;
  
  const CreateNewConversationAndSendVoiceMessage({required this.audioFile});
  
  @override
  List<Object?> get props => [audioFile];
}

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

/// (Internal) Event triggered when the AI stream finishes successfully.
class _HandleStreamDone extends AiChatEvent {
  const _HandleStreamDone();
  // No props needed for a simple completion signal
}

/// Event triggered to send a text message.
/// Uploaded image URLs will be fetched from the state.
class SendMessage extends AiChatEvent {
  final String message;
  // Removed imageFile field
  const SendMessage({required this.message});
  @override List<Object?> get props => [message];
}

/// Event triggered by the UI when the user picks an image.
class PickImage extends AiChatEvent {
  final File imageFile;
  const PickImage({required this.imageFile});
  @override List<Object?> get props => [imageFile];
}

/// (Internal) Event triggered when a background image upload succeeds.
class _ImageUploadSuccess extends AiChatEvent {
  final String originalFilePath; // Use file path as identifier
  final String uploadedUrl;
  const _ImageUploadSuccess({required this.originalFilePath, required this.uploadedUrl});
  @override List<Object?> get props => [originalFilePath, uploadedUrl];
}

/// (Internal) Event triggered when a background image upload fails.
class _ImageUploadFailure extends AiChatEvent {
  final String originalFilePath; // Use file path as identifier
  final String error;
  const _ImageUploadFailure({required this.originalFilePath, required this.error});
  @override List<Object?> get props => [originalFilePath, error];
}

/// Event triggered by the UI to remove a pending image before sending.
class RemovePendingImage extends AiChatEvent {
  final String imagePathToRemove; // Use file path as identifier
  const RemovePendingImage({required this.imagePathToRemove});
  @override List<Object?> get props => [imagePathToRemove];
}

/// Event to manually update a conversation title.
class UpdateConversationTitle extends AiChatEvent {
  final int conversationId;
  final String title;
  
  const UpdateConversationTitle({
    required this.conversationId,
    required this.title,
  });
  
  @override
  List<Object?> get props => [conversationId, title];
}

/// Event to generate a conversation title using AI.
class GenerateConversationTitle extends AiChatEvent {
  final int conversationId;
  
  const GenerateConversationTitle({
    required this.conversationId,
  });
  
  @override
  List<Object?> get props => [conversationId];
}

/// Event triggered when the user scrolls to load more conversations.
class LoadMoreConversations extends AiChatEvent {
  final int? page; // 可选的页码，如果不提供则使用当前页+1
  
  const LoadMoreConversations({this.page});
  
  @override
  List<Object?> get props => [page];
}

/// Event to refresh conversations list (pull to refresh).
class RefreshConversations extends AiChatEvent {
  const RefreshConversations();
}

/// 查询频率限制状态事件
class FetchRateLimitStatus extends AiChatEvent {
  final int userId;
  
  const FetchRateLimitStatus({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

/// 重置频率限制事件（管理员功能）
class ResetRateLimit extends AiChatEvent {
  final int userId;
  final String? serviceType;
  final String? ruleName;
  
  const ResetRateLimit({
    required this.userId,
    this.serviceType,
    this.ruleName,
  });
  
  @override
  List<Object?> get props => [userId, serviceType, ruleName];
} 