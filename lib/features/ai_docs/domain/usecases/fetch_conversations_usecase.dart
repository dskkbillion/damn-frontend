import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_conversation_entity.dart';
import '../repositories/i_ai_chat_repository.dart';
import 'get_conversations_usecase.dart'; // 导入GetConversationsResult

/// {@template fetch_conversations_usecase}
/// Use case for fetching the list of AI conversations.
/// {@endtemplate}
class FetchConversationsUseCase 
    implements UseCase<GetConversationsResult, FetchConversationsParams> {
      
  final IAiChatRepository repository;

  /// {@macro fetch_conversations_usecase}
  FetchConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, GetConversationsResult>> call(
      FetchConversationsParams params) async {
    return await repository.fetchConversations(
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
      orderBy: params.orderBy,
    );
  }
}

/// {@template fetch_conversations_params}
/// Parameters required for fetching conversations.
/// {@endtemplate}
class FetchConversationsParams extends Equatable {
  final int userId;
  final int page;
  final int pageSize;
  final String orderBy;

  /// {@macro fetch_conversations_params}
  const FetchConversationsParams({
    required this.userId,
    this.page = 1,
    this.pageSize = 20,
    this.orderBy = 'desc',
  });

  @override
  List<Object?> get props => [userId, page, pageSize, orderBy];
} 