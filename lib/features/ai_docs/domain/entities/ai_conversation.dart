import 'package:equatable/equatable.dart';

/// {@template ai_conversation}
/// Represents a single AI chat conversation session.
///
/// Corresponds to the data structure returned by the `/model/chat/list` API endpoint.
/// {@endtemplate}
class AIConversation extends Equatable {
  /// {@macro ai_conversation}
  const AIConversation({
    required this.conversationId,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.firstMessage,
    this.messageCount,
    // isFavorite is removed as the feature is abandoned
  });

  /// Unique identifier for the conversation.
  final int conversationId;

  /// Optional title for the conversation, potentially generated from the first message.
  final String? title;

  /// Timestamp when the conversation was created.
  final DateTime? createdAt;

  /// Timestamp when the conversation was last updated.
  final DateTime? updatedAt;

  /// The content of the first message in the conversation, if available.
  final String? firstMessage;

  /// The total number of messages in the conversation.
  final int? messageCount;

  @override
  List<Object?> get props => [
        conversationId,
        title,
        createdAt,
        updatedAt,
        firstMessage,
        messageCount,
      ];

  /// Creates a copy of this [AIConversation] but with the given fields replaced with
  /// the new values.
  AIConversation copyWith({
    int? conversationId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstMessage,
    int? messageCount,
  }) {
    return AIConversation(
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstMessage: firstMessage ?? this.firstMessage,
      messageCount: messageCount ?? this.messageCount,
    );
  }
} 