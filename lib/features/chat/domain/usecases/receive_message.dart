import 'package:dartz/dartz.dart';

import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_realtime_service.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';
import 'get_chat_sessions.dart';

/// 接收消息用例
///
/// 监听实时消息流并处理接收到的消息
class ReceiveMessageUseCase implements UseCase<Stream<Message>, NoParams> {
  final IChatRealtimeService _realtimeService;
  final IChatRepository _chatRepository;

  /// 创建接收消息用例
  ///
  /// [realtimeService] 实时服务接口
  /// [chatRepository] 聊天仓库接口
  const ReceiveMessageUseCase(this._realtimeService, this._chatRepository);

  @override
  Stream<Message> call(NoParams params) {
    // 连接到实时服务（如果尚未连接）
    _ensureConnected();
    
    // 处理接收到的消息数据
    return _realtimeService.incomingMessages
      .where((incomingMessage) => incomingMessage.type == 'message')
      .asyncMap((incomingMessage) => _processIncomingMessage(incomingMessage));
  }

  /// 确保已连接到实时服务
  Future<void> _ensureConnected() async {
    if (!_realtimeService.isConnected) {
      try {
        // 这里假设token已通过其他方式存储
        // 实际应用中应该从安全存储中获取
        await _realtimeService.connect('user_auth_token');
        await _realtimeService.startHeartbeat(const Duration(seconds: 30));
      } catch (e) {
        // 连接失败，将在观察连接状态时重试
        print('实时连接失败: $e');
      }
    }
  }

  /// 处理接收到的消息
  Future<Message> _processIncomingMessage(IncomingMessageDto incomingMessage) async {
    // 解析消息数据
    final messageData = incomingMessage.data;
    
    // 创建Message对象
    // 实际应用中应该从DTO转换
    final message = Message.fromJson(messageData);
    
    // 确认消息接收
    try {
      await _realtimeService.acknowledgeMessage(message.id);
    } catch (e) {
      print('消息确认失败: $e');
      // 继续处理消息，即使确认失败
    }
    
    // 将消息保存到本地存储
    // 这里我们假设sendMessage会同时处理存储逻辑
    final result = await _chatRepository.sendMessage(message);
    
    return result.fold(
      (failure) {
        // 如果保存失败，仍返回原始消息
        print('保存接收的消息失败: $failure');
        return message;
      },
      (savedMessage) => savedMessage,
    );
  }
}

/// 监听消息状态变更用例
///
/// 提供消息状态变更的实时流
class ObserveMessageStatusUseCase implements UseCase<Stream<MessageStatusUpdate>, NoParams> {
  final IChatRepository _chatRepository;

  /// 创建监听消息状态变更用例
  ///
  /// [chatRepository] 聊天仓库接口
  const ObserveMessageStatusUseCase(this._chatRepository);

  @override
  Stream<MessageStatusUpdate> call(NoParams params) {
    return _chatRepository.observeMessageStatusUpdates();
  }
} 