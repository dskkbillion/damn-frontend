import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
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

    AppLogger.d('[SendMessage] Type: ${messageToSend.type}, File provided: ${params.file != null}, Context: ${messageToSend.context}');

    // If it's an image or audio message with a file, upload the file first
    if ((messageToSend.type == 'image' || messageToSend.type == 'audio') && params.file != null) {
      AppLogger.d('[SendMessage] Uploading file for ${messageToSend.type} message: ${params.file!.path}');
      final uploadResult = await fileRepository.uploadFile(params.file!);

      // Handle upload failure
      if (uploadResult.isLeft()) {
        AppLogger.d('[SendMessage] File upload failed');
        return uploadResult.fold((failure) => Left(failure), (_) => throw Exception('Unreachable')); // Should not happen
      }

      // Update message context with the uploaded file URL
      final fileUrl = uploadResult.getOrElse(() => ''); // Should always have a value if isRight()
      AppLogger.d('[SendMessage] File uploaded successfully. URL: $fileUrl');
      if (fileUrl.isEmpty) {
        return Left(GeneralFailure(message: '发送消息失败，参数无效'));
      }
       // Important: Create a *new* instance with the updated context
      messageToSend = messageToSend.copyWith(context: fileUrl);
    } else if ((messageToSend.type == 'image' || messageToSend.type == 'audio' || messageToSend.type == 'file') && params.file == null) {
      // 如果是文件类型（包括图片、音频、文档）且没有提供文件，检查 context 是否已包含 URL 或 JSON
      // 如果 context 已经包含 URL 或 JSON（说明文件已经上传），则继续发送
      AppLogger.d('[SendMessage] File type message without file. Context: ${messageToSend.context}');
      if (messageToSend.context == null || messageToSend.context!.isEmpty) {
        return Left(GeneralFailure(message: '发送消息失败，参数无效'));
      }
      // 如果 context 有内容（URL 或 JSON），继续发送
    }

    AppLogger.d('[SendMessage] Sending message with context: ${messageToSend.context}');
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