// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatRoomDto _$ChatRoomDtoFromJson(Map<String, dynamic> json) {
  return _ChatRoomDto.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomDto {
  int get id => throw _privateConstructorUsedError;
  ParticipantDto get member => throw _privateConstructorUsedError;
  ParticipantDto get doctor => throw _privateConstructorUsedError;
  int get messageNum => throw _privateConstructorUsedError; // Unread count
  ChatMessageDto? get chatMessageNewVo =>
      throw _privateConstructorUsedError; // Latest message DTO
// 新增商品相关字段
  int? get productId => throw _privateConstructorUsedError;
  ProductVoDto? get productVo => throw _privateConstructorUsedError;

  /// Serializes this ChatRoomDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomDtoCopyWith<ChatRoomDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomDtoCopyWith<$Res> {
  factory $ChatRoomDtoCopyWith(
          ChatRoomDto value, $Res Function(ChatRoomDto) then) =
      _$ChatRoomDtoCopyWithImpl<$Res, ChatRoomDto>;
  @useResult
  $Res call(
      {int id,
      ParticipantDto member,
      ParticipantDto doctor,
      int messageNum,
      ChatMessageDto? chatMessageNewVo,
      int? productId,
      ProductVoDto? productVo});

  $ParticipantDtoCopyWith<$Res> get member;
  $ParticipantDtoCopyWith<$Res> get doctor;
  $ChatMessageDtoCopyWith<$Res>? get chatMessageNewVo;
  $ProductVoDtoCopyWith<$Res>? get productVo;
}

/// @nodoc
class _$ChatRoomDtoCopyWithImpl<$Res, $Val extends ChatRoomDto>
    implements $ChatRoomDtoCopyWith<$Res> {
  _$ChatRoomDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? member = null,
    Object? doctor = null,
    Object? messageNum = null,
    Object? chatMessageNewVo = freezed,
    Object? productId = freezed,
    Object? productVo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      member: null == member
          ? _value.member
          : member // ignore: cast_nullable_to_non_nullable
              as ParticipantDto,
      doctor: null == doctor
          ? _value.doctor
          : doctor // ignore: cast_nullable_to_non_nullable
              as ParticipantDto,
      messageNum: null == messageNum
          ? _value.messageNum
          : messageNum // ignore: cast_nullable_to_non_nullable
              as int,
      chatMessageNewVo: freezed == chatMessageNewVo
          ? _value.chatMessageNewVo
          : chatMessageNewVo // ignore: cast_nullable_to_non_nullable
              as ChatMessageDto?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int?,
      productVo: freezed == productVo
          ? _value.productVo
          : productVo // ignore: cast_nullable_to_non_nullable
              as ProductVoDto?,
    ) as $Val);
  }

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParticipantDtoCopyWith<$Res> get member {
    return $ParticipantDtoCopyWith<$Res>(_value.member, (value) {
      return _then(_value.copyWith(member: value) as $Val);
    });
  }

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParticipantDtoCopyWith<$Res> get doctor {
    return $ParticipantDtoCopyWith<$Res>(_value.doctor, (value) {
      return _then(_value.copyWith(doctor: value) as $Val);
    });
  }

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatMessageDtoCopyWith<$Res>? get chatMessageNewVo {
    if (_value.chatMessageNewVo == null) {
      return null;
    }

    return $ChatMessageDtoCopyWith<$Res>(_value.chatMessageNewVo!, (value) {
      return _then(_value.copyWith(chatMessageNewVo: value) as $Val);
    });
  }

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductVoDtoCopyWith<$Res>? get productVo {
    if (_value.productVo == null) {
      return null;
    }

    return $ProductVoDtoCopyWith<$Res>(_value.productVo!, (value) {
      return _then(_value.copyWith(productVo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomDtoImplCopyWith<$Res>
    implements $ChatRoomDtoCopyWith<$Res> {
  factory _$$ChatRoomDtoImplCopyWith(
          _$ChatRoomDtoImpl value, $Res Function(_$ChatRoomDtoImpl) then) =
      __$$ChatRoomDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      ParticipantDto member,
      ParticipantDto doctor,
      int messageNum,
      ChatMessageDto? chatMessageNewVo,
      int? productId,
      ProductVoDto? productVo});

  @override
  $ParticipantDtoCopyWith<$Res> get member;
  @override
  $ParticipantDtoCopyWith<$Res> get doctor;
  @override
  $ChatMessageDtoCopyWith<$Res>? get chatMessageNewVo;
  @override
  $ProductVoDtoCopyWith<$Res>? get productVo;
}

/// @nodoc
class __$$ChatRoomDtoImplCopyWithImpl<$Res>
    extends _$ChatRoomDtoCopyWithImpl<$Res, _$ChatRoomDtoImpl>
    implements _$$ChatRoomDtoImplCopyWith<$Res> {
  __$$ChatRoomDtoImplCopyWithImpl(
      _$ChatRoomDtoImpl _value, $Res Function(_$ChatRoomDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? member = null,
    Object? doctor = null,
    Object? messageNum = null,
    Object? chatMessageNewVo = freezed,
    Object? productId = freezed,
    Object? productVo = freezed,
  }) {
    return _then(_$ChatRoomDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      member: null == member
          ? _value.member
          : member // ignore: cast_nullable_to_non_nullable
              as ParticipantDto,
      doctor: null == doctor
          ? _value.doctor
          : doctor // ignore: cast_nullable_to_non_nullable
              as ParticipantDto,
      messageNum: null == messageNum
          ? _value.messageNum
          : messageNum // ignore: cast_nullable_to_non_nullable
              as int,
      chatMessageNewVo: freezed == chatMessageNewVo
          ? _value.chatMessageNewVo
          : chatMessageNewVo // ignore: cast_nullable_to_non_nullable
              as ChatMessageDto?,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int?,
      productVo: freezed == productVo
          ? _value.productVo
          : productVo // ignore: cast_nullable_to_non_nullable
              as ProductVoDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomDtoImpl extends _ChatRoomDto {
  const _$ChatRoomDtoImpl(
      {required this.id,
      required this.member,
      required this.doctor,
      this.messageNum = 0,
      this.chatMessageNewVo,
      this.productId,
      this.productVo})
      : super._();

  factory _$ChatRoomDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomDtoImplFromJson(json);

  @override
  final int id;
  @override
  final ParticipantDto member;
  @override
  final ParticipantDto doctor;
  @override
  @JsonKey()
  final int messageNum;
// Unread count
  @override
  final ChatMessageDto? chatMessageNewVo;
// Latest message DTO
// 新增商品相关字段
  @override
  final int? productId;
  @override
  final ProductVoDto? productVo;

  @override
  String toString() {
    return 'ChatRoomDto(id: $id, member: $member, doctor: $doctor, messageNum: $messageNum, chatMessageNewVo: $chatMessageNewVo, productId: $productId, productVo: $productVo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.member, member) || other.member == member) &&
            (identical(other.doctor, doctor) || other.doctor == doctor) &&
            (identical(other.messageNum, messageNum) ||
                other.messageNum == messageNum) &&
            (identical(other.chatMessageNewVo, chatMessageNewVo) ||
                other.chatMessageNewVo == chatMessageNewVo) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productVo, productVo) ||
                other.productVo == productVo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, member, doctor, messageNum,
      chatMessageNewVo, productId, productVo);

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomDtoImplCopyWith<_$ChatRoomDtoImpl> get copyWith =>
      __$$ChatRoomDtoImplCopyWithImpl<_$ChatRoomDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomDtoImplToJson(
      this,
    );
  }
}

abstract class _ChatRoomDto extends ChatRoomDto {
  const factory _ChatRoomDto(
      {required final int id,
      required final ParticipantDto member,
      required final ParticipantDto doctor,
      final int messageNum,
      final ChatMessageDto? chatMessageNewVo,
      final int? productId,
      final ProductVoDto? productVo}) = _$ChatRoomDtoImpl;
  const _ChatRoomDto._() : super._();

  factory _ChatRoomDto.fromJson(Map<String, dynamic> json) =
      _$ChatRoomDtoImpl.fromJson;

  @override
  int get id;
  @override
  ParticipantDto get member;
  @override
  ParticipantDto get doctor;
  @override
  int get messageNum; // Unread count
  @override
  ChatMessageDto? get chatMessageNewVo; // Latest message DTO
// 新增商品相关字段
  @override
  int? get productId;
  @override
  ProductVoDto? get productVo;

  /// Create a copy of ChatRoomDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomDtoImplCopyWith<_$ChatRoomDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
