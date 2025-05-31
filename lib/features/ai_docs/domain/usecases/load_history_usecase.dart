import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_chat_message_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template load_history_result}
/// Result of loading conversation history with pagination info.
/// {@endtemplate}
class LoadHistoryResult extends Equatable {
  final List<AiChatMessageEntity> messages;
  final bool hasMore; // 是否还有更多页面
  final int currentPage; // 当前页码
  final int totalPages; // 总页数（如果后端提供）
  final int totalMessages; // 总消息数（如果后端提供）

  const LoadHistoryResult({
    required this.messages,
    required this.hasMore,
    required this.currentPage,
    this.totalPages = 0,
    this.totalMessages = 0,
  });

  @override
  List<Object?> get props => [messages, hasMore, currentPage, totalPages, totalMessages];
}

/// {@template load_history_usecase}
/// Use case for loading the message history of a conversation.
/// {@endtemplate}
@lazySingleton
class LoadHistoryUseCase implements UseCase<LoadHistoryResult, LoadHistoryParams> {
  final IAiChatRepository repository;

  /// {@macro load_history_usecase}
  LoadHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, LoadHistoryResult>> call(
      LoadHistoryParams params) async {
    return await repository.loadHistory(
      conversationId: params.conversationId,
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
      orderBy: params.orderBy,
      getAll: params.getAll,
    );
  }
}

/// {@template load_history_params}
/// Parameters required for loading conversation history with new pagination.
/// {@endtemplate}
class LoadHistoryParams extends Equatable {
  final int conversationId;
  final int userId;
  final int page; // 页码，从1开始
  final int pageSize; // 每页大小
  final String orderBy; // 排序方式：'desc'(默认，最新在前) 或 'asc'(最旧在前)
  final bool getAll; // 是否获取全部消息

  /// {@macro load_history_params}
  const LoadHistoryParams({
    required this.conversationId,
    required this.userId,
    this.page = 1,
    this.pageSize = 50,
    this.orderBy = 'desc', // 默认最新消息在前
    this.getAll = false,
  });

  @override
  List<Object?> get props => [conversationId, userId, page, pageSize, orderBy, getAll];
} 