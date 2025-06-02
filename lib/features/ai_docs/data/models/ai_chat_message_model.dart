import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert'; // Import for jsonDecode
import '../../domain/entities/ai_chat_message_entity.dart';

part 'ai_chat_message_model.freezed.dart';
part 'ai_chat_message_model.g.dart';

/// {@template ai_chat_message_model}
/// Data Transfer Object (DTO) representing a chat message object from the API.
///
/// This model should strictly match the JSON structure returned by the
/// `/model/chat/messages` endpoint and potentially used in SSE events.
/// {@endtemplate}

// --- Custom JSON converter for the 'files' field ---
List<String> _filesFromJson(dynamic jsonValue) {
  if (jsonValue == null) {
    return [];
  }
  if (jsonValue is List) {
    // If it's already a list, assume elements are strings (or add casting/checking)
    return List<String>.from(jsonValue.map((e) => e.toString()));
  }
  if (jsonValue is String) {
    // If it's a string, try to decode it as JSON
    try {
      final decoded = jsonDecode(jsonValue);
      if (decoded is List) {
        // If decoded result is a list, map its elements to strings
        return List<String>.from(decoded.map((e) => e.toString()));
      }
    } catch (e) {
      // Log error if decoding fails
      print("Error decoding 'files' string: $e. Value: $jsonValue");
    }
  }
  // Fallback for unexpected types or decoding errors
  print("Warning: Unexpected type or structure for 'files' field: ${jsonValue.runtimeType}. Value: $jsonValue");
  return [];
}
// --- End of custom converter ---

@freezed
class AiChatMessageModel with _$AiChatMessageModel {
  /// {@macro ai_chat_message_model}
  const AiChatMessageModel._(); // Private constructor for implementing methods

  /// Factory constructor for creating an [AiChatMessageModel].
  const factory AiChatMessageModel({
    int? id, // Optional database ID from API?
    @JsonKey(name: 'message_id') required int messageId,
    @JsonKey(name: 'conversation_id') required int conversationId,
    required String role, // API likely uses 'user' or 'assistant' strings
    required String content,
    @JsonKey(fromJson: _filesFromJson) @Default([]) List<String> files, // List of OSS URLs
    int? timestamp, // API might return seconds or milliseconds
    String? type, // 新增：消息类型字段，从API获取
    // Add other potential fields from API like 'parent_message_id' if needed
  }) = _AiChatMessageModel;

  // --- Restore the generated fromJson factory ---
  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$AiChatMessageModelFromJson(json);
  // --- Remove the manual implementation ---
  /* // Multi-line comment for manual fromJson
  factory AiChatMessageModel.fromJson(Map<String, dynamic> json) {
     // ... (Manual implementation with try-catch) ...
  }
  */ // End multi-line comment

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
      messageId: messageId.toString(),
      conversationId: conversationId,
      sender: domainSender,
      content: content,
      fileUrls: files.isNotEmpty ? files : null,
      timestamp: dateTime,
      messageType: _determineMessageType(), // 使用智能判断
    );
  }

  /// 智能判断消息类型
  MessageType _determineMessageType() {
    // 1. 优先使用API返回的type字段
    if (type != null) {
      switch (type!.toLowerCase()) {
        case 'audio':
        case 'voice':
          return MessageType.audio;
        case 'image':
        case 'picture':
          return MessageType.image;
        case 'text':
        default:
          return MessageType.text;
      }
    }

    // 2. 如果没有type字段，根据文件URL判断
    if (files.isEmpty) {
      return MessageType.text;
    }

    // 检查第一个文件的扩展名
    final firstFile = files.first.toLowerCase();
    
    // 音频文件扩展名
    if (firstFile.contains('.wav') || 
        firstFile.contains('.mp3') || 
        firstFile.contains('.m4a') || 
        firstFile.contains('.aac') ||
        firstFile.contains('.ogg') ||
        firstFile.contains('audio')) {
      return MessageType.audio;
    }
    
    // 图片文件扩展名
    if (firstFile.contains('.jpg') || 
        firstFile.contains('.jpeg') || 
        firstFile.contains('.png') || 
        firstFile.contains('.gif') || 
        firstFile.contains('.webp') ||
        firstFile.contains('.bmp') ||
        firstFile.contains('image') ||
        firstFile.contains('img')) {
      return MessageType.image;
    }

    // 默认情况：有文件但无法判断类型，当作文本处理
    print('Warning: Unknown file type for URL: $firstFile, treating as text');
    return MessageType.text;
  }
} 