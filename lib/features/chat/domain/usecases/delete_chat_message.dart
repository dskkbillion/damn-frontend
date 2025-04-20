import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../repositories/i_chat_repository.dart';

// Use case definition
abstract class DeleteChatMessage implements UseCase<void, DeleteChatMessageParams> {}

// Implementation
class DeleteChatMessageImpl implements DeleteChatMessage {
  final IChatRepository repository;

  DeleteChatMessageImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChatMessageParams params) async {
    // FIX: Pass the list of messageIds directly to the repository
    return await repository.deleteChatMessages(params.messageIds, params.chatId);
  }
}

// Parameters
class DeleteChatMessageParams extends Equatable {
  // FIX: Change from single messageId to a list
  final List<int> messageIds; // The IDs of the messages to delete
  final int chatId; // The ID of the chat room the messages belong to

  // FIX: Update constructor
  const DeleteChatMessageParams({required this.messageIds, required this.chatId});

  @override
  // FIX: Update props
  List<Object?> get props => [messageIds, chatId];
} 