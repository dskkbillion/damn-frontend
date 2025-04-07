import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/chat_enums.dart';
import '../entities/chat_session.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 管理会话参数
///
/// 封装会话管理的各种操作参数
class ManageSessionParams extends Equatable {
  /// 会话ID
  final String sessionId;
  
  /// 会话状态
  final SessionStatus? status;
  
  /// 是否置顶
  final bool? isPinned;
  
  /// 是否静音
  final bool? isMuted;
  
  /// 是否标记为已读
  final bool? markAsRead;
  
  /// 是否删除
  final bool? isDelete;

  /// 创建管理会话参数
  ///
  /// [sessionId] 会话ID
  /// [status] 会话状态
  /// [isPinned] 是否置顶
  /// [isMuted] 是否静音
  /// [markAsRead] 是否标记为已读
  /// [isDelete] 是否删除
  const ManageSessionParams({
    required this.sessionId,
    this.status,
    this.isPinned,
    this.isMuted,
    this.markAsRead,
    this.isDelete,
  });

  @override
  List<Object?> get props => [
        sessionId,
        status,
        isPinned,
        isMuted,
        markAsRead,
        isDelete,
      ];

  /// 检查是否至少有一个参数被设置
  bool get hasChanges => 
      status != null || 
      isPinned != null || 
      isMuted != null || 
      markAsRead != null || 
      isDelete != null;
}

/// 管理会话用例
///
/// 处理会话的各种状态管理操作，如标记已读、置顶、静音等
class ManageSessionUseCase implements UseCase<Future<Either<ChatFailure, void>>, ManageSessionParams> {
  final IChatRepository _chatRepository;

  /// 创建管理会话用例
  ///
  /// [chatRepository] 聊天仓库接口
  const ManageSessionUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, void>> call(ManageSessionParams params) async {
    if (!params.hasChanges) {
      return const Right(null); // 没有任何更改，直接返回成功
    }

    try {
      // 处理删除操作
      if (params.isDelete == true) {
        return _chatRepository.deleteSession(params.sessionId);
      }

      // 处理状态更新
      if (params.status != null) {
        final result = await _chatRepository.updateSessionStatus(
          params.sessionId,
          params.status!,
        );
        
        if (result.isLeft()) {
          return result;
        }
      }

      // 处理本地状态更新（置顶、静音）
      if (params.isPinned != null || params.isMuted != null) {
        final result = await _chatRepository.updateLocalSessionState(
          params.sessionId,
          isPinned: params.isPinned,
          isMuted: params.isMuted,
        );
        
        if (result.isLeft()) {
          return result.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        }
      }

      // 处理标记已读
      if (params.markAsRead == true) {
        return _chatRepository.markSessionAsRead(params.sessionId);
      }

      return const Right(null);
    } on Exception catch (e) {
      return Left(UnexpectedFailure(message: '管理会话失败: $e', error: e));
    }
  }
} 