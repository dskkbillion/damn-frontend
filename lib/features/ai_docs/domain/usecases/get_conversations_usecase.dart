import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_conversation_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template get_conversations_result}
/// Result of loading conversations with pagination info.
/// {@endtemplate}
class GetConversationsResult extends Equatable {
  final List<AiConversationEntity> conversations;
  final bool hasMore; // 是否还有更多页面
  final int currentPage; // 当前页码
  final int totalPages; // 总页数（如果后端提供）
  final int totalConversations; // 总对话数（如果后端提供）

  const GetConversationsResult({
    required this.conversations,
    required this.hasMore,
    required this.currentPage,
    this.totalPages = 0,
    this.totalConversations = 0,
  });

  @override
  List<Object?> get props => [conversations, hasMore, currentPage, totalPages, totalConversations];
}

@lazySingleton // Annotate for DI
class GetConversationsUseCase implements UseCase<GetConversationsResult, GetConversationsParams> {
  final IAiChatRepository repository;

  GetConversationsUseCase(this.repository); // Inject repository

  @override
  Future<Either<Failure, GetConversationsResult>> call(GetConversationsParams params) async {
    return await repository.fetchConversations(
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
      orderBy: params.orderBy,
    );
  }
}

/// {@template get_conversations_params}
/// Parameters required for loading conversations with pagination.
/// {@endtemplate}
class GetConversationsParams extends Equatable {
  final int userId;
  final int page; // 页码，从1开始
  final int pageSize; // 每页大小
  final String orderBy; // 排序方式：'desc'(默认，最新在前) 或 'asc'(最早在前)

  /// {@macro get_conversations_params}
  const GetConversationsParams({
    required this.userId,
    this.page = 1,
    this.pageSize = 20, // 对话列表默认每页20条
    this.orderBy = 'desc', // 默认最新对话在前
  });

  @override
  List<Object?> get props => [userId, page, pageSize, orderBy];
} 