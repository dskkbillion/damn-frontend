import 'package:equatable/equatable.dart';

/// 消息发送者类型枚举
enum MessageSenderType {
  /// 普通用户
  USER,
  /// 系统通知
  SYSTEM,
}

/// 消息来源类型枚举
enum MessageSourceType {
  /// 用户直接发送
  USER,
  /// AI 分发
  AI_DISTRIBUTION,
  /// 系统通知
  SYSTEM_NOTIFICATION,
}

/// 消息接收者类型枚举
enum MessageReceiverType {
  /// 普通用户
  USER,
  /// 系统
  SYSTEM,
}

/// 消息类型枚举
enum MessageType {
  /// 文本消息
  TEXT,
  /// 音频消息
  AUDIO,
  /// 图片消息
  IMAGE,
  /// 订单通知
  ORDER_NOTIFICATION,
  /// 系统消息
  SYSTEM,
}

/// 消息状态枚举
enum MessageStatus {
  /// 发送中
  SENDING,
  /// 已发送
  SENT,
  /// 已送达
  DELIVERED,
  /// 已读
  READ,
  /// 发送失败
  FAILED,
  /// 已撤回
  REVOKED,
}

/// 消息同步状态枚举
enum MessageSyncStatus {
  /// 待同步
  PENDING,
  /// 同步中
  SYNCING,
  /// 已同步
  SYNCED,
  /// 同步失败
  FAILED,
}

/// 聊天错误类
class ChatError extends Equatable {
  final String code;
  final String message;

  const ChatError({
    required this.code,
    required this.message,
  });

  @override
  List<Object?> get props => [code, message];
}

/// 消息实体类
class Message extends Equatable {
  /// 消息唯一标识
  final String id;
  
  /// 消息内容
  final String content;
  
  /// 发送者ID
  final String senderId;
  
  /// 发送者类型
  final MessageSenderType senderType;
  
  /// 消息来源
  final MessageSourceType messageSource;
  
  /// 接收者ID
  final String receiverId;
  
  /// 接收者类型
  final MessageReceiverType receiverType;
  
  /// 消息时间戳
  final DateTime timestamp;
  
  /// 消息状态
  final MessageStatus status;
  
  /// 消息类型
  final MessageType type;
  
  /// 消息同步状态
  final MessageSyncStatus syncStatus;
  
  /// 重试次数
  final int retryCount;
  
  /// 错误信息
  final ChatError? error;
  
  /// 会话ID
  final String sessionId;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderType,
    required this.messageSource,
    required this.receiverId,
    required this.receiverType,
    required this.timestamp,
    required this.status,
    required this.type,
    required this.syncStatus,
    this.retryCount = 0,
    this.error,
    required this.sessionId,
  });

  /// 复制并返回一个新的消息对象，可更新指定字段
  Message copyWith({
    String? id,
    String? content,
    String? senderId,
    MessageSenderType? senderType,
    MessageSourceType? messageSource,
    String? receiverId,
    MessageReceiverType? receiverType,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    MessageSyncStatus? syncStatus,
    int? retryCount,
    ChatError? error,
    String? sessionId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      messageSource: messageSource ?? this.messageSource,
      receiverId: receiverId ?? this.receiverId,
      receiverType: receiverType ?? this.receiverType,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    content,
    senderId,
    senderType,
    messageSource,
    receiverId,
    receiverType,
    timestamp,
    status,
    type,
    syncStatus,
    retryCount,
    error,
    sessionId,
  ];
} 