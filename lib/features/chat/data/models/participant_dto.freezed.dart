// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ParticipantDto _$ParticipantDtoFromJson(Map<String, dynamic> json) {
  return _ParticipantDto.fromJson(json);
}

/// @nodoc
mixin _$ParticipantDto {
  int get id => throw _privateConstructorUsedError;
  String? get nickName => throw _privateConstructorUsedError;
  String? get trueName => throw _privateConstructorUsedError;
  String? get mobile => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  String? get type =>
      throw _privateConstructorUsedError; // 'MEMBER', 'DOCTOR', 'ADMIN'
  int? get referId => throw _privateConstructorUsedError;

  /// Serializes this ParticipantDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantDtoCopyWith<ParticipantDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantDtoCopyWith<$Res> {
  factory $ParticipantDtoCopyWith(
          ParticipantDto value, $Res Function(ParticipantDto) then) =
      _$ParticipantDtoCopyWithImpl<$Res, ParticipantDto>;
  @useResult
  $Res call(
      {int id,
      String? nickName,
      String? trueName,
      String? mobile,
      String? avatar,
      String? type,
      int? referId});
}

/// @nodoc
class _$ParticipantDtoCopyWithImpl<$Res, $Val extends ParticipantDto>
    implements $ParticipantDtoCopyWith<$Res> {
  _$ParticipantDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickName = freezed,
    Object? trueName = freezed,
    Object? mobile = freezed,
    Object? avatar = freezed,
    Object? type = freezed,
    Object? referId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nickName: freezed == nickName
          ? _value.nickName
          : nickName // ignore: cast_nullable_to_non_nullable
              as String?,
      trueName: freezed == trueName
          ? _value.trueName
          : trueName // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      referId: freezed == referId
          ? _value.referId
          : referId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParticipantDtoImplCopyWith<$Res>
    implements $ParticipantDtoCopyWith<$Res> {
  factory _$$ParticipantDtoImplCopyWith(_$ParticipantDtoImpl value,
          $Res Function(_$ParticipantDtoImpl) then) =
      __$$ParticipantDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? nickName,
      String? trueName,
      String? mobile,
      String? avatar,
      String? type,
      int? referId});
}

/// @nodoc
class __$$ParticipantDtoImplCopyWithImpl<$Res>
    extends _$ParticipantDtoCopyWithImpl<$Res, _$ParticipantDtoImpl>
    implements _$$ParticipantDtoImplCopyWith<$Res> {
  __$$ParticipantDtoImplCopyWithImpl(
      _$ParticipantDtoImpl _value, $Res Function(_$ParticipantDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nickName = freezed,
    Object? trueName = freezed,
    Object? mobile = freezed,
    Object? avatar = freezed,
    Object? type = freezed,
    Object? referId = freezed,
  }) {
    return _then(_$ParticipantDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nickName: freezed == nickName
          ? _value.nickName
          : nickName // ignore: cast_nullable_to_non_nullable
              as String?,
      trueName: freezed == trueName
          ? _value.trueName
          : trueName // ignore: cast_nullable_to_non_nullable
              as String?,
      mobile: freezed == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      referId: freezed == referId
          ? _value.referId
          : referId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipantDtoImpl extends _ParticipantDto {
  const _$ParticipantDtoImpl(
      {required this.id,
      this.nickName,
      this.trueName,
      this.mobile,
      this.avatar,
      this.type,
      this.referId})
      : super._();

  factory _$ParticipantDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String? nickName;
  @override
  final String? trueName;
  @override
  final String? mobile;
  @override
  final String? avatar;
  @override
  final String? type;
// 'MEMBER', 'DOCTOR', 'ADMIN'
  @override
  final int? referId;

  @override
  String toString() {
    return 'ParticipantDto(id: $id, nickName: $nickName, trueName: $trueName, mobile: $mobile, avatar: $avatar, type: $type, referId: $referId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nickName, nickName) ||
                other.nickName == nickName) &&
            (identical(other.trueName, trueName) ||
                other.trueName == trueName) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.referId, referId) || other.referId == referId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, nickName, trueName, mobile, avatar, type, referId);

  /// Create a copy of ParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantDtoImplCopyWith<_$ParticipantDtoImpl> get copyWith =>
      __$$ParticipantDtoImplCopyWithImpl<_$ParticipantDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantDtoImplToJson(
      this,
    );
  }
}

abstract class _ParticipantDto extends ParticipantDto {
  const factory _ParticipantDto(
      {required final int id,
      final String? nickName,
      final String? trueName,
      final String? mobile,
      final String? avatar,
      final String? type,
      final int? referId}) = _$ParticipantDtoImpl;
  const _ParticipantDto._() : super._();

  factory _ParticipantDto.fromJson(Map<String, dynamic> json) =
      _$ParticipantDtoImpl.fromJson;

  @override
  int get id;
  @override
  String? get nickName;
  @override
  String? get trueName;
  @override
  String? get mobile;
  @override
  String? get avatar;
  @override
  String? get type; // 'MEMBER', 'DOCTOR', 'ADMIN'
  @override
  int? get referId;

  /// Create a copy of ParticipantDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantDtoImplCopyWith<_$ParticipantDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
