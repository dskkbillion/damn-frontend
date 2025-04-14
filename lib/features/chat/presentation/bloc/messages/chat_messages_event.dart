import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/message.dart';

part of 'chat_messages_bloc.dart';

/// ChatMessagesBloc 的事件
abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial messages for a specific chat.
class LoadMessages extends ChatMessagesEvent {
  final int chatId;
  // TODO: Add pagination parameters if API supports it (e.g., lastMessageId, limit)

  const LoadMessages(this.chatId);

  @override
  List<Object> get props => [chatId];
}

/// Event triggered when the underlying message data stream updates.
class _MessagesUpdated extends ChatMessagesEvent {
  final List<Message> messages;

  const _MessagesUpdated(this.messages);

  @override
  List<Object> get props => [messages];
}

/// Event triggered when a single new message is received (e.g., from WebSocket).
class NewMessageReceived extends ChatMessagesEvent {
  final Message message;

  const NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

/// Event to send a new message.
class SendMessage extends ChatMessagesEvent {
  final Message message; // Contains localId, content, type, sender, etc.

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

/// Event triggered internally after a message send attempt (success or failure).
class _MessageSendStatusUpdated extends ChatMessagesEvent {
  final String localId;
  final MessageStatus status;
  final int? serverId; // ID assigned by the server on success
  final DateTime? createTime; // Timestamp from server on success

  const _MessageSendStatusUpdated({
     required this.localId,
     required this.status,
     this.serverId,
     this.createTime,
  });

  @override
  List<Object?> get props => [localId, status, serverId, createTime];
}

/// Event to retry sending a previously failed message.
class RetrySendMessage extends ChatMessagesEvent {
  final Message failedMessage; // The message object that failed

  const RetrySendMessage(this.failedMessage);

   @override
  List<Object> get props => [failedMessage];
}

/// Event to revoke a message.
class RevokeMessage extends ChatMessagesEvent {
  final int messageId;

  const RevokeMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

/// Event triggered internally when a message revocation status updates.
class _MessageRevoked extends ChatMessagesEvent {
   final int messageId;
   final bool success; // Indicates if the revoke operation was successful

   const _MessageRevoked(this.messageId, {required this.success});

   @override
   List<Object> get props => [messageId, success];
}

/// 标记会话为已读事件
class MarkChatAsRead extends ChatMessagesEvent {
   final int chatId;

  const MarkChatAsRead(this.chatId);

   @override
  List<Object?> get props => [chatId];
}

/// 内部事件：实时收到新消息
class _ReceivedNewMessage extends ChatMessagesEvent {
  final Message message;

  const _ReceivedNewMessage(this.message);

  @override
  List<Object?> get props => [message];
}

// Internal event for handling errors from streams
class _MessagesErrorEvent extends ChatMessagesEvent {
  const _MessagesErrorEvent();
} 