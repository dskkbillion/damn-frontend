import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../entities/message.dart';
import '../repositories/i_chat_repository.dart';

/// 获取指定会话的消息列表。
class GetMessagesUseCase {
  final IChatRepository _repository;

  GetMessagesUseCase(this._repository);

  /// 调用此 UseCase。
  /// [params] 包含需要获取消息的 `chatId`。
  /// 成功时返回消息列表 `List<Message>`。
  /// 失败时返回 `Failure`。
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) {
    return _repository.getMessages(params.chatId);
  }
}

/// GetMessagesUseCase 的参数
class GetMessagesParams {
  final int chatId;

  GetMessagesParams({required this.chatId});
} 