import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_conversation_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template fetch_conversations_usecase}
/// Use case for fetching the list of AI conversations.
/// {@endtemplate}
class FetchConversationsUseCase 
    implements UseCase<List<AiConversationEntity>, FetchConversationsParams> {
      
  final IAiChatRepository repository;

  /// {@macro fetch_conversations_usecase}
  FetchConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AiConversationEntity>>> call(
      FetchConversationsParams params) async {
    return await repository.fetchConversations(userId: params.userId);
  }
}

/// {@template fetch_conversations_params}
/// Parameters required for fetching conversations.
/// {@endtemplate}
class FetchConversationsParams extends Equatable {
  final int userId;

  /// {@macro fetch_conversations_params}
  const FetchConversationsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
} 