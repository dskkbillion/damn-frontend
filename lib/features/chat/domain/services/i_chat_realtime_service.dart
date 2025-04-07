import '../entities/message.dart';

/// 消息状态更新
class MessageStatusUpdate {
  /// 消息ID
  final String messageId;
  
  /// 新的消息状态
  final MessageStatus status;

  /// 创建消息状态更新
  const MessageStatusUpdate({
    required this.messageId,
    required this.status,
  });
}

/// 聊天实时服务接口
///
/// 管理实时消息的接收和状态更新
abstract class IChatRealtimeService {
  /// 消息流，提供新接收到的消息
  Stream<Message> get messageStream;
  
  /// 消息状态更新流，提供消息状态变化信息
  Stream<MessageStatusUpdate> get messageStatusStream;
} 