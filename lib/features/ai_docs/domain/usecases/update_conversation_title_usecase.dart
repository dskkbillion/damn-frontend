 import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template update_conversation_title_usecase}
/// Use case for updating the title of a conversation.
/// {@endtemplate}
@injectable
class UpdateConversationTitleUseCase implements UseCase<String, UpdateConversationTitleParams> {
  final IAiChatRepository _repository;

  /// {@macro update_conversation_title_usecase}
  UpdateConversationTitleUseCase(this._repository);

  @override
  Future<Either<Failure, String>> call(UpdateConversationTitleParams params) async {
    return await _repository.updateConversationTitle(
      conversationId: params.conversationId,
      userId: params.userId,
      title: params.title,
    );
  }
}

/// {@template update_conversation_title_params}
/// Parameters for [UpdateConversationTitleUseCase].
/// {@endtemplate}
class UpdateConversationTitleParams {
  final int conversationId;
  final int userId;
  final String title;

  /// {@macro update_conversation_title_params}
  const UpdateConversationTitleParams({
    required this.conversationId,
    required this.userId,
    required this.title,
  });
}