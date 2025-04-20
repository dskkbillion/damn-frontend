import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../entities/chat_room.dart';
import '../repositories/i_chat_repository.dart';

// Use case definition
abstract class GetChatRoomDetails implements UseCase<ChatRoom, GetChatRoomDetailsParams> {}

// Implementation
class GetChatRoomDetailsImpl implements GetChatRoomDetails {
  final IChatRepository repository;

  GetChatRoomDetailsImpl(this.repository);

  @override
  Future<Either<Failure, ChatRoom>> call(GetChatRoomDetailsParams params) async {
    return await repository.getRoomDetails(params.chatId);
  }
}

// Parameters
class GetChatRoomDetailsParams extends Equatable {
  final int chatId;

  const GetChatRoomDetailsParams({required this.chatId});

  @override
  List<Object?> get props => [chatId];
} 