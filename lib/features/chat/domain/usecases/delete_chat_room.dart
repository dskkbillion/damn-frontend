import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../repositories/i_chat_repository.dart';

// Use case definition
abstract class DeleteChatRoom implements UseCase<void, DeleteChatRoomParams> {}

// Implementation
class DeleteChatRoomImpl implements DeleteChatRoom {
  final IChatRepository repository;

  DeleteChatRoomImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChatRoomParams params) async {
    return await repository.deleteChatRooms(params.chatIds);
  }
}

// Parameters
class DeleteChatRoomParams extends Equatable {
  final List<int> chatIds; // The IDs of the chat rooms to delete

  const DeleteChatRoomParams({required this.chatIds});

  @override
  List<Object?> get props => [chatIds];
}
