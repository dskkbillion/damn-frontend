import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_enums.dart';
import '../../domain/entities/chat_error.dart';
import '../../domain/entities/message.dart';

part 'message_dto.g.dart';

/// 消息数据传输对象
///
/// 用于在API和应用之间传输消息数据
@JsonSerializable()
class MessageDto {
  /// 消息唯一标识符
  final String id;
  
  /// 消息所属的会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 发送者ID
  final String senderId;
  
  /// 发送者类型
  @JsonKey(name: 'sender_type')
  final String senderType;
  
  /// 消息来源
  @JsonKey(name: 'message_source')
  final String messageSource;
  
  /// 接收者ID
  final String receiverId;
  
  /// 接收者类型
  @JsonKey(name: 'receiver_type')
  final String receiverType;
  
  /// 消息发送/接收时间
  final String timestamp;
  
  /// 消息当前状态
  final String status;
  
  /// 消息类型
  final String type;
  
  /// 父消息ID (对于回复类消息)
  @JsonKey(name: 'parent_message_id')
  final String? parentMessageId;
  
  /// 其他元数据，如附件URL等
  final Map<String, dynamic>? metadata;

  /// 创建一个消息DTO
  const MessageDto({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.senderId,
    required this.senderType,
    required this.messageSource,
    required this.receiverId,
    required this.receiverType,
    required this.timestamp,
    required this.status,
    required this.type,
    this.parentMessageId,
    this.metadata,
  });

  /// 从JSON创建消息DTO
  factory MessageDto.fromJson(Map<String, dynamic> json) => 
      _$MessageDtoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);

  /// 从实体创建DTO
  factory MessageDto.fromEntity(Message message) {
    return MessageDto(
      id: message.id,
      sessionId: message.sessionId,
      content: message.content,
      senderId: message.senderId,
      senderType: _senderTypeToString(message.senderType),
      messageSource: _messageSourceToString(message.messageSource),
      receiverId: message.receiverId,
      receiverType: _receiverTypeToString(message.receiverType),
      timestamp: message.timestamp.toIso8601String(),
      status: _messageStatusToString(message.status),
      type: _messageTypeToString(message.type),
      parentMessageId: message.parentMessageId,
      metadata: message.metadata,
    );
  }

  /// 转换为实体
  Message toEntity() {
    return Message(
      id: id,
      sessionId: sessionId,
      content: content,
      senderId: senderId,
      senderType: _stringToSenderType(senderType),
      messageSource: _stringToMessageSource(messageSource),
      receiverId: receiverId,
      receiverType: _stringToReceiverType(receiverType),
      timestamp: DateTime.parse(timestamp),
      status: _stringToMessageStatus(status),
      type: _stringToMessageType(type),
      syncStatus: MessageSyncStatus.SYNCED, // 从服务器获取的消息默认已同步
      parentMessageId: parentMessageId,
      metadata: metadata,
    );
  }

  // 枚举转换工具方法
  static String _senderTypeToString(MessageSenderType type) {
    switch (type) {
      case MessageSenderType.USER:
        return 'user';
      case MessageSenderType.SYSTEM:
        return 'system';
    }
  }

  static MessageSenderType _stringToSenderType(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return MessageSenderType.USER;
      case 'system':
        return MessageSenderType.SYSTEM;
      default:
        return MessageSenderType.USER; // 默认为用户
    }
  }

  static String _receiverTypeToString(MessageReceiverType type) {
    switch (type) {
      case MessageReceiverType.USER:
        return 'user';
      case MessageReceiverType.SYSTEM:
        return 'system';
    }
  }

  static MessageReceiverType _stringToReceiverType(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return MessageReceiverType.USER;
      case 'system':
        return MessageReceiverType.SYSTEM;
      default:
        return MessageReceiverType.USER; // 默认为用户
    }
  }

  static String _messageSourceToString(MessageSourceType type) {
    switch (type) {
      case MessageSourceType.USER:
        return 'user';
      case MessageSourceType.AI_DISTRIBUTION:
        return 'ai_distribution';
      case MessageSourceType.SYSTEM_NOTIFICATION:
        return 'system_notification';
    }
  }

  static MessageSourceType _stringToMessageSource(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return MessageSourceType.USER;
      case 'ai_distribution':
        return MessageSourceType.AI_DISTRIBUTION;
      case 'system_notification':
        return MessageSourceType.SYSTEM_NOTIFICATION;
      default:
        return MessageSourceType.USER; // 默认为用户
    }
  }

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.SENDING:
        return 'sending';
      case MessageStatus.SENT:
        return 'sent';
      case MessageStatus.DELIVERED:
        return 'delivered';
      case MessageStatus.READ:
        return 'read';
      case MessageStatus.REVOKED:
        return 'revoked';
      case MessageStatus.DELETED:
        return 'deleted';
      case MessageStatus.FAILED:
        return 'failed';
    }
  }

  static MessageStatus _stringToMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.SENDING;
      case 'sent':
        return MessageStatus.SENT;
      case 'delivered':
        return MessageStatus.DELIVERED;
      case 'read':
        return MessageStatus.READ;
      case 'revoked':
        return MessageStatus.REVOKED;
      case 'deleted':
        return MessageStatus.DELETED;
      case 'failed':
        return MessageStatus.FAILED;
      default:
        return MessageStatus.SENT; // 默认为已发送
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.TEXT:
        return 'text';
      case MessageType.IMAGE:
        return 'image';
      case MessageType.AUDIO:
        return 'audio';
      case MessageType.SYSTEM:
        return 'system';
      case MessageType.ORDER_NOTIFICATION:
        return 'order_notification';
    }
  }

  static MessageType _stringToMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.TEXT;
      case 'image':
        return MessageType.IMAGE;
      case 'audio':
        return MessageType.AUDIO;
      case 'system':
        return MessageType.SYSTEM;
      case 'order_notification':
        return MessageType.ORDER_NOTIFICATION;
      default:
        return MessageType.TEXT; // 默认为文本
    }
  }
} 