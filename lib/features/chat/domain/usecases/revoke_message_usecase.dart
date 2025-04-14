import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 撤回消息用例。
class RevokeMessageUseCase {
  final IChatRepository _repository;

  RevokeMessageUseCase(this._repository);

  /// 调用此 UseCase 撤回消息。
  /// [params] 包含要撤回的消息的服务器 ID (`messageId`)。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call(RevokeMessageParams params) {
    // 调用者应在成功后更新本地消息状态 (例如标记为已撤回或从列表中移除)
    return _repository.revokeMessage(params.messageId);
  }
}

/// RevokeMessageUseCase 的参数
class RevokeMessageParams {
  final int messageId;

  RevokeMessageParams({required this.messageId});
} 