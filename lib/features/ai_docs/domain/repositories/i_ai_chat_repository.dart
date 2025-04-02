import 'package:dartz/dartz.dart';

import '../entities/ai_chat_message.dart';
import '../entities/ai_conversation.dart';
import '../entities/failure.dart';
import '../entities/related_service.dart';

/// {@template i_ai_chat_repository}
/// Defines the interface for interacting with AI chat data.
///
/// This repository handles fetching conversations, messages, sending messages,
/// and interacting with related services or features.
/// {@endtemplate}
abstract class IAiChatRepository {
  /// Fetches the list of AI conversations for the current user.
  ///
  /// Returns a list of [AIConversation] on success (Right),
  /// or a [Failure] on error (Left).
  Future<Either<Failure, List<AIConversation>>> listConversations();

  /// Loads the message history for a specific conversation.
  ///
  /// [conversationId] The ID of the conversation to load.
  /// [offset] Optional offset for pagination.
  /// [limit] Optional limit for pagination.
  ///
  /// Returns a list of [AIChatMessage] on success (Right),
  /// or a [Failure] on error (Left).
  Future<Either<Failure, List<AIChatMessage>>> loadHistory(
    int conversationId,
   {int? offset, int? limit}
  );

  /// Starts a new conversation.
  ///
  /// [userId] The ID of the current user (required by API).
  /// [title] Optional initial title for the conversation.
  ///
  /// Returns the new [conversationId] on success (Right),
  /// or a [Failure] on error (Left).
  /// API Endpoint: `/model/chat/create`
  /// Request Body: `{ "user_id": userId, "title": title }`
  Future<Either<Failure, int>> startNewConversation({
    required int userId,
    String? title,
  });

  /// Deletes a specific conversation.
  ///
  /// [conversationId] The ID of the conversation to delete.
  ///
  /// Returns `void` on success (Right), or a [Failure] on error (Left).
  /// API Endpoint: `/model/chat/delete`
  Future<Either<Failure, void>> deleteConversation(int conversationId);

  /// Sends a message to a specific conversation and streams the AI response.
  ///
  /// [conversationId] The target conversation ID.
  /// [userId] The current user ID.
  /// [message] The text message content.
  /// [fileUrls] List of file URLs (should be OSS URLs) associated with the message.
  ///
  /// Returns a [Stream] of AI response chunks (String) on success (Right),
  /// or a [Failure] on error (Left).
  /// API Endpoint: `/model/chat` (via SSE)
  /// Request Body: `{ "model": "dify", "user_id": userId, "message": message, "conversation_id": conversationId, "files": fileUrls, "stream": true }`
  /// **Warning:** Ensure `fileUrls` only contains valid OSS URLs before calling.
  Stream<Either<Failure, String>> sendMessage({
    required int conversationId,
    required int userId,
    required String message,
    required List<String> fileUrls,
  });

  /// Streams the AI's reasoning process for a given conversation (if available).
  ///
  /// [conversationId] The target conversation ID.
  ///
  /// Returns a [Stream] of reasoning chunks (String) on success (Right),
  /// or a [Failure] on error (Left).
  /// Note: This might be part of the same SSE stream as `sendMessage`.
  Stream<Either<Failure, String>> streamReasoning(int conversationId);

  /// Fetches related services for a specific conversation.
  ///
  /// [conversationId] The ID of the conversation.
  ///
  /// Returns a list of [RelatedService] on success (Right),
  /// or a [Failure] on error (Left).
  /// API Endpoint: `/recsys/conversation/recommend`
  Future<Either<Failure, List<RelatedService>>> getRelatedServices(
      int conversationId);

  /// Triggers a matching action (e.g., "one-click dispatch") related to a
  /// conversation and potentially a selected item/service.
  ///
  /// This corresponds to the `/model/chat/package` API.
  /// The exact parameters and return type need further clarification by
  /// analyzing the RN code and backend behavior.
  ///
  /// Returns a success indicator or relevant data (Right), or a [Failure] (Left).
  Future<Either<Failure, dynamic>> triggerMatchingAction({
    required int conversationId,
    required int userId, // From API spec
    required Map<String, dynamic> item, // From API spec {name, description}
    required int limit, // From API spec
    required double similarityThreshold, // From API spec
    // Add other potential parameters based on RN code analysis
  });

  // --- Features marked as abandoned or API missing ---
  // Future<Either<Failure, void>> toggleFavorite(int conversationId, bool isFavorite); // Abandoned
  // Future<Either<Failure, List<PresetQuestion>>> getPresetQuestions(); // Abandoned
  // Future<Either<Failure, void>> reportIssue(...); // Abandoned
  // Future<Either<Failure, List<AIConversation>>> getRelatedConversations(...); // Abandoned
} 