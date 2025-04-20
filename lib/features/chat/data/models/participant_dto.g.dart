// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipantDtoImpl _$$ParticipantDtoImplFromJson(Map<String, dynamic> json) =>
    _$ParticipantDtoImpl(
      id: (json['id'] as num).toInt(),
      nickName: json['nickName'] as String?,
      avatar: json['avatar'] as String?,
      type: json['type'] as String?,
      referId: (json['referId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ParticipantDtoImplToJson(
        _$ParticipantDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickName': instance.nickName,
      'avatar': instance.avatar,
      'type': instance.type,
      'referId': instance.referId,
    };
