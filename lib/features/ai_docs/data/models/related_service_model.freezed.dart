// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'related_service_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RelatedServiceModel _$RelatedServiceModelFromJson(Map<String, dynamic> json) {
  return _RelatedServiceModel.fromJson(json);
}

/// @nodoc
mixin _$RelatedServiceModel {
// Updated fields and types based on actual API response.
  int get id => throw _privateConstructorUsedError; // Changed to int
  @JsonKey(name: 'mainImage')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get title =>
      throw _privateConstructorUsedError; // rating field removed
  @JsonKey(name: 'sellingPrice')
  double get price => throw _privateConstructorUsedError; // Changed to double
  @JsonKey(name: 'allocation_status_recorded')
  bool get allocationStatusRecorded => throw _privateConstructorUsedError;
  @JsonKey(name: 'tenantId')
  int get tenantId => throw _privateConstructorUsedError;

  /// Serializes this RelatedServiceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RelatedServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelatedServiceModelCopyWith<RelatedServiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelatedServiceModelCopyWith<$Res> {
  factory $RelatedServiceModelCopyWith(
          RelatedServiceModel value, $Res Function(RelatedServiceModel) then) =
      _$RelatedServiceModelCopyWithImpl<$Res, RelatedServiceModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'mainImage') String imageUrl,
      @JsonKey(name: 'name') String title,
      @JsonKey(name: 'sellingPrice') double price,
      @JsonKey(name: 'allocation_status_recorded')
      bool allocationStatusRecorded,
      @JsonKey(name: 'tenantId') int tenantId});
}

/// @nodoc
class _$RelatedServiceModelCopyWithImpl<$Res, $Val extends RelatedServiceModel>
    implements $RelatedServiceModelCopyWith<$Res> {
  _$RelatedServiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelatedServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? title = null,
    Object? price = null,
    Object? allocationStatusRecorded = null,
    Object? tenantId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      allocationStatusRecorded: null == allocationStatusRecorded
          ? _value.allocationStatusRecorded
          : allocationStatusRecorded // ignore: cast_nullable_to_non_nullable
              as bool,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelatedServiceModelImplCopyWith<$Res>
    implements $RelatedServiceModelCopyWith<$Res> {
  factory _$$RelatedServiceModelImplCopyWith(_$RelatedServiceModelImpl value,
          $Res Function(_$RelatedServiceModelImpl) then) =
      __$$RelatedServiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'mainImage') String imageUrl,
      @JsonKey(name: 'name') String title,
      @JsonKey(name: 'sellingPrice') double price,
      @JsonKey(name: 'allocation_status_recorded')
      bool allocationStatusRecorded,
      @JsonKey(name: 'tenantId') int tenantId});
}

/// @nodoc
class __$$RelatedServiceModelImplCopyWithImpl<$Res>
    extends _$RelatedServiceModelCopyWithImpl<$Res, _$RelatedServiceModelImpl>
    implements _$$RelatedServiceModelImplCopyWith<$Res> {
  __$$RelatedServiceModelImplCopyWithImpl(_$RelatedServiceModelImpl _value,
      $Res Function(_$RelatedServiceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RelatedServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? title = null,
    Object? price = null,
    Object? allocationStatusRecorded = null,
    Object? tenantId = null,
  }) {
    return _then(_$RelatedServiceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      allocationStatusRecorded: null == allocationStatusRecorded
          ? _value.allocationStatusRecorded
          : allocationStatusRecorded // ignore: cast_nullable_to_non_nullable
              as bool,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none)
class _$RelatedServiceModelImpl extends _RelatedServiceModel {
  const _$RelatedServiceModelImpl(
      {required this.id,
      @JsonKey(name: 'mainImage') required this.imageUrl,
      @JsonKey(name: 'name') required this.title,
      @JsonKey(name: 'sellingPrice') required this.price,
      @JsonKey(name: 'allocation_status_recorded')
      this.allocationStatusRecorded = false,
      @JsonKey(name: 'tenantId') required this.tenantId})
      : super._();

  factory _$RelatedServiceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelatedServiceModelImplFromJson(json);

// Updated fields and types based on actual API response.
  @override
  final int id;
// Changed to int
  @override
  @JsonKey(name: 'mainImage')
  final String imageUrl;
  @override
  @JsonKey(name: 'name')
  final String title;
// rating field removed
  @override
  @JsonKey(name: 'sellingPrice')
  final double price;
// Changed to double
  @override
  @JsonKey(name: 'allocation_status_recorded')
  final bool allocationStatusRecorded;
  @override
  @JsonKey(name: 'tenantId')
  final int tenantId;

  @override
  String toString() {
    return 'RelatedServiceModel(id: $id, imageUrl: $imageUrl, title: $title, price: $price, allocationStatusRecorded: $allocationStatusRecorded, tenantId: $tenantId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelatedServiceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(
                    other.allocationStatusRecorded, allocationStatusRecorded) ||
                other.allocationStatusRecorded == allocationStatusRecorded) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageUrl, title, price,
      allocationStatusRecorded, tenantId);

  /// Create a copy of RelatedServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelatedServiceModelImplCopyWith<_$RelatedServiceModelImpl> get copyWith =>
      __$$RelatedServiceModelImplCopyWithImpl<_$RelatedServiceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelatedServiceModelImplToJson(
      this,
    );
  }
}

abstract class _RelatedServiceModel extends RelatedServiceModel {
  const factory _RelatedServiceModel(
          {required final int id,
          @JsonKey(name: 'mainImage') required final String imageUrl,
          @JsonKey(name: 'name') required final String title,
          @JsonKey(name: 'sellingPrice') required final double price,
          @JsonKey(name: 'allocation_status_recorded')
          final bool allocationStatusRecorded,
          @JsonKey(name: 'tenantId') required final int tenantId}) =
      _$RelatedServiceModelImpl;
  const _RelatedServiceModel._() : super._();

  factory _RelatedServiceModel.fromJson(Map<String, dynamic> json) =
      _$RelatedServiceModelImpl.fromJson;

// Updated fields and types based on actual API response.
  @override
  int get id; // Changed to int
  @override
  @JsonKey(name: 'mainImage')
  String get imageUrl;
  @override
  @JsonKey(name: 'name')
  String get title; // rating field removed
  @override
  @JsonKey(name: 'sellingPrice')
  double get price; // Changed to double
  @override
  @JsonKey(name: 'allocation_status_recorded')
  bool get allocationStatusRecorded;
  @override
  @JsonKey(name: 'tenantId')
  int get tenantId;

  /// Create a copy of RelatedServiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelatedServiceModelImplCopyWith<_$RelatedServiceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
