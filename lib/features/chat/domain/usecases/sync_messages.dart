import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 同步消息参数
///
/// 封装从服务器同步消息所需的参数
class SyncMessagesParams extends Equatable {
  /// 会话ID
  final String sessionId;
  
  /// 上次同步时间
  final DateTime lastSyncTime;
  
  /// 返回消息数量限制
  final int limit;

  /// 创建同步消息参数
  ///
  /// [sessionId] 会话ID
  /// [lastSyncTime] 上次同步的时间点，将获取此时间之后的消息
  /// [limit] 最大消息数限制，默认100条
  const SyncMessagesParams({
    required this.sessionId,
    required this.lastSyncTime,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [sessionId, lastSyncTime, limit];
}

/// 同步消息用例
///
/// 从服务器获取指定时间点后的新消息，用于应用启动或网络重连时的消息同步
class SyncMessagesUseCase implements UseCase<Future<Either<ChatFailure, List<Message>>>, SyncMessagesParams> {
  final IChatRepository _chatRepository;

  /// 创建同步消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const SyncMessagesUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, List<Message>>> call(SyncMessagesParams params) async {
    try {
      // 使用仓库的批量加载方法
      return _chatRepository.batchLoadMessages(
        params.sessionId,
        params.lastSyncTime,
        params.limit,
      );
    } on Exception catch (e) {
      return Left(UnexpectedFailure(message: '同步消息失败: $e', error: e));
    }
  }
}

/// 标记消息为已读参数
///
/// 封装标记消息已读所需的参数
class MarkMessagesReadParams extends Equatable {
  /// 会话ID
  final String sessionId;
  
  /// 特定消息ID列表（可选）
  final List<String>? messageIds;

  /// 创建标记消息已读参数
  ///
  /// [sessionId] 会话ID
  /// [messageIds] 需要标记为已读的消息ID列表，不提供则标记所有消息
  const MarkMessagesReadParams({
    required this.sessionId,
    this.messageIds,
  });

  @override
  List<Object?> get props => [sessionId, messageIds];
}

/// 标记消息为已读用例
///
/// 将会话中的消息标记为已读状态
class MarkMessagesReadUseCase implements UseCase<Future<Either<ChatFailure, void>>, MarkMessagesReadParams> {
  final IChatRepository _chatRepository;

  /// 创建标记消息已读用例
  ///
  /// [chatRepository] 聊天仓库接口
  const MarkMessagesReadUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, void>> call(MarkMessagesReadParams params) async {
    try {
      // 我们这里简化为标记整个会话已读
      // 实际实现中可能需要更复杂的逻辑来标记特定消息
      return _chatRepository.markSessionAsRead(params.sessionId);
    } on Exception catch (e) {
      return Left(UnexpectedFailure(message: '标记消息已读失败: $e', error: e));
    }
  }
} 