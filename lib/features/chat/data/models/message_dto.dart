import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// 消息数据传输对象
class MessageDto extends Equatable {
  /// 消息ID
  final String id;
  
  /// 会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 发送者ID
  final String senderId;
  
  /// 接收者ID
  final String receiverId;
  
  /// 消息类型
  final String type;
  
  /// 时间戳（毫秒）
  final int timestamp;
  
  /// 读取时间（毫秒）
  final int? readTime;
  
  /// 消息角色（user/assistant/system）
  final String? role;
  
  /// 消息来源类型
  final String? messageType;
  
  /// 父消息ID
  final String? parentMessageId;
  
  /// 附加数据
  final Map<String, dynamic>? additionalData;

  const MessageDto({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.timestamp,
    this.readTime,
    this.role,
    this.messageType,
    this.parentMessageId,
    this.additionalData,
  });

  /// 从JSON映射创建DTO
  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] ?? '',
      sessionId: json['conversation_id'] ?? '',
      content: json['content'] ?? json['context'] ?? '',
      senderId: json['sender_id'] ?? json['role'] ?? '',
      receiverId: json['recipient_id'] ?? json['receiver_id'] ?? '',
      type: json['type'] ?? 'text',
      timestamp: json['timestamp'] ?? json['create_time'] ?? DateTime.now().millisecondsSinceEpoch,
      readTime: json['read_time'],
      role: json['role'],
      messageType: json['message_type'],
      parentMessageId: json['parent_message_id'],
      additionalData: json['additional_data'],
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': sessionId,
      'content': content,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'type': type,
      'timestamp': timestamp,
      if (readTime != null) 'read_time': readTime,
      if (role != null) 'role': role,
      if (messageType != null) 'message_type': messageType,
      if (parentMessageId != null) 'parent_message_id': parentMessageId,
      if (additionalData != null) ...additionalData!,
    };
  }

  /// 转换为领域实体
  Message toDomain() {
    // 根据角色或其他字段确定发送者类型
    final senderType = role == 'system' || senderId == 'system' 
        ? MessageSenderType.SYSTEM 
        : MessageSenderType.USER;
    
    // 确定消息来源
    MessageSourceType messageSource;
    if (messageType == 'AI_DISTRIBUTION') {
      messageSource = MessageSourceType.AI_DISTRIBUTION;
    } else if (senderType == MessageSenderType.SYSTEM) {
      messageSource = MessageSourceType.SYSTEM_NOTIFICATION;
    } else {
      messageSource = MessageSourceType.USER;
    }
    
    // 确定接收者类型
    final receiverType = receiverId == 'system'
        ? MessageReceiverType.SYSTEM
        : MessageReceiverType.USER;
    
    // 确定消息类型
    MessageType messageTypeEnum;
    switch (type.toLowerCase()) {
      case 'audio':
        messageTypeEnum = MessageType.AUDIO;
        break;
      case 'image':
        messageTypeEnum = MessageType.IMAGE;
        break;
      case 'order_notification':
        messageTypeEnum = MessageType.ORDER_NOTIFICATION;
        break;
      case 'system':
        messageTypeEnum = MessageType.SYSTEM;
        break;
      default:
        messageTypeEnum = MessageType.TEXT;
    }
    
    // 确定消息状态
    MessageStatus status;
    if (readTime != null && readTime! > 0) {
      status = MessageStatus.READ;
    } else {
      status = MessageStatus.SENT;
    }
    
    return Message(
      id: id,
      content: content,
      senderId: senderId,
      senderType: senderType,
      messageSource: messageSource,
      receiverId: receiverId,
      receiverType: receiverType,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      status: status,
      type: messageTypeEnum,
      syncStatus: MessageSyncStatus.SYNCED,
      sessionId: sessionId,
    );
  }

  /// 从领域实体创建DTO
  factory MessageDto.fromDomain(Message message) {
    // 确定消息类型字符串
    String typeStr;
    switch (message.type) {
      case MessageType.AUDIO:
        typeStr = 'audio';
        break;
      case MessageType.IMAGE:
        typeStr = 'image';
        break;
      case MessageType.ORDER_NOTIFICATION:
        typeStr = 'order_notification';
        break;
      case MessageType.SYSTEM:
        typeStr = 'system';
        break;
      default:
        typeStr = 'text';
    }
    
    // 确定消息来源字符串
    String? messageTypeStr;
    if (message.messageSource == MessageSourceType.AI_DISTRIBUTION) {
      messageTypeStr = 'AI_DISTRIBUTION';
    } else if (message.messageSource == MessageSourceType.SYSTEM_NOTIFICATION) {
      messageTypeStr = 'SYSTEM_NOTIFICATION';
    }
    
    return MessageDto(
      id: message.id,
      sessionId: message.sessionId,
      content: message.content,
      senderId: message.senderId,
      receiverId: message.receiverId,
      type: typeStr,
      timestamp: message.timestamp.millisecondsSinceEpoch,
      role: message.senderType == MessageSenderType.SYSTEM ? 'system' : 'user',
      messageType: messageTypeStr,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sessionId,
    content,
    senderId,
    receiverId,
    type,
    timestamp,
    readTime,
    role,
    messageType,
    parentMessageId,
  ];
} 