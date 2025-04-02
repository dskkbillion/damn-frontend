import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template send_message}
/// Sends a user message to an AI conversation and streams the response.
///
/// This use case validates input, potentially triggers file uploads (though
/// upload logic should ideally be handled before calling this),
/// and then interacts with the [IAiChatRepository] to send the message
/// and receive the streamed response.
/// {@endtemplate}
class SendMessage {
  final IAiChatRepository _repository;
  // Potentially inject IFileRepository if upload needs triggering here?
  // Or assume URLs are already uploaded as per current repo interface.

  /// {@macro send_message}
  const SendMessage(this._repository);

  /// Executes the use case to send a message.
  ///
  /// [params] The parameters required to send the message.
  ///
  /// Returns a [Stream] of AI response chunks (String) on success (Right),
  /// or a [Failure] on error (Left).
  Stream<Either<Failure, String>> call(SendMessageParams params) {
    // 1. Input Validation (Example)
    if (params.message.trim().isEmpty && params.fileUrls.isEmpty) {
      // Use dartz's left factory constructor
      return Stream.value(Left(const InvalidInputFailure(
          message: 'Cannot send an empty message without files.')));
    }
    // Add more validation as needed (e.g., check URL format if possible)

    // 2. Trigger Repository Method
    // Warning about fileUrls content should be handled by the caller or
    // potentially re-checked here if necessary.
    return _repository.sendMessage(
      conversationId: params.conversationId,
      userId: params.userId,
      message: params.message,
      fileUrls: params.fileUrls,
    );
  }
}

/// Parameters required for the [SendMessage] use case.
class SendMessageParams {
  final int conversationId;
  final int userId;
  final String message;
  final List<String> fileUrls; // Should be OSS URLs

  const SendMessageParams({
    required this.conversationId,
    required this.userId,
    required this.message,
    required this.fileUrls,
  });
} 