import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/i_chat_repository.dart';
import '../repositories/i_file_repository.dart'; // Needed for file uploads

// Use case definition
abstract class SendMessage implements UseCase<ChatMessage, SendMessageParams> {}

// Implementation
class SendMessageImpl implements SendMessage {
  final IChatRepository chatRepository;
  final IFileRepository fileRepository; // Inject file repository

  SendMessageImpl(this.chatRepository, this.fileRepository);

  @override
  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    ChatMessage messageToSend = params.message;

    // If it's an image or audio message, upload the file first
    if ((messageToSend.type == 'image' || messageToSend.type == 'audio') && params.file != null) {
      final uploadResult = await fileRepository.uploadFile(params.file!);

      // Handle upload failure
      if (uploadResult.isLeft()) {
        return uploadResult.fold((failure) => Left(failure), (_) => throw Exception('Unreachable')); // Should not happen
      }

      // Update message context with the uploaded file URL
      final fileUrl = uploadResult.getOrElse(() => ''); // Should always have a value if isRight()
      if (fileUrl.isEmpty) {
        return Left(GeneralFailure());
      }
       // Important: Create a *new* instance with the updated context
      messageToSend = messageToSend.copyWith(context: fileUrl);
    } else if ((messageToSend.type == 'image' || messageToSend.type == 'audio') && params.file == null) {
       return Left(GeneralFailure());
    }

    // Send the message (text or file URL as context)
    return await chatRepository.sendMessage(messageToSend);
  }
}

// Parameters
class SendMessageParams extends Equatable {
  final ChatMessage message; // Contains chatId, type, context (for text), memberId, doctorId etc.
  final File? file; // File is needed for image/audio types

  const SendMessageParams({required this.message, this.file});

  @override
  List<Object?> get props => [message, file];
} 