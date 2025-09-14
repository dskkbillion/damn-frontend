// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) {
  return _ChatMessageDto.fromJson(json);
}

/// @nodoc
mixin _$ChatMessageDto {
  int? get id =>
      throw _privateConstructorUsedError; // Make id optional for WebSocket messages
  int get chatId => throw _privateConstructorUsedError;
  int? get doctorId => throw _privateConstructorUsedError;
  int? get memberId => throw _privateConstructorUsedError;
  String get context => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get createTime =>
      throw _privateConstructorUsedError; // API might return string
  bool get withdrawFlag => throw _privateConstructorUsedError;
  bool? get readFlg => throw _privateConstructorUsedError;

  /// Serializes this ChatMessageDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageDtoCopyWith<ChatMessageDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageDtoCopyWith<$Res> {
  factory $ChatMessageDtoCopyWith(
          ChatMessageDto value, $Res Function(ChatMessageDto) then) =
      _$ChatMessageDtoCopyWithImpl<$Res, ChatMessageDto>;
  @useResult
  $Res call(
      {int? id,
      int chatId,
      int? doctorId,
      int? memberId,
      String context,
      String type,
      String? createTime,
      bool withdrawFlag,
      bool? readFlg});
}

/// @nodoc
class _$ChatMessageDtoCopyWithImpl<$Res, $Val extends ChatMessageDto>
    implements $ChatMessageDtoCopyWith<$Res> {
  _$ChatMessageDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = null,
    Object? doctorId = freezed,
    Object? memberId = freezed,
    Object? context = null,
    Object? type = null,
    Object? createTime = freezed,
    Object? withdrawFlag = null,
    Object? readFlg = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as int,
      doctorId: freezed == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as int?,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createTime: freezed == createTime
          ? _value.createTime
          : createTime // ignore: cast_nullable_to_non_nullable
              as String?,
      withdrawFlag: null == withdrawFlag
          ? _value.withdrawFlag
          : withdrawFlag // ignore: cast_nullable_to_non_nullable
              as bool,
      readFlg: freezed == readFlg
          ? _value.readFlg
          : readFlg // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageDtoImplCopyWith<$Res>
    implements $ChatMessageDtoCopyWith<$Res> {
  factory _$$ChatMessageDtoImplCopyWith(_$ChatMessageDtoImpl value,
          $Res Function(_$ChatMessageDtoImpl) then) =
      __$$ChatMessageDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int chatId,
      int? doctorId,
      int? memberId,
      String context,
      String type,
      String? createTime,
      bool withdrawFlag,
      bool? readFlg});
}

/// @nodoc
class __$$ChatMessageDtoImplCopyWithImpl<$Res>
    extends _$ChatMessageDtoCopyWithImpl<$Res, _$ChatMessageDtoImpl>
    implements _$$ChatMessageDtoImplCopyWith<$Res> {
  __$$ChatMessageDtoImplCopyWithImpl(
      _$ChatMessageDtoImpl _value, $Res Function(_$ChatMessageDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = null,
    Object? doctorId = freezed,
    Object? memberId = freezed,
    Object? context = null,
    Object? type = null,
    Object? createTime = freezed,
    Object? withdrawFlag = null,
    Object? readFlg = freezed,
  }) {
    return _then(_$ChatMessageDtoImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as int,
      doctorId: freezed == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as int?,
      memberId: freezed == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int?,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createTime: freezed == createTime
          ? _value.createTime
          : createTime // ignore: cast_nullable_to_non_nullable
              as String?,
      withdrawFlag: null == withdrawFlag
          ? _value.withdrawFlag
          : withdrawFlag // ignore: cast_nullable_to_non_nullable
              as bool,
      readFlg: freezed == readFlg
          ? _value.readFlg
          : readFlg // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageDtoImpl extends _ChatMessageDto {
  const _$ChatMessageDtoImpl(
      {this.id,
      required this.chatId,
      this.doctorId,
      this.memberId,
      required this.context,
      required this.type,
      this.createTime,
      this.withdrawFlag = false,
      this.readFlg})
      : super._();

  factory _$ChatMessageDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageDtoImplFromJson(json);

  @override
  final int? id;
// Make id optional for WebSocket messages
  @override
  final int chatId;
  @override
  final int? doctorId;
  @override
  final int? memberId;
  @override
  final String context;
  @override
  final String type;
  @override
  final String? createTime;
// API might return string
  @override
  @JsonKey()
  final bool withdrawFlag;
  @override
  final bool? readFlg;

  @override
  String toString() {
    return 'ChatMessageDto(id: $id, chatId: $chatId, doctorId: $doctorId, memberId: $memberId, context: $context, type: $type, createTime: $createTime, withdrawFlag: $withdrawFlag, readFlg: $readFlg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createTime, createTime) ||
                other.createTime == createTime) &&
            (identical(other.withdrawFlag, withdrawFlag) ||
                other.withdrawFlag == withdrawFlag) &&
            (identical(other.readFlg, readFlg) || other.readFlg == readFlg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, chatId, doctorId, memberId,
      context, type, createTime, withdrawFlag, readFlg);

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageDtoImplCopyWith<_$ChatMessageDtoImpl> get copyWith =>
      __$$ChatMessageDtoImplCopyWithImpl<_$ChatMessageDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageDtoImplToJson(
      this,
    );
  }
}

abstract class _ChatMessageDto extends ChatMessageDto {
  const factory _ChatMessageDto(
      {final int? id,
      required final int chatId,
      final int? doctorId,
      final int? memberId,
      required final String context,
      required final String type,
      final String? createTime,
      final bool withdrawFlag,
      final bool? readFlg}) = _$ChatMessageDtoImpl;
  const _ChatMessageDto._() : super._();

  factory _ChatMessageDto.fromJson(Map<String, dynamic> json) =
      _$ChatMessageDtoImpl.fromJson;

  @override
  int? get id; // Make id optional for WebSocket messages
  @override
  int get chatId;
  @override
  int? get doctorId;
  @override
  int? get memberId;
  @override
  String get context;
  @override
  String get type;
  @override
  String? get createTime; // API might return string
  @override
  bool get withdrawFlag;
  @override
  bool? get readFlg;

  /// Create a copy of ChatMessageDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageDtoImplCopyWith<_$ChatMessageDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
