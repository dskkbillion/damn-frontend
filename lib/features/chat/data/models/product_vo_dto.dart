import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_vo_dto.freezed.dart';
part 'product_vo_dto.g.dart';

@freezed
class ProductVoDto with _$ProductVoDto {
  const factory ProductVoDto({
    required int id,
    String? mainImage,
    List<String>? images,
    required String name,
    required double sellingPrice,
    @Default(0) int inventory,
    @Default(0) int buyedNumber,
    @Default(0) int viewNumber,
    @Default(0) int minimumBuy,
    String? state,
  }) = _ProductVoDto;

  factory ProductVoDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVoDtoFromJson(json);
} 