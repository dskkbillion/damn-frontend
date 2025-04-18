import 'dart:async'; // Required for Stream

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template stream_chat_completion_usecase}
/// Use case for sending a message and streaming the AI's response.
/// 
/// It handles the initial call to the repository to get the stream.
/// The caller (e.g., Bloc/Cubit) is responsible for listening to the stream
/// and handling events/errors during the stream.
/// {@endtemplate}
@lazySingleton
class StreamChatCompletionUseCase 
    implements UseCase<Stream<String>, StreamChatCompletionParams> {
      
  final IAiChatRepository repository;

  /// {@macro stream_chat_completion_usecase}
  StreamChatCompletionUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<String>>> call(
      StreamChatCompletionParams params) async {
        
    // **Important:** Input validation, especially for fileUrls, should happen here
    // or before calling this use case. Ensure fileUrls contains only valid OSS URLs
    // if the backend cannot handle local URIs.
    // Example check (needs refinement based on actual URL format):
    // if (params.fileUrls.any((url) => !url.startsWith('http'))) {
    //   return Left(GeneralFailure(message: 'Invalid file URL detected.'));
    // }

    return await repository.streamChatCompletion(
      conversationId: params.conversationId,
      userId: params.userId,
      message: params.message,
      fileUrls: params.fileUrls,
    );
  }
}

/// {@template stream_chat_completion_params}
/// Parameters required for streaming chat completions.
/// {@endtemplate}
class StreamChatCompletionParams extends Equatable {
  final int conversationId;
  final int userId;
  final String message;
  final List<String> fileUrls; // Should contain OSS URLs before calling

  /// {@macro stream_chat_completion_params}
  const StreamChatCompletionParams({
    required this.conversationId,
    required this.userId,
    required this.message,
    required this.fileUrls,
  });

  @override
  List<Object?> get props => [conversationId, userId, message, fileUrls];
} 