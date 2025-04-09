import 'package:equatable/equatable.dart';

import '../../../domain/entities/message.dart';

/// 消息状态基类
abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

/// 消息初始状态
class MessageInitial extends MessageState {
  const MessageInitial();
}

/// 消息加载中状态
class MessagesLoading extends MessageState {
  /// 是否是首次加载
  final bool isInitialLoading;
  
  /// 是否是加载更多
  final bool isLoadingMore;

  const MessagesLoading({
    this.isInitialLoading = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [isInitialLoading, isLoadingMore];
}

/// 消息加载成功状态
class MessagesLoaded extends MessageState {
  /// 当前会话ID
  final String sessionId;
  
  /// 消息列表
  final List<Message> messages;
  
  /// 是否还有更多消息可加载
  final bool hasMore;
  
  /// 是否正在发送消息
  final bool isSending;
  
  /// 是否是初次加载
  final bool isInitialLoad;
  
  /// 当前用户ID
  final String currentUserId;

  const MessagesLoaded({
    required this.sessionId,
    required this.messages,
    this.hasMore = false,
    this.isSending = false,
    this.isInitialLoad = false,
    required this.currentUserId,
  });

  /// 创建新的状态实例，但部分字段值已更新
  MessagesLoaded copyWith({
    String? sessionId,
    List<Message>? messages,
    bool? hasMore,
    bool? isSending,
    bool? isInitialLoad,
    String? currentUserId,
  }) {
    return MessagesLoaded(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object> get props => [
        sessionId,
        messages,
        hasMore,
        isSending,
        isInitialLoad,
        currentUserId,
      ];
}

/// 消息操作中状态
class MessageActionInProgress extends MessageState {
  /// 正在执行的操作描述
  final String action;
  
  /// 操作的消息ID
  final String messageId;

  const MessageActionInProgress({
    required this.action,
    required this.messageId,
  });

  @override
  List<Object> get props => [action, messageId];
}

/// 消息操作失败状态
class MessageActionFailed extends MessageState {
  /// 错误消息
  final String message;
  
  /// 失败的消息ID
  final String? messageId;
  
  /// 失败的操作
  final String? action;

  const MessageActionFailed({
    required this.message,
    this.messageId,
    this.action,
  });

  @override
  List<Object?> get props => [message, messageId, action];
}

/// 消息加载失败状态
class MessagesLoadFailure extends MessageState {
  /// 错误消息
  final String message;
  
  /// 会话ID
  final String sessionId;

  const MessagesLoadFailure({
    required this.message,
    required this.sessionId,
  });

  @override
  List<Object> get props => [message, sessionId];
}

/// 消息发送成功状态
class MessageSent extends MessageState {
  /// 发送成功的消息
  final Message message;

  const MessageSent({required this.message});

  @override
  List<Object> get props => [message];
}

/// 消息发送失败状态
class MessageSendFailure extends MessageState {
  /// 错误消息
  final String message;
  
  /// 失败的消息
  final Message failedMessage;

  const MessageSendFailure({
    required this.message,
    required this.failedMessage,
  });

  @override
  List<Object> get props => [message, failedMessage];
} 