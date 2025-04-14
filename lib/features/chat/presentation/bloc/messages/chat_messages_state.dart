part of 'chat_messages_bloc.dart';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/failure.dart';
import '../../../domain/entities/message.dart';

/// ChatMessagesBloc 的状态
abstract class ChatMessagesState extends Equatable {
  /// 当前显示的聊天消息列表
  final List<Message> messages;
  // TODO: Add pagination info if needed (e.g., hasReachedMax, isLoadingMore)

  const ChatMessagesState({this.messages = const []});

  @override
  List<Object> get props => [messages];
}

/// Initial state before messages for a chat are loaded.
class MessagesInitial extends ChatMessagesState {}

/// State while messages are being loaded (can hold previous data).
class MessagesLoading extends ChatMessagesState {
  const MessagesLoading(List<Message> messages) : super(messages: messages);
}

/// State when messages have been successfully loaded.
class MessagesLoaded extends ChatMessagesState {
  const MessagesLoaded(List<Message> messages) : super(messages: messages);
}

/// State when an error occurred while loading messages (can hold previous data).
class MessagesError extends ChatMessagesState {
  final Failure failure;

  const MessagesError(this.failure, List<Message> messages) : super(messages: messages);

  @override
  List<Object> get props => [failure, messages];
}

/// 消息发送中状态 (特定消息)
/// 可以通过更新消息列表中的特定消息的 sendStatus 来表示，而不是单独的状态
// class ChatMessageSending extends ChatMessagesState { ... } 