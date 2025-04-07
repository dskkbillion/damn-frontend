import 'dart:async';
import 'dart:math';

import '../domain/entities/message.dart';
import '../domain/services/i_chat_realtime_service.dart';

/// 模拟聊天实时服务实现
///
/// 用于隔离开发和测试
class MockChatRealtimeService implements IChatRealtimeService {
  final _messageStreamController = StreamController<Message>.broadcast();
  final _messageStatusStreamController = StreamController<MessageStatusUpdate>.broadcast();
  final _random = Random();
  
  /// 创建模拟聊天实时服务
  MockChatRealtimeService() {
    // 模拟随机接收消息
    _simulateIncomingMessages();
    
    // 模拟随机消息状态更新
    _simulateStatusUpdates();
  }

  @override
  Stream<Message> get messageStream => _messageStreamController.stream;

  @override
  Stream<MessageStatusUpdate> get messageStatusStream => _messageStatusStreamController.stream;
  
  /// 模拟接收新消息
  ///
  /// 随机生成新消息并通过消息流发送
  void _simulateIncomingMessages() {
    // 模拟每隔一段时间收到一条新消息
    Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_random.nextBool()) {
        final sessionId = 'session_${_random.nextInt(4) + 1}';
        final senderId = 'user_${_random.nextInt(4) + 1}';
        final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
        
        // 随机选择消息类型
        final messageType = _random.nextDouble() > 0.8 
          ? MessageType.image 
          : MessageType.text;
        
        // 根据消息类型生成内容
        String content;
        if (messageType == MessageType.text) {
          final templates = [
            '你好，有什么可以帮到你的吗？',
            '我刚才看到一个很有趣的事情',
            '周末有空一起出去玩吗？',
            '今天的会议很重要，请准时参加',
            '我昨天推荐的那本书你看了吗？',
            '这个项目的截止日期是下周五',
            '我刚刚解决了那个问题，很简单',
            '明天下午有时间讨论方案吗？',
          ];
          content = templates[_random.nextInt(templates.length)];
        } else {
          // 图片类型
          final imageId = _random.nextInt(10) + 1;
          final gender = _random.nextBool() ? 'men' : 'women';
          content = 'https://randomuser.me/api/portraits/$gender/$imageId.jpg';
        }
        
        // 创建消息对象
        final message = Message(
          id: messageId,
          sessionId: sessionId,
          senderId: senderId,
          content: content,
          timestamp: DateTime.now(),
          status: MessageStatus.delivered,
          type: messageType,
          currentUserId: 'current_user',
        );
        
        // 发送消息
        _messageStreamController.add(message);
      }
    });
  }
  
  /// 模拟消息状态更新
  ///
  /// 随机生成状态更新并通过状态流发送
  void _simulateStatusUpdates() {
    // 模拟每隔一段时间有消息状态更新
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_random.nextBool()) {
        final messageId = 'msg_${_random.nextInt(100) + 1}';
        
        // 随机选择一个状态
        final statuses = [
          MessageStatus.sent,
          MessageStatus.delivered,
          MessageStatus.read,
          MessageStatus.failed,
        ];
        final status = statuses[_random.nextInt(statuses.length)];
        
        // 创建状态更新对象
        final statusUpdate = MessageStatusUpdate(
          messageId: messageId,
          status: status,
        );
        
        // 发送状态更新
        _messageStatusStreamController.add(statusUpdate);
      }
    });
  }
} 