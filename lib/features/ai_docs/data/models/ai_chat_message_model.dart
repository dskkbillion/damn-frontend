import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ai_chat_message_entity.dart';

part 'ai_chat_message_model.freezed.dart';
part 'ai_chat_message_model.g.dart';

/// {@template ai_chat_message_model}
/// Data Transfer Object (DTO) representing a chat message object from the API.
///
/// This model should strictly match the JSON structure returned by the
/// `/model/chat/messages` endpoint and potentially used in SSE events.
/// {@endtemplate}
@freezed
class AiChatMessageModel with _$AiChatMessageModel {
  /// {@macro ai_chat_message_model}
  const AiChatMessageModel._(); // Private constructor for implementing methods

  /// Factory constructor for creating an [AiChatMessageModel].
  const factory AiChatMessageModel({
    int? id, // Optional database ID from API?
    @JsonKey(name: 'message_id') required String messageId,
    @JsonKey(name: 'conversation_id') required int conversationId,
    required String role, // API likely uses 'user' or 'assistant' strings
    required String content,
    @Default([]) List<String> files, // List of OSS URLs
    int? timestamp, // API might return seconds or milliseconds
    // Add other potential fields from API like 'parent_message_id' if needed
  }) = _AiChatMessageModel;

  /// Creates an [AiChatMessageModel] from a JSON map.
  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageModelFromJson(json);

  /// Converts this [AiChatMessageModel] to its corresponding Domain [AiChatMessageEntity].
  AiChatMessageEntity toEntity() {
    MessageSender domainSender;
    switch (role.toLowerCase()) {
      case 'user':
        domainSender = MessageSender.user;
        break;
      case 'assistant':
        domainSender = MessageSender.ai;
        break;
      default:
        // Handle unexpected role string
        print('Warning: Unknown message role "$role", defaulting to system.');
        domainSender = MessageSender.system;
    }

    DateTime? dateTime;
    if (timestamp != null) {
      // Assuming timestamp is in seconds since epoch, adjust if milliseconds
      try {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
      } catch (e) {
        print('Error parsing timestamp in AiChatMessageModel: $e');
        // Keep dateTime as null if parsing fails
      }
    }

    return AiChatMessageEntity(
      messageId: messageId,
      conversationId: conversationId,
      sender: domainSender,
      content: content,
      fileUrls: files.isNotEmpty ? files : null,
      timestamp: dateTime,
    );
  }
} 