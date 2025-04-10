import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

/// 聊天消息事件基类
abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

/// 加载消息事件
class LoadMessagesEvent extends ChatMessagesEvent {
  /// 会话ID
  final String sessionId;
  
  /// 每页消息数量
  final int limit;

  const LoadMessagesEvent({
    required this.sessionId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [sessionId, limit];
}

/// 加载更多消息事件
class LoadMoreMessagesEvent extends ChatMessagesEvent {
  /// 会话ID
  final String sessionId;
  
  /// 分页标记（消息ID），获取此ID之前的消息
  final String beforeMessageId;
  
  /// 每页消息数量
  final int limit;

  const LoadMoreMessagesEvent({
    required this.sessionId,
    required this.beforeMessageId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [sessionId, beforeMessageId, limit];
}

/// 发送消息事件
class SendMessageEvent extends ChatMessagesEvent {
  /// 会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 消息类型
  final MessageType type;
  
  /// 附加参数
  final Map<String, dynamic>? extraParams;

  const SendMessageEvent({
    required this.sessionId,
    required this.content,
    required this.type,
    this.extraParams,
  });

  @override
  List<Object?> get props => [sessionId, content, type, extraParams];
}

/// 重试发送消息事件
class RetrySendMessageEvent extends ChatMessagesEvent {
  /// 消息ID
  final String messageId;

  const RetrySendMessageEvent({
    required this.messageId,
  });

  @override
  List<Object?> get props => [messageId];
}

/// 撤回消息事件
class RevokeMessageEvent extends ChatMessagesEvent {
  /// 消息ID
  final String messageId;

  const RevokeMessageEvent({
    required this.messageId,
  });

  @override
  List<Object?> get props => [messageId];
}

/// 删除消息事件
class DeleteMessageEvent extends ChatMessagesEvent {
  /// 消息ID
  final String messageId;

  const DeleteMessageEvent({
    required this.messageId,
  });

  @override
  List<Object?> get props => [messageId];
}

/// 标记会话为已读事件
class MarkSessionAsReadEvent extends ChatMessagesEvent {
  /// 会话ID
  final String sessionId;

  const MarkSessionAsReadEvent({
    required this.sessionId,
  });

  @override
  List<Object?> get props => [sessionId];
}

/// 接收新消息事件
class ReceiveMessageEvent extends ChatMessagesEvent {
  /// 新收到的消息
  final Message message;

  const ReceiveMessageEvent({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// 消息状态更新事件
class MessageStatusUpdateEvent extends ChatMessagesEvent {
  /// 消息ID
  final String messageId;
  
  /// 新状态
  final MessageStatus newStatus;

  const MessageStatusUpdateEvent({
    required this.messageId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [messageId, newStatus];
} 