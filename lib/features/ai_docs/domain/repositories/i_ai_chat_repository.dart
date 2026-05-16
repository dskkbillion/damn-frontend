import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/allocated_item_entity.dart';
import '../entities/chat_allocation_result_entity.dart';
import '../entities/related_service_entity.dart';
import '../usecases/load_history_usecase.dart';
import '../usecases/get_conversations_usecase.dart';

/// {@template i_ai_chat_repository}
/// Interface for the AI Chat repository.
///
/// Defines the contract for data operations related to AI chat functionality,
/// abstracting the data source details from the domain layer (UseCases).
/// Methods return Either<Failure, SuccessType> to handle potential errors.
/// {@endtemplate}
abstract class IAiChatRepository {
  /// Fetches the list of AI conversations for a given user with pagination.
  ///
  /// Supports pagination using [page], [pageSize], and [orderBy].
  /// Returns [Either<Failure, GetConversationsResult>].
  Future<Either<Failure, GetConversationsResult>> fetchConversations({
    required int userId,
    int page = 1,
    int pageSize = 20,
    String orderBy = 'desc',
  });

  /// Loads the message history for a specific conversation with pagination.
  ///
  /// Supports new pagination using [page], [pageSize], [orderBy], and [getAll].
  /// Returns [Either<Failure, LoadHistoryResult>].
  Future<Either<Failure, LoadHistoryResult>> loadHistory({
    required int conversationId,
    required int userId,
    int page = 1,
    int pageSize = 50,
    String orderBy = 'desc',
    bool getAll = false,
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
    List<String>? audioUrls,
    String? transcription,
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

  /// 获取某 conversation 的已分发商品历史(#347)。
  /// 按 allocatedAt desc 排序。可能返回空列表(无历史)。
  Future<Either<Failure, List<AllocatedItemEntity>>> getDispatchHistory({
    required int conversationId,
    required int userId,
  });

  /// Transcribes audio from a given URL.
  /// (Corresponds to /model/chat/audio endpoint).
  ///
  /// Returns [Either<Failure, String>] where String is the transcribed text.
  Future<Either<Failure, String>> transcribeAudio(
      {required String audioOssUrl, int? userId});

  /// Cancels an ongoing chat generation.
  /// (Corresponds to /model/chat/cancel endpoint).
  ///
  /// Returns [Either<Failure, void>].
  Future<Either<Failure, void>> cancelChatGeneration({
    required int conversationId,
    required int userId,
  });

  /// Updates the title of a specific conversation.
  ///
  /// Returns [Either<Failure, String>] where String is the updated title.
  Future<Either<Failure, String>> updateConversationTitle({
    required int conversationId,
    required int userId,
    required String title,
  });

  /// Generates a title for a specific conversation using AI.
  ///
  /// Returns [Either<Failure, String>] where String is the generated title.
  Future<Either<Failure, String>> generateConversationTitle({
    required int conversationId,
    required int userId,
  });

  // TODO: Consider adding methods for uploading files if that logic belongs here
  // Future<Either<Failure, String>> uploadFile(File file);
} 