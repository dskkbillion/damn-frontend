// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiChatMessageModel _$AiChatMessageModelFromJson(Map<String, dynamic> json) {
  return _AiChatMessageModel.fromJson(json);
}

/// @nodoc
mixin _$AiChatMessageModel {
  int? get id =>
      throw _privateConstructorUsedError; // Optional database ID from API?
  @JsonKey(name: 'message_id')
  int get messageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'conversation_id')
  int get conversationId => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // API likely uses 'user' or 'assistant' strings
  String get content => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _filesFromJson)
  List<String> get files =>
      throw _privateConstructorUsedError; // List of OSS URLs
  int? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this AiChatMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatMessageModelCopyWith<AiChatMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatMessageModelCopyWith<$Res> {
  factory $AiChatMessageModelCopyWith(
          AiChatMessageModel value, $Res Function(AiChatMessageModel) then) =
      _$AiChatMessageModelCopyWithImpl<$Res, AiChatMessageModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'message_id') int messageId,
      @JsonKey(name: 'conversation_id') int conversationId,
      String role,
      String content,
      @JsonKey(fromJson: _filesFromJson) List<String> files,
      int? timestamp});
}

/// @nodoc
class _$AiChatMessageModelCopyWithImpl<$Res, $Val extends AiChatMessageModel>
    implements $AiChatMessageModelCopyWith<$Res> {
  _$AiChatMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? messageId = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? files = null,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      files: null == files
          ? _value.files
          : files // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatMessageModelImplCopyWith<$Res>
    implements $AiChatMessageModelCopyWith<$Res> {
  factory _$$AiChatMessageModelImplCopyWith(_$AiChatMessageModelImpl value,
          $Res Function(_$AiChatMessageModelImpl) then) =
      __$$AiChatMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'message_id') int messageId,
      @JsonKey(name: 'conversation_id') int conversationId,
      String role,
      String content,
      @JsonKey(fromJson: _filesFromJson) List<String> files,
      int? timestamp});
}

/// @nodoc
class __$$AiChatMessageModelImplCopyWithImpl<$Res>
    extends _$AiChatMessageModelCopyWithImpl<$Res, _$AiChatMessageModelImpl>
    implements _$$AiChatMessageModelImplCopyWith<$Res> {
  __$$AiChatMessageModelImplCopyWithImpl(_$AiChatMessageModelImpl _value,
      $Res Function(_$AiChatMessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? messageId = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? files = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$AiChatMessageModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      files: null == files
          ? _value._files
          : files // ignore: cast_nullable_to_non_nullable
              as List<String>,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiChatMessageModelImpl extends _AiChatMessageModel {
  const _$AiChatMessageModelImpl(
      {this.id,
      @JsonKey(name: 'message_id') required this.messageId,
      @JsonKey(name: 'conversation_id') required this.conversationId,
      required this.role,
      required this.content,
      @JsonKey(fromJson: _filesFromJson) final List<String> files = const [],
      this.timestamp})
      : _files = files,
        super._();

  factory _$AiChatMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatMessageModelImplFromJson(json);

  @override
  final int? id;
// Optional database ID from API?
  @override
  @JsonKey(name: 'message_id')
  final int messageId;
  @override
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  @override
  final String role;
// API likely uses 'user' or 'assistant' strings
  @override
  final String content;
  final List<String> _files;
  @override
  @JsonKey(fromJson: _filesFromJson)
  List<String> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

// List of OSS URLs
  @override
  final int? timestamp;

  @override
  String toString() {
    return 'AiChatMessageModel(id: $id, messageId: $messageId, conversationId: $conversationId, role: $role, content: $content, files: $files, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, messageId, conversationId,
      role, content, const DeepCollectionEquality().hash(_files), timestamp);

  /// Create a copy of AiChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatMessageModelImplCopyWith<_$AiChatMessageModelImpl> get copyWith =>
      __$$AiChatMessageModelImplCopyWithImpl<_$AiChatMessageModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatMessageModelImplToJson(
      this,
    );
  }
}

abstract class _AiChatMessageModel extends AiChatMessageModel {
  const factory _AiChatMessageModel(
      {final int? id,
      @JsonKey(name: 'message_id') required final int messageId,
      @JsonKey(name: 'conversation_id') required final int conversationId,
      required final String role,
      required final String content,
      @JsonKey(fromJson: _filesFromJson) final List<String> files,
      final int? timestamp}) = _$AiChatMessageModelImpl;
  const _AiChatMessageModel._() : super._();

  factory _AiChatMessageModel.fromJson(Map<String, dynamic> json) =
      _$AiChatMessageModelImpl.fromJson;

  @override
  int? get id; // Optional database ID from API?
  @override
  @JsonKey(name: 'message_id')
  int get messageId;
  @override
  @JsonKey(name: 'conversation_id')
  int get conversationId;
  @override
  String get role; // API likely uses 'user' or 'assistant' strings
  @override
  String get content;
  @override
  @JsonKey(fromJson: _filesFromJson)
  List<String> get files; // List of OSS URLs
  @override
  int? get timestamp;

  /// Create a copy of AiChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatMessageModelImplCopyWith<_$AiChatMessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
