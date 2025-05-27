 import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template generate_conversation_title_usecase}
/// Use case for generating a title for a conversation using AI.
/// {@endtemplate}
@injectable
class GenerateConversationTitleUseCase implements UseCase<String, GenerateConversationTitleParams> {
  final IAiChatRepository _repository;

  /// {@macro generate_conversation_title_usecase}
  GenerateConversationTitleUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(GenerateConversationTitleParams params) async {
    return await _repository.generateConversationTitle(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

/// {@template generate_conversation_title_params}
/// Parameters for [GenerateConversationTitleUseCase].
/// {@endtemplate}
class GenerateConversationTitleParams {
  final int conversationId;
  final int userId;

  /// {@macro generate_conversation_title_params}
  const GenerateConversationTitleParams({
    required this.conversationId,
    required this.userId,
  });
}