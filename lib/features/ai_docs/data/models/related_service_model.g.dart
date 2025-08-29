// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelatedServiceModelImpl _$$RelatedServiceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RelatedServiceModelImpl(
      id: (json['id'] as num).toInt(),
      imageUrl: json['mainImage'] as String,
      title: json['name'] as String,
      price: (json['sellingPrice'] as num).toDouble(),
      allocationStatusRecorded:
          json['allocation_status_recorded'] as bool? ?? false,
      tenantId: (json['tenantId'] as num).toInt(),
    );

Map<String, dynamic> _$$RelatedServiceModelImplToJson(
        _$RelatedServiceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mainImage': instance.imageUrl,
      'name': instance.title,
      'sellingPrice': instance.price,
      'allocation_status_recorded': instance.allocationStatusRecorded,
      'tenantId': instance.tenantId,
    };
