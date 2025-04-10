import 'package:equatable/equatable.dart';
import 'message.dart';

/// 消息状态更新实体类
class MessageStatusUpdate extends Equatable {
  /// 消息ID
  final String messageId;
  
  /// 新状态
  final MessageStatus newStatus;
  
  /// 会话ID
  final String sessionId;
  
  /// 更新时间
  final DateTime timestamp;

  const MessageStatusUpdate({
    required this.messageId,
    required this.newStatus,
    required this.sessionId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    messageId,
    newStatus,
    sessionId,
    timestamp,
  ];
} 