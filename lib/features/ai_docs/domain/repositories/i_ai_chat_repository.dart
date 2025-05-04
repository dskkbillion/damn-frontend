import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ai_chat_message_entity.dart';
import '../entities/ai_conversation_entity.dart';
import '../entities/chat_allocation_result_entity.dart';
import '../entities/related_service_entity.dart';

/// {@template i_ai_chat_repository}
/// Interface for the AI Chat repository.
///
/// Defines the contract for data operations related to AI chat functionality,
/// abstracting the data source details from the domain layer (UseCases).
/// Methods return Either<Failure, SuccessType> to handle potential errors.
/// {@endtemplate}
abstract class IAiChatRepository {
  /// Fetches the list of AI conversations for a given user.
  ///
  /// Returns [Either<Failure, List<AiConversationEntity>>].
  Future<Either<Failure, List<AiConversationEntity>>> fetchConversations(
      {required int userId});

  /// Loads the message history for a specific conversation.
  ///
  /// Supports pagination using [offset] and [limit].
  /// Returns [Either<Failure, List<AiChatMessageEntity>>].
  Future<Either<Failure, List<AiChatMessageEntity>>> loadHistory({
    required int conversationId,
    required int userId,
    int? offset,
    int? limit,
  });

  /// Creates a new AI conversation.
  ///
  /// Returns [Either<Failure, int>] where int is the new conversation ID.
  Future<Either<Failure, int>> createConversation(
      {required int userId, String? title});

  /// Deletes a specific conversation.
  ///
  /// Returns [Either<Failure, void>].
  Future<Either<Failure, void>> deleteConversation(
      {required int conversationId, required int userId});

  /// Sends a message and streams the AI's response using SSE.
  ///
  /// Returns [Either<Failure, Stream<String>>] where the Stream emits
  /// chunks of the AI's response text.
  /// Note: The stream itself might emit errors if the connection drops.
  Future<Either<Failure, Stream<String>>> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls, // URLs of uploaded files
  });

  /// Fetches related service recommendations for a conversation.
  ///
  /// Returns [Either<Failure, List<RelatedServiceEntity>>].
  Future<Either<Failure, List<RelatedServiceEntity>>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
    int? messageId,
  });

  /// Triggers a chat allocation action (e.g., one-click dispatch).
  /// Corresponds to the /chat/allocate endpoint.
  ///
  /// Returns [Either<Failure, ChatAllocationResultEntity>].
  Future<Either<Failure, ChatAllocationResultEntity>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item, 
    required int merchantId,
  });

  /// Transcribes audio from a given URL.
  /// (Corresponds to /model/chat/audio endpoint).
  ///
  /// Returns [Either<Failure, String>] where String is the transcribed text.
  Future<Either<Failure, String>> transcribeAudio(
      {required String audioOssUrl, int? userId});

  // TODO: Consider adding methods for uploading files if that logic belongs here
  // Future<Either<Failure, String>> uploadFile(File file);
} 