import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取聊天会话列表用例
class GetChatSessionsUseCase {
  final IChatRepository _repository;

  /// 创建获取聊天会话列表用例
  GetChatSessionsUseCase(this._repository);

  /// 执行用例，获取聊天会话列表流
  ///
  /// 将会返回一个包含所有聊天会话的流，当有新会话或更新时流会发送新值
  Stream<List<ChatSession>> call() {
    return _repository.getChatSessions();
  }
} 