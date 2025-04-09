import 'package:dartz/dartz.dart';

import '../entities/chat_session.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 获取聊天会话列表用例
///
/// 提供会话列表的实时流，当会话更新时会自动推送新数据
class GetChatSessionsUseCase implements UseCase<Stream<List<ChatSession>>, NoParams> {
  final IChatRepository _chatRepository;

  /// 创建获取聊天会话列表用例
  ///
  /// [chatRepository] 聊天仓库接口
  const GetChatSessionsUseCase(this._chatRepository);

  @override
  Stream<List<ChatSession>> call(NoParams params) {
    return _chatRepository.getChatSessions();
  }
}

/// 获取特定会话详情用例
///
/// 根据会话ID获取单个会话的详细信息
class GetSessionDetailUseCase implements UseCase<Future<Either<ChatFailure, ChatSession>>, String> {
  final IChatRepository _chatRepository;

  /// 创建获取会话详情用例
  ///
  /// [chatRepository] 聊天仓库接口
  const GetSessionDetailUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, ChatSession>> call(String sessionId) {
    return _chatRepository.getSessionDetail(sessionId);
  }
} 