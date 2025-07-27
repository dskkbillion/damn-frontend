// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CountryCodeImpl _$$CountryCodeImplFromJson(Map<String, dynamic> json) =>
    _$CountryCodeImpl(
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      code: json['code'] as String,
      dialCode: json['dialCode'] as String,
      flag: json['flag'] as String,
    );

Map<String, dynamic> _$$CountryCodeImplToJson(_$CountryCodeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameEn': instance.nameEn,
      'code': instance.code,
      'dialCode': instance.dialCode,
      'flag': instance.flag,
    };
