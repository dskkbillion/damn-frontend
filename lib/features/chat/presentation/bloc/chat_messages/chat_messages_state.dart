import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

/// 聊天消息状态基类
abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();
  
  @override
  List<Object?> get props => [];
}

/// 初始状态
class MessagesInitial extends ChatMessagesState {
  const MessagesInitial();
}

/// 加载中状态
class MessagesLoading extends ChatMessagesState {
  /// 是否在加载更多
  final bool isLoadingMore;

  const MessagesLoading({
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [isLoadingMore];
}

/// 已加载状态
class MessagesLoaded extends ChatMessagesState {
  /// 消息列表
  final List<Message> messages;
  
  /// 会话ID
  final String sessionId;
  
  /// 是否还有更多消息
  final bool hasMore;

  const MessagesLoaded({
    required this.messages,
    required this.sessionId,
    this.hasMore = true,
  });

  /// 创建更新后的状态
  MessagesLoaded copyWith({
    List<Message>? messages,
    String? sessionId,
    bool? hasMore,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      sessionId: sessionId ?? this.sessionId,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [messages, sessionId, hasMore];
}

/// 错误状态
class MessagesError extends ChatMessagesState {
  /// 错误消息
  final String message;

  const MessagesError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// 消息发送中状态
class MessageSending extends ChatMessagesState {
  /// 正在发送的消息
  final Message message;

  const MessageSending({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// 消息发送成功状态
class MessageSent extends ChatMessagesState {
  /// 已发送的消息
  final Message message;

  const MessageSent({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// 消息发送失败状态
class MessageSendFailed extends ChatMessagesState {
  /// 发送失败的消息
  final Message message;
  
  /// 错误消息
  final String errorMessage;

  const MessageSendFailed({
    required this.message,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [message, errorMessage];
}

/// 消息操作成功状态
class MessageActionSuccess extends ChatMessagesState {
  /// 操作类型
  final String actionType;
  
  /// 消息ID
  final String messageId;

  const MessageActionSuccess({
    required this.actionType,
    required this.messageId,
  });

  @override
  List<Object?> get props => [actionType, messageId];
} 