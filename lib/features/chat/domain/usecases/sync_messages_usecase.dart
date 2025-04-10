import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 同步消息用例
class SyncMessagesUseCase {
  final IChatRepository _chatRepository;

  SyncMessagesUseCase(this._chatRepository);

  /// 获取历史消息
  /// 
  /// [sessionId] 会话ID
  /// [beforeMessageId] 可选的消息ID，获取此ID之前的消息
  /// [limit] 返回消息数量限制，默认为20
  /// 返回消息列表
  Future<Either<Failure, List<Message>>> getMessages(
    String sessionId, {
    String? beforeMessageId,
    int limit = 20,
  }) async {
    return await _chatRepository.getMessages(sessionId, beforeMessageId, limit);
  }

  /// 撤回消息
  /// 
  /// [messageId] 消息ID
  /// 返回操作结果
  Future<Either<Failure, void>> revokeMessage(String messageId) async {
    return await _chatRepository.revokeMessage(messageId);
  }

  /// 删除消息
  /// 
  /// [messageId] 消息ID
  /// 返回操作结果
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    return await _chatRepository.deleteMessage(messageId);
  }

  /// 清除消息错误状态
  /// 
  /// [messageId] 消息ID
  /// 返回操作结果
  Future<Either<Failure, void>> clearMessageError(String messageId) async {
    return await _chatRepository.clearError(messageId);
  }
} 