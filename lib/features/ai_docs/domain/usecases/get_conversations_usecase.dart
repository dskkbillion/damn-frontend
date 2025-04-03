import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_conversation_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

@lazySingleton // Annotate for DI
class GetConversationsUseCase implements UseCase<List<AiConversationEntity>, GetConversationsParams> {
  final IAiChatRepository repository;

  GetConversationsUseCase(this.repository); // Inject repository

  @override
  Future<Either<Failure, List<AiConversationEntity>>> call(GetConversationsParams params) async {
    return await repository.fetchConversations(userId: params.userId);
  }
}

// Parameters class remains the same
class GetConversationsParams {
  final int userId;

  GetConversationsParams({required this.userId});
} 