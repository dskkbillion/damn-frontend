// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiConversationModelImpl _$$AiConversationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AiConversationModelImpl(
      conversationId: (json['conversation_id'] as num).toInt(),
      title: json['title'] as String?,
      createdAtString: json['created_at'] as String?,
      updatedAtString: json['updated_at'] as String?,
      firstMessage: json['first_message'] as String?,
      messageCount: (json['message_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AiConversationModelImplToJson(
        _$AiConversationModelImpl instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'title': instance.title,
      'created_at': instance.createdAtString,
      'updated_at': instance.updatedAtString,
      'first_message': instance.firstMessage,
      'message_count': instance.messageCount,
    };
