import 'package:equatable/equatable.dart';
import '../../domain/entities/message_status_update.dart';
import '../../domain/entities/message.dart';

/// 消息状态更新模型类
/// 用于消息状态更新的数据转换和处理
class MessageStatusUpdateModel extends Equatable {
  /// 消息ID
  final String messageId;
  
  /// 新状态
  final MessageStatus newStatus;
  
  /// 会话ID
  final String sessionId;
  
  /// 更新时间
  final DateTime timestamp;

  const MessageStatusUpdateModel({
    required this.messageId,
    required this.newStatus,
    required this.sessionId,
    required this.timestamp,
  });

  /// 从领域实体创建模型
  factory MessageStatusUpdateModel.fromDomain(MessageStatusUpdate update) {
    return MessageStatusUpdateModel(
      messageId: update.messageId,
      newStatus: update.newStatus,
      sessionId: update.sessionId,
      timestamp: update.timestamp,
    );
  }

  /// 从JSON映射创建模型
  factory MessageStatusUpdateModel.fromJson(Map<String, dynamic> json) {
    // 解析状态字符串为枚举
    MessageStatus status;
    switch (json['status']?.toString().toLowerCase()) {
      case 'sending':
        status = MessageStatus.SENDING;
        break;
      case 'sent':
        status = MessageStatus.SENT;
        break;
      case 'delivered':
        status = MessageStatus.DELIVERED;
        break;
      case 'read':
        status = MessageStatus.READ;
        break;
      case 'failed':
        status = MessageStatus.FAILED;
        break;
      case 'revoked':
        status = MessageStatus.REVOKED;
        break;
      default:
        status = MessageStatus.SENT;
    }

    return MessageStatusUpdateModel(
      messageId: json['message_id'] ?? '',
      newStatus: status,
      sessionId: json['session_id'] ?? json['conversation_id'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) 
          : DateTime.now(),
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    // 状态枚举转换为字符串
    String statusStr;
    switch (newStatus) {
      case MessageStatus.SENDING:
        statusStr = 'sending';
        break;
      case MessageStatus.SENT:
        statusStr = 'sent';
        break;
      case MessageStatus.DELIVERED:
        statusStr = 'delivered';
        break;
      case MessageStatus.READ:
        statusStr = 'read';
        break;
      case MessageStatus.FAILED:
        statusStr = 'failed';
        break;
      case MessageStatus.REVOKED:
        statusStr = 'revoked';
        break;
    }

    return {
      'message_id': messageId,
      'status': statusStr,
      'session_id': sessionId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// 转换为领域实体
  MessageStatusUpdate toDomain() {
    return MessageStatusUpdate(
      messageId: messageId,
      newStatus: newStatus,
      sessionId: sessionId,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    newStatus,
    sessionId,
    timestamp,
  ];
} 