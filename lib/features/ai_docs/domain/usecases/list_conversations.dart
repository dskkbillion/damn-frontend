import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/i_ai_chat_repository.dart';
import 'get_conversations_usecase.dart'; // 导入GetConversationsResult

/// {@template list_conversations}
/// Fetches the list of AI conversations.
///
/// This use case retrieves the conversation history for the current user
/// by interacting with the [IAiChatRepository].
/// {@endtemplate}
class ListConversations {
  final IAiChatRepository _repository;

  /// {@macro list_conversations}
  const ListConversations(this._repository);

  /// Executes the use case.
  ///
  /// Returns a GetConversationsResult on success (Right),
  /// or a [Failure] on error (Left).
  Future<Either<Failure, GetConversationsResult>> call(int userId, {
    int page = 1,
    int pageSize = 20,
    String orderBy = 'desc',
  }) async {
    // Input validation can be added here if needed
    return _repository.fetchConversations(
      userId: userId,
      page: page,
      pageSize: pageSize,
      orderBy: orderBy,
    );
  }
} 