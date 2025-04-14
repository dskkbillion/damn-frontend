import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 标记会话为已读用例。
class MarkSessionAsReadUseCase {
  final IChatRepository _repository;

  MarkSessionAsReadUseCase(this._repository);

  /// 调用此 UseCase 标记会话为已读。
  /// [params] 包含要标记的会话 ID (`chatId`)。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call(MarkSessionAsReadParams params) {
    // 注意：此操作的具体实现依赖于 Repository，可能仅更新本地状态
    return _repository.markSessionAsRead(params.chatId);
  }
}

/// MarkSessionAsReadUseCase 的参数
class MarkSessionAsReadParams {
  final int chatId;

  MarkSessionAsReadParams({required this.chatId});
} 