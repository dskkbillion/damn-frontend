import '../models/ai_chat_message_model.dart';
import '../models/ai_conversation_model.dart';
import '../models/related_service_model.dart';

/// {@template i_ai_chat_remote_data_source}
/// Interface for the remote data source handling AI Chat API interactions.
///
/// Defines methods for fetching data from and sending data to the backend APIs.
/// Implementations should handle HTTP requests and potentially specific exceptions.
/// {@endtemplate}
abstract class IAiChatRemoteDataSource {
  /// Fetches the list of AI conversations from the `/model/chat/list` endpoint.
  ///
  /// [userId] The ID of the user whose conversations are to be fetched.
  ///
  /// Throws specific exceptions (e.g., ServerException, NetworkException) on failure.
  /// Returns a list of [AiConversationModel] on success.
  Future<List<AiConversationModel>> fetchConversations({required int userId});

  /// Loads the message history for a specific conversation from `/model/chat/messages`.
  ///
  /// [conversationId] The ID of the conversation.
  /// [userId] The ID of the user (required by API).
  /// [offset] Optional offset for pagination.
  /// [limit] Optional limit for pagination.
  ///
  /// Throws specific exceptions on failure.
  /// Returns a list of [AiChatMessageModel] on success.
  Future<List<AiChatMessageModel>> loadHistory({
    required int conversationId,
    required int userId,
    int? offset,
    int? limit,
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
  ///
  /// Throws specific exceptions on connection failure.
  /// Returns a [Stream] of raw SSE event data strings.
  /// The stream should handle closing the connection when the stream is cancelled.
  Stream<String> streamChatCompletion({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
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
} 