// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelatedServiceModelImpl _$$RelatedServiceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RelatedServiceModelImpl(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String?,
      title: json['title'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      price: json['price'] as String?,
    );

Map<String, dynamic> _$$RelatedServiceModelImplToJson(
        _$RelatedServiceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'title': instance.title,
      'rating': instance.rating,
      'price': instance.price,
    };
