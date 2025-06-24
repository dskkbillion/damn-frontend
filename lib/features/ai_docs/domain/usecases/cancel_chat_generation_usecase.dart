import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template cancel_chat_generation_usecase}
/// UseCase for cancelling an ongoing chat generation.
/// 
/// This is useful when the user wants to stop an AI response that's currently
/// being generated in real-time.
/// {@endtemplate}
@injectable
class CancelChatGenerationUseCase implements UseCase<void, CancelChatGenerationParams> {
  final IAiChatRepository _repository;

  /// {@macro cancel_chat_generation_usecase}
  CancelChatGenerationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CancelChatGenerationParams params) async {
    return await _repository.cancelChatGeneration(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

/// {@template cancel_chat_generation_params}
/// Parameters for the [CancelChatGenerationUseCase].
/// 
/// Contains the conversation ID and user ID needed to cancel
/// the ongoing chat generation.
/// {@endtemplate}
class CancelChatGenerationParams {
  /// The ID of the conversation where chat generation should be cancelled.
  final int conversationId;
  
  /// The ID of the user requesting the cancellation.
  final int userId;

  /// {@macro cancel_chat_generation_params}
  const CancelChatGenerationParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelChatGenerationParams &&
        other.conversationId == conversationId &&
        other.userId == userId;
  }

  @override
  int get hashCode => conversationId.hashCode ^ userId.hashCode;

  @override
  String toString() => 'CancelChatGenerationParams(conversationId: $conversationId, userId: $userId)';
} 