import '../models/related_service_model.dart';

/// {@template i_ai_chat_remote_data_source}
/// Interface for the remote data source handling AI Chat API interactions.
///
/// Defines methods for fetching data from and sending data to the backend APIs.
/// Implementations should handle HTTP requests and potentially specific exceptions.
/// {@endtemplate}
abstract class IAiChatRemoteDataSource {
  /// Fetches the list of AI conversations from the `/model/chat/list` endpoint with pagination.
  ///
  /// [userId] The ID of the user whose conversations are to be fetched.
  /// [page] Page number (starting from 1).
  /// [pageSize] Number of conversations per page.
  /// [orderBy] Sort order: 'desc' (newest first) or 'asc' (oldest first).
  ///
  /// Throws specific exceptions (e.g., ServerException, NetworkException) on failure.
  /// Returns a Map containing conversations list and pagination info.
  Future<Map<String, dynamic>> fetchConversations({
    required int userId,
    int page = 1,
    int pageSize = 20,
    String orderBy = 'desc',
  });

  /// Loads the message history for a specific conversation from `/model/chat/messages`.
  /// 
  /// Updated to support new pagination parameters:
  /// [conversationId] The ID of the conversation.
  /// [userId] The ID of the user (required by API).
  /// [page] Page number (starting from 1).
  /// [pageSize] Number of messages per page.
  /// [orderBy] Sort order: 'desc' (newest first) or 'asc' (oldest first).
  /// [getAll] Whether to get all messages (ignores pagination when true).
  ///
  /// Throws specific exceptions on failure.
  /// Returns a Map containing messages list and pagination info.
  Future<Map<String, dynamic>> loadHistory({
    required int conversationId,
    required int userId,
    int page = 1,
    int pageSize = 50,
    String orderBy = 'desc',
    bool getAll = false,
  });

  /// Creates a new conversation via the `/model/chat/create` endpoint.
  ///
  /// [userId] The ID of the user creating the conversation.
  /// [title] Optional initial title.
  ///
  /// Throws specific exceptions on failure.
  /// Returns the new [conversationId] (int) on success.
  Future<int> createConversation({
    required int userId,
    String? title,
  });

  /// Deletes a conversation via the `/model/chat/delete` endpoint.
  ///
  /// [conversationId] The ID of the conversation to delete.
  /// [userId] The ID of the user (required by API).
  ///
  /// Throws specific exceptions on failure.
  /// Returns `void` on success.
  Future<void> deleteConversation({
    required int conversationId,
    required int userId,
  });

  /// Establishes an SSE connection to `/model/chat` to send a message and stream the response.
  ///
  /// [conversationId] The target conversation ID.
  /// [userId] The current user ID.
  /// [message] The text message content.
  /// [fileUrls] List of file URLs (should be valid OSS URLs).
  /// [audioUrls] List of audio URLs for voice messages.
  /// [transcription] Pre-transcribed text for audio messages.
  ///
  /// Throws specific exceptions on connection failure.
  /// Returns a [Stream] of raw SSE event data strings.
  /// The stream should handle closing the connection when the stream is cancelled.
  Stream<String> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
    List<String>? audioUrls,
    String? transcription,
  });

  /// Fetches related service recommendations from `/recsys/conversation/recommend`.
  ///
  /// [conversationId] The ID of the conversation.
  /// [userId] The ID of the user.
  /// [limit] Optional limit for the number of recommendations.
  /// [messageId] Optional message ID to get recommendations related to a specific message.
  ///
  /// Throws specific exceptions on failure.
  /// Returns a list of [RelatedServiceModel] on success.
  /// **Note:** The structure of [RelatedServiceModel] needs verification against the actual API response.
  Future<List<RelatedServiceModel>> getRelatedServices({
    required int conversationId,
    required int userId,
    int? limit,
    int? messageId,
  });

  /// Triggers a chat allocation action (e.g., one-click dispatch).
  /// Corresponds to the /chat/allocate endpoint.
  /// 
  /// Returns the allocation result details on success.
  /// Throws [ServerException], [NetworkException], or [DataSourceException] on failure.
  Future<Map<String, dynamic>> allocateChatResource({
    required int conversationId,
    required int userId,
    required Map<String, dynamic> item, 
    required int merchantId,
  });

  /// Calls the `/model/chat/audio` endpoint for speech-to-text.
  ///
  /// [audioOssUrl] The OSS URL of the audio file to transcribe.
  /// [userId] The user ID (optional according to API doc, confirm if needed).
  ///
  /// Throws specific exceptions on failure.
  /// Returns the transcribed text content (String) on success.
  Future<String> transcribeAudio({
    required String audioOssUrl,
    int? userId, 
  });

  /// Cancels an ongoing chat generation via the `/model/chat/cancel` endpoint.
  ///
  /// [conversationId] The ID of the conversation to cancel.
  /// [userId] The ID of the user requesting the cancellation.
  ///
  /// Throws specific exceptions on failure.
  /// Returns `void` on success.
  Future<void> cancelChatGeneration({
    required int conversationId,
    required int userId,
  });

  /// Updates the title of a conversation via the `/model/chat/title/update` endpoint.
  ///
  /// [conversationId] The ID of the conversation to update.
  /// [userId] The ID of the user (required by API).
  /// [title] The new title for the conversation.
  ///
  /// Throws specific exceptions on failure.
  /// Returns the updated title (String) on success.
  Future<String> updateConversationTitle({
    required int conversationId,
    required int userId,
    required String title,
  });

  /// Generates a title for a conversation via the `/model/chat/title/generate` endpoint.
  ///
  /// [conversationId] The ID of the conversation to generate title for.
  /// [userId] The ID of the user (required by API).
  ///
  /// Throws specific exceptions on failure.
  /// Returns the generated title (String) on success.
  Future<String> generateConversationTitle({
    required int conversationId,
    required int userId,
  });

  /// 查询用户频率限制状态
  ///
  /// [userId] 用户ID
  ///
  /// Throws specific exceptions on failure.
  /// Returns rate limit status data on success.
  Future<Map<String, dynamic>> getRateLimitStatus({
    required int userId,
  });

  /// 重置用户频率限制
  ///
  /// [userId] 用户ID
  /// [serviceType] 服务类型 (conversation/personalized)，可选
  /// [ruleName] 规则名称 (burst/hourly)，可选
  ///
  /// Throws specific exceptions on failure.
  /// Returns reset result data on success.
  Future<Map<String, dynamic>> resetUserRateLimit({
    required int userId,
    String? serviceType,
    String? ruleName,
  });

  /// 获取频率限制配置
  ///
  /// Throws specific exceptions on failure.
  /// Returns rate limit config data on success.
  Future<Map<String, dynamic>> getRateLimitConfig();
} 