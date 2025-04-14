import 'package:dartz/dartz.dart';

import '../entities/chat_session.dart';
import '../entities/failure.dart';
import '../repositories/i_chat_repository.dart';

/// 监听聊天会话列表的变化。
class ObserveChatSessionsUseCase {
  final IChatRepository _repository;

  ObserveChatSessionsUseCase(this._repository);

  /// 调用此 UseCase。
  /// 返回一个 Stream，该流会持续发出最新的会话列表 `List<ChatSession>` 或 `Failure`。
  Stream<Either<Failure, List<ChatSession>>> call() {
    return _repository.observeChatSessions();
  }
} 