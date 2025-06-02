// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_vo_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductVoDto _$ProductVoDtoFromJson(Map<String, dynamic> json) {
  return _ProductVoDto.fromJson(json);
}

/// @nodoc
mixin _$ProductVoDto {
  int get id => throw _privateConstructorUsedError;
  String? get mainImage => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get sellingPrice => throw _privateConstructorUsedError;
  int get inventory => throw _privateConstructorUsedError;
  int get buyedNumber => throw _privateConstructorUsedError;
  int get viewNumber => throw _privateConstructorUsedError;
  int get minimumBuy => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;

  /// Serializes this ProductVoDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVoDtoCopyWith<ProductVoDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVoDtoCopyWith<$Res> {
  factory $ProductVoDtoCopyWith(
          ProductVoDto value, $Res Function(ProductVoDto) then) =
      _$ProductVoDtoCopyWithImpl<$Res, ProductVoDto>;
  @useResult
  $Res call(
      {int id,
      String? mainImage,
      List<String>? images,
      String name,
      double sellingPrice,
      int inventory,
      int buyedNumber,
      int viewNumber,
      int minimumBuy,
      String? state});
}

/// @nodoc
class _$ProductVoDtoCopyWithImpl<$Res, $Val extends ProductVoDto>
    implements $ProductVoDtoCopyWith<$Res> {
  _$ProductVoDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mainImage = freezed,
    Object? images = freezed,
    Object? name = null,
    Object? sellingPrice = null,
    Object? inventory = null,
    Object? buyedNumber = null,
    Object? viewNumber = null,
    Object? minimumBuy = null,
    Object? state = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      mainImage: freezed == mainImage
          ? _value.mainImage
          : mainImage // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      inventory: null == inventory
          ? _value.inventory
          : inventory // ignore: cast_nullable_to_non_nullable
              as int,
      buyedNumber: null == buyedNumber
          ? _value.buyedNumber
          : buyedNumber // ignore: cast_nullable_to_non_nullable
              as int,
      viewNumber: null == viewNumber
          ? _value.viewNumber
          : viewNumber // ignore: cast_nullable_to_non_nullable
              as int,
      minimumBuy: null == minimumBuy
          ? _value.minimumBuy
          : minimumBuy // ignore: cast_nullable_to_non_nullable
              as int,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductVoDtoImplCopyWith<$Res>
    implements $ProductVoDtoCopyWith<$Res> {
  factory _$$ProductVoDtoImplCopyWith(
          _$ProductVoDtoImpl value, $Res Function(_$ProductVoDtoImpl) then) =
      __$$ProductVoDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? mainImage,
      List<String>? images,
      String name,
      double sellingPrice,
      int inventory,
      int buyedNumber,
      int viewNumber,
      int minimumBuy,
      String? state});
}

/// @nodoc
class __$$ProductVoDtoImplCopyWithImpl<$Res>
    extends _$ProductVoDtoCopyWithImpl<$Res, _$ProductVoDtoImpl>
    implements _$$ProductVoDtoImplCopyWith<$Res> {
  __$$ProductVoDtoImplCopyWithImpl(
      _$ProductVoDtoImpl _value, $Res Function(_$ProductVoDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProductVoDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mainImage = freezed,
    Object? images = freezed,
    Object? name = null,
    Object? sellingPrice = null,
    Object? inventory = null,
    Object? buyedNumber = null,
    Object? viewNumber = null,
    Object? minimumBuy = null,
    Object? state = freezed,
  }) {
    return _then(_$ProductVoDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      mainImage: freezed == mainImage
          ? _value.mainImage
          : mainImage // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sellingPrice: null == sellingPrice
          ? _value.sellingPrice
          : sellingPrice // ignore: cast_nullable_to_non_nullable
              as double,
      inventory: null == inventory
          ? _value.inventory
          : inventory // ignore: cast_nullable_to_non_nullable
              as int,
      buyedNumber: null == buyedNumber
          ? _value.buyedNumber
          : buyedNumber // ignore: cast_nullable_to_non_nullable
              as int,
      viewNumber: null == viewNumber
          ? _value.viewNumber
          : viewNumber // ignore: cast_nullable_to_non_nullable
              as int,
      minimumBuy: null == minimumBuy
          ? _value.minimumBuy
          : minimumBuy // ignore: cast_nullable_to_non_nullable
              as int,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVoDtoImpl implements _ProductVoDto {
  const _$ProductVoDtoImpl(
      {required this.id,
      this.mainImage,
      final List<String>? images,
      required this.name,
      required this.sellingPrice,
      this.inventory = 0,
      this.buyedNumber = 0,
      this.viewNumber = 0,
      this.minimumBuy = 0,
      this.state})
      : _images = images;

  factory _$ProductVoDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVoDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String? mainImage;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String name;
  @override
  final double sellingPrice;
  @override
  @JsonKey()
  final int inventory;
  @override
  @JsonKey()
  final int buyedNumber;
  @override
  @JsonKey()
  final int viewNumber;
  @override
  @JsonKey()
  final int minimumBuy;
  @override
  final String? state;

  @override
  String toString() {
    return 'ProductVoDto(id: $id, mainImage: $mainImage, images: $images, name: $name, sellingPrice: $sellingPrice, inventory: $inventory, buyedNumber: $buyedNumber, viewNumber: $viewNumber, minimumBuy: $minimumBuy, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVoDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mainImage, mainImage) ||
                other.mainImage == mainImage) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.inventory, inventory) ||
                other.inventory == inventory) &&
            (identical(other.buyedNumber, buyedNumber) ||
                other.buyedNumber == buyedNumber) &&
            (identical(other.viewNumber, viewNumber) ||
                other.viewNumber == viewNumber) &&
            (identical(other.minimumBuy, minimumBuy) ||
                other.minimumBuy == minimumBuy) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mainImage,
      const DeepCollectionEquality().hash(_images),
      name,
      sellingPrice,
      inventory,
      buyedNumber,
      viewNumber,
      minimumBuy,
      state);

  /// Create a copy of ProductVoDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVoDtoImplCopyWith<_$ProductVoDtoImpl> get copyWith =>
      __$$ProductVoDtoImplCopyWithImpl<_$ProductVoDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVoDtoImplToJson(
      this,
    );
  }
}

abstract class _ProductVoDto implements ProductVoDto {
  const factory _ProductVoDto(
      {required final int id,
      final String? mainImage,
      final List<String>? images,
      required final String name,
      required final double sellingPrice,
      final int inventory,
      final int buyedNumber,
      final int viewNumber,
      final int minimumBuy,
      final String? state}) = _$ProductVoDtoImpl;

  factory _ProductVoDto.fromJson(Map<String, dynamic> json) =
      _$ProductVoDtoImpl.fromJson;

  @override
  int get id;
  @override
  String? get mainImage;
  @override
  List<String>? get images;
  @override
  String get name;
  @override
  double get sellingPrice;
  @override
  int get inventory;
  @override
  int get buyedNumber;
  @override
  int get viewNumber;
  @override
  int get minimumBuy;
  @override
  String? get state;

  /// Create a copy of ProductVoDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVoDtoImplCopyWith<_$ProductVoDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
