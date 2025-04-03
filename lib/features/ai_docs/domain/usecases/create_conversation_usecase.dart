import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template create_conversation_usecase}
/// Use case for creating a new AI conversation.
/// {@endtemplate}
@lazySingleton
class CreateConversationUseCase implements UseCase<int, CreateConversationParams> {
  final IAiChatRepository repository;

  /// {@macro create_conversation_usecase}
  CreateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateConversationParams params) async {
    // Input validation could be added here (e.g., check title length)
    return await repository.createConversation(
      userId: params.userId,
      title: params.title,
    );
  }
}

/// {@template create_conversation_params}
/// Parameters required for creating a new conversation.
/// {@endtemplate}
class CreateConversationParams extends Equatable {
  final int userId;
  final String? title;

  /// {@macro create_conversation_params}
  const CreateConversationParams({required this.userId, this.title});

  @override
  List<Object?> get props => [userId, title];
} 