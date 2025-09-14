// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageDtoImpl _$$ChatMessageDtoImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageDtoImpl(
      id: (json['id'] as num?)?.toInt(),
      chatId: (json['chatId'] as num).toInt(),
      doctorId: (json['doctorId'] as num?)?.toInt(),
      memberId: (json['memberId'] as num?)?.toInt(),
      context: json['context'] as String,
      type: json['type'] as String,
      createTime: json['createTime'] as String?,
      withdrawFlag: json['withdrawFlag'] as bool? ?? false,
      readFlg: json['readFlg'] as bool?,
    );

Map<String, dynamic> _$$ChatMessageDtoImplToJson(
        _$ChatMessageDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'doctorId': instance.doctorId,
      'memberId': instance.memberId,
      'context': instance.context,
      'type': instance.type,
      'createTime': instance.createTime,
      'withdrawFlag': instance.withdrawFlag,
      'readFlg': instance.readFlg,
    };
