// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiChatMessageModelImpl _$$AiChatMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AiChatMessageModelImpl(
      id: (json['id'] as num?)?.toInt(),
      messageId: (json['message_id'] as num).toInt(),
      conversationId: (json['conversation_id'] as num).toInt(),
      role: json['role'] as String,
      content: json['content'] as String,
      files: json['files'] == null ? const [] : _filesFromJson(json['files']),
      timestamp: (json['timestamp'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$$AiChatMessageModelImplToJson(
        _$AiChatMessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_id': instance.messageId,
      'conversation_id': instance.conversationId,
      'role': instance.role,
      'content': instance.content,
      'files': instance.files,
      'timestamp': instance.timestamp,
      'type': instance.type,
    };
