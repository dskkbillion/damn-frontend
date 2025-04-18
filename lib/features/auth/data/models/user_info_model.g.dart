// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserInfoModelImpl _$$UserInfoModelImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoModelImpl(
      id: (json['id'] as num).toInt(),
      mobile: json['mobile'] as String,
      nickName: json['nickName'] as String?,
      avatar: json['avatar'] as String?,
      commonUserId: (json['commonUserId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UserInfoModelImplToJson(_$UserInfoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mobile': instance.mobile,
      'nickName': instance.nickName,
      'avatar': instance.avatar,
      'commonUserId': instance.commonUserId,
    };
