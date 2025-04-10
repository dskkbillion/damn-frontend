import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 发送消息用例
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase(this._chatRepository);

  /// 执行发送消息操作
  /// 
  /// [message] 要发送的消息
  /// 返回发送后的消息或失败
  Future<Either<Failure, Message>> execute(Message message) async {
    return await _chatRepository.sendMessage(message);
  }

  /// 执行重试发送消息操作
  /// 
  /// [message] 要重试发送的消息
  /// [maxRetries] 最大重试次数，默认为3
  /// 返回发送后的消息或失败
  Future<Either<Failure, Message>> retry(Message message, {int maxRetries = 3}) async {
    return await _chatRepository.retryOperation(() => 
      _chatRepository.sendMessage(message), maxRetries);
  }
} 