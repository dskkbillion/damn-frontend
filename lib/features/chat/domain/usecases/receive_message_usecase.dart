import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 接收消息用例
class ReceiveMessageUseCase {
  final IChatRepository _chatRepository;

  ReceiveMessageUseCase(this._chatRepository);

  /// 获取新消息的流
  /// 返回消息流
  Stream<Message> execute() {
    return _chatRepository.observeMessages();
  }

  /// 获取消息状态更新的流
  /// 返回消息状态更新流
  Stream<MessageStatusUpdate> observeStatusUpdates() {
    return _chatRepository.observeMessageStatusUpdates();
  }
} 