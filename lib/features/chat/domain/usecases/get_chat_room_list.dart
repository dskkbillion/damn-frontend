import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart'; // Optional: for DI later

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart'; // For Base UseCase & NoParams
import '../entities/chat_room.dart';
import '../repositories/i_chat_repository.dart';

/// Use case for retrieving the list of chat rooms.
abstract class GetChatRoomList extends UseCase<List<ChatRoom>, NoParams> {}

// Implementation (can be in the same file for simplicity now, or separate later)
@LazySingleton(as: GetChatRoomList) // Optional: for DI later
class GetChatRoomListImpl implements GetChatRoomList {
  final IChatRepository repository;

  GetChatRoomListImpl(this.repository);

  @override
  Future<Either<Failure, List<ChatRoom>>> call(NoParams params) async {
    return await repository.getChatRooms();
  }
} 