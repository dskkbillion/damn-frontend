// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_vo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductVoDtoImpl _$$ProductVoDtoImplFromJson(Map<String, dynamic> json) =>
    _$ProductVoDtoImpl(
      id: (json['id'] as num).toInt(),
      mainImage: json['mainImage'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      name: json['name'] as String,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      inventory: (json['inventory'] as num?)?.toInt() ?? 0,
      buyedNumber: (json['buyedNumber'] as num?)?.toInt() ?? 0,
      viewNumber: (json['viewNumber'] as num?)?.toInt() ?? 0,
      minimumBuy: (json['minimumBuy'] as num?)?.toInt() ?? 0,
      state: json['state'] as String?,
    );

Map<String, dynamic> _$$ProductVoDtoImplToJson(_$ProductVoDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mainImage': instance.mainImage,
      'images': instance.images,
      'name': instance.name,
      'sellingPrice': instance.sellingPrice,
      'inventory': instance.inventory,
      'buyedNumber': instance.buyedNumber,
      'viewNumber': instance.viewNumber,
      'minimumBuy': instance.minimumBuy,
      'state': instance.state,
    };
