import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_chat_repository.dart';

// Use Case: Create a new chat room
abstract class CreateChatRoom extends UseCase<int, CreateChatRoomParams> {}

class CreateChatRoomParams extends Equatable {
  final int participantId; // The ID of the user/doctor to create a chat with

  const CreateChatRoomParams({required this.participantId});

  @override
  List<Object?> get props => [participantId];
}

class CreateChatRoomImpl implements CreateChatRoom {
  final IChatRepository repository;

  CreateChatRoomImpl(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateChatRoomParams params) async {
    return await repository.createRoom(params.participantId);
  }
} 