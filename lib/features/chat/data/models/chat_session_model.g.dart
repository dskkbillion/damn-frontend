// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSessionModel _$ChatSessionModelFromJson(Map<String, dynamic> json) =>
    ChatSessionModel(
      id: (json['id'] as num).toInt(),
      doctorId: (json['doctorId'] as num?)?.toInt(),
      memberId: (json['memberId'] as num?)?.toInt(),
      messageNum: (json['messageNum'] as num?)?.toInt(),
      context: json['context'] as String?,
      chatMessageNewVo: json['chatMessageNewVo'] == null
          ? null
          : MessageModel.fromJson(
              json['chatMessageNewVo'] as Map<String, dynamic>),
      member: json['member'] == null
          ? null
          : UserModel.fromJson(json['member'] as Map<String, dynamic>),
      doctor: json['doctor'] == null
          ? null
          : UserModel.fromJson(json['doctor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatSessionModelToJson(ChatSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'memberId': instance.memberId,
      'messageNum': instance.messageNum,
      'context': instance.context,
      'chatMessageNewVo': instance.chatMessageNewVo?.toJson(),
      'member': instance.member?.toJson(),
      'doctor': instance.doctor?.toJson(),
    };
