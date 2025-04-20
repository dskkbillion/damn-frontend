// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomDtoImpl _$$ChatRoomDtoImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomDtoImpl(
      id: (json['id'] as num).toInt(),
      member: ParticipantDto.fromJson(json['member'] as Map<String, dynamic>),
      doctor: ParticipantDto.fromJson(json['doctor'] as Map<String, dynamic>),
      messageNum: (json['messageNum'] as num?)?.toInt() ?? 0,
      chatMessageNewVo: json['chatMessageNewVo'] == null
          ? null
          : ChatMessageDto.fromJson(
              json['chatMessageNewVo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatRoomDtoImplToJson(_$ChatRoomDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member': instance.member,
      'doctor': instance.doctor,
      'messageNum': instance.messageNum,
      'chatMessageNewVo': instance.chatMessageNewVo,
    };
