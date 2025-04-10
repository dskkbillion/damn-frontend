import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 创建会话用例
class CreateSessionUseCase {
  final IChatRepository _chatRepository;

  CreateSessionUseCase(this._chatRepository);

  /// 执行创建会话操作
  /// 
  /// [targetUserId] 目标用户ID
  /// [initialMessage] 可选的初始消息
  /// 返回创建的会话或失败
  Future<Either<Failure, ChatSession>> execute(String targetUserId, {Message? initialMessage}) async {
    return await _chatRepository.createSession(targetUserId, initialMessage: initialMessage);
  }
} 