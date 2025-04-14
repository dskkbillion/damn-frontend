import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 创建或获取聊天会话用例。
class CreateChatSessionUseCase {
  final IChatRepository _repository;

  CreateChatSessionUseCase(this._repository);

  /// 调用此 UseCase 创建或获取会话。
  /// [params] 包含目标用户的 ID (`targetUserId`)。
  /// 成功时返回会话 ID (`chatId`)。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, int>> call(CreateChatSessionParams params) {
    return _repository.createChatSession(params.targetUserId);
  }
}

/// CreateChatSessionUseCase 的参数
class CreateChatSessionParams {
  final int targetUserId;

  CreateChatSessionParams({required this.targetUserId});
} 