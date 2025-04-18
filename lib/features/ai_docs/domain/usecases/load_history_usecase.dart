import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_chat_message_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template load_history_usecase}
/// Use case for loading the message history of a conversation.
/// {@endtemplate}
@lazySingleton
class LoadHistoryUseCase implements UseCase<List<AiChatMessageEntity>, LoadHistoryParams> {
  final IAiChatRepository repository;

  /// {@macro load_history_usecase}
  LoadHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<AiChatMessageEntity>>> call(
      LoadHistoryParams params) async {
    return await repository.loadHistory(
      conversationId: params.conversationId,
      userId: params.userId,
      offset: params.offset,
      limit: params.limit,
    );
  }
}

/// {@template load_history_params}
/// Parameters required for loading conversation history.
/// {@endtemplate}
class LoadHistoryParams extends Equatable {
  final int conversationId;
  final int userId;
  final int? offset;
  final int? limit;

  /// {@macro load_history_params}
  const LoadHistoryParams({
    required this.conversationId,
    required this.userId,
    this.offset,
    this.limit,
  });

  @override
  List<Object?> get props => [conversationId, userId, offset, limit];
} 