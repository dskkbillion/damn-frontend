import 'package:equatable/equatable.dart';

/// Type of the message content.
enum MessageType {
  text,
  image,
  audio,
  // Add other types like file, system notification etc. if needed
}

/// Represents the sender of a chat message (USER or AI).
enum MessageSender {
  user, 
  ai,
  system // Optional: For system messages/notifications within the chat
}

/// {@template ai_chat_message_entity}
/// Represents a single chat message in the domain layer.
/// {@endtemplate}
class AiChatMessageEntity extends Equatable {
  final String messageId;
  final MessageSender sender;
  final int conversationId;
  final DateTime? timestamp;
  
  // --- Content Fields ---
  final MessageType messageType; // Added field for type
  final String content; // Used for text messages
  final List<String>? fileUrls; // Used for image URL(s) or audio URL

  // Removed isStreaming, hasError - these should be UI state, not entity properties

  /// {@macro ai_chat_message_entity}
  const AiChatMessageEntity({
    required this.messageId,
    required this.sender,
    required this.conversationId,
    this.timestamp,
    // Default to text, make required
    this.messageType = MessageType.text, 
    // Content might be empty for non-text messages initially
    this.content = '', 
    this.fileUrls, 
  });

  @override
  List<Object?> get props => [
        messageId,
        sender,
        conversationId,
        timestamp,
        messageType,
        content,
        fileUrls,
      ];
} 