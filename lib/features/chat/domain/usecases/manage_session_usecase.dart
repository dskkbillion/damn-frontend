import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 管理会话用例
class ManageSessionUseCase {
  final IChatRepository _chatRepository;

  ManageSessionUseCase(this._chatRepository);

  /// 获取会话列表流
  Stream<List<ChatSession>> getSessions() {
    return _chatRepository.getChatSessions();
  }

  /// 标记会话为已读
  /// 
  /// [sessionId] 会话ID
  /// 返回操作结果
  Future<Either<Failure, void>> markAsRead(String sessionId) async {
    return await _chatRepository.markSessionAsRead(sessionId);
  }

  /// 更新会话状态
  /// 
  /// [sessionId] 会话ID
  /// [status] 新状态
  /// 返回操作结果
  Future<Either<Failure, void>> updateStatus(String sessionId, SessionStatus status) async {
    return await _chatRepository.updateSessionStatus(sessionId, status);
  }

  /// 删除会话
  /// 
  /// [sessionId] 会话ID
  /// 返回操作结果
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    return await _chatRepository.deleteSession(sessionId);
  }

  /// 获取会话详情
  /// 
  /// [sessionId] 会话ID
  /// 返回会话详情
  Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId) async {
    return await _chatRepository.getSessionDetail(sessionId);
  }
} 