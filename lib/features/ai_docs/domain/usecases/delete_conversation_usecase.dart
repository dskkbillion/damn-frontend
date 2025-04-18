import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template delete_conversation_usecase}
/// Use case for deleting an AI conversation.
/// {@endtemplate}
@lazySingleton
class DeleteConversationUseCase implements UseCase<void, DeleteConversationParams> {
  final IAiChatRepository repository;

  /// {@macro delete_conversation_usecase}
  DeleteConversationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteConversationParams params) async {
    return await repository.deleteConversation(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

/// {@template delete_conversation_params}
/// Parameters required for deleting a conversation.
/// {@endtemplate}
class DeleteConversationParams extends Equatable {
  final int conversationId;
  final int userId;

  /// {@macro delete_conversation_params}
  const DeleteConversationParams({required this.conversationId, required this.userId});

  @override
  List<Object?> get props => [conversationId, userId];
} 