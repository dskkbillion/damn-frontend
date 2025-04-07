import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_enums.dart';
import '../../../domain/entities/message.dart';

/// 消息事件基类
abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

/// 加载消息事件
class LoadMessages extends MessageEvent {
  /// 会话ID
  final String sessionId;
  
  /// 消息数量限制
  final int limit;
  
  /// 是否初始加载
  final bool initial;

  const LoadMessages({
    required this.sessionId,
    this.limit = 20,
    this.initial = false,
  });

  @override
  List<Object> get props => [sessionId, limit, initial];
}

/// 加载更多消息事件
class LoadMoreMessages extends MessageEvent {
  /// 会话ID
  final String sessionId;
  
  /// 基准消息ID
  final String beforeMessageId;
  
  /// 消息数量限制
  final int limit;

  const LoadMoreMessages({
    required this.sessionId,
    required this.beforeMessageId,
    this.limit = 20,
  });

  @override
  List<Object> get props => [sessionId, beforeMessageId, limit];
}

/// 消息更新事件
class MessagesUpdated extends MessageEvent {
  /// 消息列表
  final List<Message> messages;
  
  /// 是否添加到现有消息列表
  final bool append;

  const MessagesUpdated({
    required this.messages,
    this.append = false,
  });

  @override
  List<Object> get props => [messages, append];
}

/// 发送消息事件
class SendMessage extends MessageEvent {
  /// 会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 接收者ID
  final String receiverId;
  
  /// 消息类型
  final MessageType type;
  
  /// 额外元数据
  final Map<String, dynamic>? metadata;

  const SendMessage({
    required this.sessionId,
    required this.content,
    required this.receiverId,
    this.type = MessageType.text,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        sessionId,
        content,
        receiverId,
        type,
        metadata,
      ];
}

/// 重试发送消息事件
class RetrySendMessage extends MessageEvent {
  /// 消息ID
  final String messageId;

  const RetrySendMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

/// 删除消息事件
class DeleteMessage extends MessageEvent {
  /// 消息ID
  final String messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

/// 撤回消息事件
class RevokeMessage extends MessageEvent {
  /// 消息ID
  final String messageId;

  const RevokeMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

/// 接收新消息事件
class ReceiveMessage extends MessageEvent {
  /// 新消息
  final Message message;

  const ReceiveMessage({required this.message});

  @override
  List<Object> get props => [message];
}

/// 消息状态更新事件
class MessageStatusChanged extends MessageEvent {
  /// 消息ID
  final String messageId;
  
  /// 新状态
  final MessageStatus status;

  const MessageStatusChanged({
    required this.messageId,
    required this.status,
  });

  @override
  List<Object> get props => [messageId, status];
} 