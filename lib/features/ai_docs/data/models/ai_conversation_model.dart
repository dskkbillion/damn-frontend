import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import '../../domain/entities/ai_conversation_entity.dart';

part 'ai_conversation_model.freezed.dart';
part 'ai_conversation_model.g.dart';

/// {@template ai_conversation_model}
/// Data Transfer Object (DTO) representing a conversation object from the API.
///
/// This model should strictly match the JSON structure returned by the
/// `/model/chat/list` endpoint.
/// {@endtemplate}
@freezed
class AiConversationModel with _$AiConversationModel {
  /// {@macro ai_conversation_model}
  const AiConversationModel._(); // Private constructor for implementing methods

  /// Factory constructor for creating an [AiConversationModel].
  ///
  /// Uses `JsonKey` annotations to map JSON keys to field names if they differ
  /// (e.g., `snake_case` in JSON to `camelCase` in Dart).
  const factory AiConversationModel({
    @JsonKey(name: 'conversation_id') required int conversationId,
    String? title, // Assumes JSON key is also 'title'
    @JsonKey(name: 'created_at') String? createdAtString, // Read as String first
    @JsonKey(name: 'updated_at') String? updatedAtString, // Read as String first
    @JsonKey(name: 'first_message') String? firstMessage,
    @JsonKey(name: 'message_count') int? messageCount,
    // No isFavorite field as feature is abandoned
  }) = _AiConversationModel;

  /// Creates an [AiConversationModel] from a JSON map.
  factory AiConversationModel.fromJson(Map<String, dynamic> json) =>
      _$AiConversationModelFromJson(json);

  /// Converts this [AiConversationModel] to its corresponding Domain [AiConversationEntity].
  ///
  /// Handles potential `DateTime` parsing errors.
  AiConversationEntity toEntity() {
    DateTime? createdAtDt;
    DateTime? updatedAtDt;
    try {
      if (createdAtString != null) {
        createdAtDt = DateTime.parse(createdAtString!);
      }
      if (updatedAtString != null) {
        updatedAtDt = DateTime.parse(updatedAtString!);
      }
    } catch (e) {
      // Log or handle parsing error if necessary
      AppLogger.d('Error parsing date string in AiConversationModel: $e');
      // Keep dates as null if parsing fails
    }

    return AiConversationEntity(
      id: conversationId,
      title: title,
      createdAt: createdAtDt,
      updatedAt: updatedAtDt,
    );
  }
} 