import 'package:dartz/dartz.dart';

import '../entities/chat_session.dart';
import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 获取当前用户的聊天会话列表。
class GetChatSessionsUseCase {
  final IChatRepository _repository;

  GetChatSessionsUseCase(this._repository);

  /// 调用此 UseCase。
  /// 成功时返回会话列表 `List<ChatSession>`。
  /// 失败时返回 `Failure`。
  Future<Either<Failure, List<ChatSession>>> call() {
    return _repository.getChatSessions();
  }
} 