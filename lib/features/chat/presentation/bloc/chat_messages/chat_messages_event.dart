part of 'chat_messages_bloc.dart';

@immutable
abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load messages for a specific chat room
class LoadChatMessages extends ChatMessagesEvent {
  final int chatId;

  const LoadChatMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

/// Event to load more messages for a specific chat room
// class LoadMoreChatMessages extends ChatMessagesEvent {
//   final int chatId;
//   final int pageNum;
//   final int pageSize;
// 
//   const LoadMoreChatMessages({
//     required this.chatId,
//     required this.pageNum,
//     required this.pageSize,
//   });
// 
//   @override
//   List<Object?> get props => [chatId, pageNum, pageSize];
// }

/// Event to send a message
class SendMessageRequested extends ChatMessagesEvent {
  final String type; // 'text', 'image', 'audio'
  final String? text; // Required if type is 'text'
  final File? file; // Required if type is 'image' or 'audio'

  const SendMessageRequested({required this.type, this.text, this.file})
      : assert(type == 'text' ? text != null : file != null);

  @override
  List<Object?> get props => [type, text, file];
}

/// Event triggered when a new message is received (e.g., via WebSocket)
class MessageReceived extends ChatMessagesEvent {
  final ChatMessage message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to request message revocation
class RevokeMessageRequested extends ChatMessagesEvent {
  final int messageId;

  const RevokeMessageRequested(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// Event to request message deletion
class DeleteMessageRequested extends ChatMessagesEvent {
  final List<int> messageIds;

  const DeleteMessageRequested(this.messageIds);

  @override
  List<Object?> get props => [messageIds];
}

// Internal event for WebSocket messages
class _MessageReceived extends ChatMessagesEvent {
  final ChatMessageDto messageDto;
  const _MessageReceived(this.messageDto);
   @override
  List<Object?> get props => [messageDto];
}

// Internal event for WebSocket status changes
class _ConnectionStatusChanged extends ChatMessagesEvent {
  final ConnectionStatus status;
  const _ConnectionStatusChanged(this.status);
   @override
  List<Object?> get props => [status];
} 