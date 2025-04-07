import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 获取消息用例参数
class GetMessagesParams extends Equatable {
  /// 会话ID
  final String sessionId;
  
  /// 基准消息ID，获取此消息之前的消息
  final String? beforeMessageId;
  
  /// 消息数量限制
  final int limit;

  /// 创建获取消息用例参数
  const GetMessagesParams({
    required this.sessionId,
    this.beforeMessageId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [sessionId, beforeMessageId, limit];
}

/// 获取消息用例
///
/// 提供获取历史消息的功能
class GetMessagesUseCase implements UseCase<Either<ChatFailure, List<Message>>, GetMessagesParams> {
  final IChatRepository _chatRepository;

  /// 创建获取消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const GetMessagesUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, List<Message>>> call(GetMessagesParams params) async {
    return _chatRepository.getMessages(
      sessionId: params.sessionId,
      beforeMessageId: params.beforeMessageId,
      limit: params.limit,
    );
  }
}

/// 搜索消息参数
///
/// 封装搜索消息需要的参数
class SearchMessagesParams extends Equatable {
  /// 搜索关键词
  final String query;
  
  /// 会话ID（可选）
  final String? sessionId;

  /// 创建搜索消息参数
  ///
  /// [query] 搜索关键词
  /// [sessionId] 会话ID，如果提供则只在该会话中搜索
  const SearchMessagesParams({
    required this.query,
    this.sessionId,
  });

  @override
  List<Object?> get props => [query, sessionId];
}

/// 搜索消息用例
///
/// 根据关键词搜索消息
class SearchMessagesUseCase implements UseCase<Future<Either<ChatFailure, List<Message>>>, SearchMessagesParams> {
  final IChatRepository _chatRepository;

  /// 创建搜索消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const SearchMessagesUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, List<Message>>> call(SearchMessagesParams params) {
    return _chatRepository.searchMessages(
      params.query,
      sessionId: params.sessionId,
    );
  }
} 