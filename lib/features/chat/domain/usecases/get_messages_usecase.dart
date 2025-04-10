import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取消息用例
class GetMessagesUseCase {
  final IChatRepository _chatRepository;

  GetMessagesUseCase(this._chatRepository);

  /// 执行获取消息操作
  /// 
  /// [sessionId] 会话ID
  /// [beforeMessageId] 可选的分页标记，获取此消息ID之前的消息
  /// [limit] 返回消息数量限制
  /// 
  /// 返回消息列表或失败
  Future<Either<Failure, List<Message>>> execute(
    String sessionId, {
    String? beforeMessageId,
    int limit = 20,
  }) async {
    return _chatRepository.getMessages(sessionId, beforeMessageId, limit);
  }
} 