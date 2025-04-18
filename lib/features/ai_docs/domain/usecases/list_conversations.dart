import 'package:dartz/dartz.dart';

import '../entities/ai_conversation.dart';
import '../entities/failure.dart';
import '../repositories/i_ai_chat_repository.dart';

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
  /// Returns a list of [AIConversation] on success (Right),
  /// or a [Failure] on error (Left).
  Future<Either<Failure, List<AIConversation>>> call() async {
    // Input validation can be added here if needed
    return _repository.listConversations();
  }
} 