import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/i_chat_repository.dart';

// Use case definition
abstract class GetMessageList implements UseCase<List<ChatMessage>, GetMessageListParams> {}

// Implementation
class GetMessageListImpl implements GetMessageList {
  final IChatRepository repository;

  GetMessageListImpl(this.repository);

  @override
  Future<Either<Failure, List<ChatMessage>>> call(GetMessageListParams params) async {
    return await repository.getMessages(params.chatId);
  }
}

// Parameters
class GetMessageListParams extends Equatable {
  final int chatId;

  const GetMessageListParams({required this.chatId});

  @override
  List<Object?> get props => [chatId];
} 