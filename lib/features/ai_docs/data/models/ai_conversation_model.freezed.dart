// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiConversationModel _$AiConversationModelFromJson(Map<String, dynamic> json) {
  return _AiConversationModel.fromJson(json);
}

/// @nodoc
mixin _$AiConversationModel {
  @JsonKey(name: 'conversation_id')
  int get conversationId => throw _privateConstructorUsedError;
  String? get title =>
      throw _privateConstructorUsedError; // Assumes JSON key is also 'title'
  @JsonKey(name: 'created_at')
  String? get createdAtString =>
      throw _privateConstructorUsedError; // Read as String first
  @JsonKey(name: 'updated_at')
  String? get updatedAtString =>
      throw _privateConstructorUsedError; // Read as String first
  @JsonKey(name: 'first_message')
  String? get firstMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_count')
  int? get messageCount => throw _privateConstructorUsedError;

  /// Serializes this AiConversationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiConversationModelCopyWith<AiConversationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiConversationModelCopyWith<$Res> {
  factory $AiConversationModelCopyWith(
          AiConversationModel value, $Res Function(AiConversationModel) then) =
      _$AiConversationModelCopyWithImpl<$Res, AiConversationModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'conversation_id') int conversationId,
      String? title,
      @JsonKey(name: 'created_at') String? createdAtString,
      @JsonKey(name: 'updated_at') String? updatedAtString,
      @JsonKey(name: 'first_message') String? firstMessage,
      @JsonKey(name: 'message_count') int? messageCount});
}

/// @nodoc
class _$AiConversationModelCopyWithImpl<$Res, $Val extends AiConversationModel>
    implements $AiConversationModelCopyWith<$Res> {
  _$AiConversationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? title = freezed,
    Object? createdAtString = freezed,
    Object? updatedAtString = freezed,
    Object? firstMessage = freezed,
    Object? messageCount = freezed,
  }) {
    return _then(_value.copyWith(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAtString: freezed == createdAtString
          ? _value.createdAtString
          : createdAtString // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAtString: freezed == updatedAtString
          ? _value.updatedAtString
          : updatedAtString // ignore: cast_nullable_to_non_nullable
              as String?,
      firstMessage: freezed == firstMessage
          ? _value.firstMessage
          : firstMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCount: freezed == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiConversationModelImplCopyWith<$Res>
    implements $AiConversationModelCopyWith<$Res> {
  factory _$$AiConversationModelImplCopyWith(_$AiConversationModelImpl value,
          $Res Function(_$AiConversationModelImpl) then) =
      __$$AiConversationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'conversation_id') int conversationId,
      String? title,
      @JsonKey(name: 'created_at') String? createdAtString,
      @JsonKey(name: 'updated_at') String? updatedAtString,
      @JsonKey(name: 'first_message') String? firstMessage,
      @JsonKey(name: 'message_count') int? messageCount});
}

/// @nodoc
class __$$AiConversationModelImplCopyWithImpl<$Res>
    extends _$AiConversationModelCopyWithImpl<$Res, _$AiConversationModelImpl>
    implements _$$AiConversationModelImplCopyWith<$Res> {
  __$$AiConversationModelImplCopyWithImpl(_$AiConversationModelImpl _value,
      $Res Function(_$AiConversationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? title = freezed,
    Object? createdAtString = freezed,
    Object? updatedAtString = freezed,
    Object? firstMessage = freezed,
    Object? messageCount = freezed,
  }) {
    return _then(_$AiConversationModelImpl(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAtString: freezed == createdAtString
          ? _value.createdAtString
          : createdAtString // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAtString: freezed == updatedAtString
          ? _value.updatedAtString
          : updatedAtString // ignore: cast_nullable_to_non_nullable
              as String?,
      firstMessage: freezed == firstMessage
          ? _value.firstMessage
          : firstMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCount: freezed == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiConversationModelImpl extends _AiConversationModel {
  const _$AiConversationModelImpl(
      {@JsonKey(name: 'conversation_id') required this.conversationId,
      this.title,
      @JsonKey(name: 'created_at') this.createdAtString,
      @JsonKey(name: 'updated_at') this.updatedAtString,
      @JsonKey(name: 'first_message') this.firstMessage,
      @JsonKey(name: 'message_count') this.messageCount})
      : super._();

  factory _$AiConversationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiConversationModelImplFromJson(json);

  @override
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  @override
  final String? title;
// Assumes JSON key is also 'title'
  @override
  @JsonKey(name: 'created_at')
  final String? createdAtString;
// Read as String first
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAtString;
// Read as String first
  @override
  @JsonKey(name: 'first_message')
  final String? firstMessage;
  @override
  @JsonKey(name: 'message_count')
  final int? messageCount;

  @override
  String toString() {
    return 'AiConversationModel(conversationId: $conversationId, title: $title, createdAtString: $createdAtString, updatedAtString: $updatedAtString, firstMessage: $firstMessage, messageCount: $messageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiConversationModelImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAtString, createdAtString) ||
                other.createdAtString == createdAtString) &&
            (identical(other.updatedAtString, updatedAtString) ||
                other.updatedAtString == updatedAtString) &&
            (identical(other.firstMessage, firstMessage) ||
                other.firstMessage == firstMessage) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, conversationId, title,
      createdAtString, updatedAtString, firstMessage, messageCount);

  /// Create a copy of AiConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiConversationModelImplCopyWith<_$AiConversationModelImpl> get copyWith =>
      __$$AiConversationModelImplCopyWithImpl<_$AiConversationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiConversationModelImplToJson(
      this,
    );
  }
}

abstract class _AiConversationModel extends AiConversationModel {
  const factory _AiConversationModel(
          {@JsonKey(name: 'conversation_id') required final int conversationId,
          final String? title,
          @JsonKey(name: 'created_at') final String? createdAtString,
          @JsonKey(name: 'updated_at') final String? updatedAtString,
          @JsonKey(name: 'first_message') final String? firstMessage,
          @JsonKey(name: 'message_count') final int? messageCount}) =
      _$AiConversationModelImpl;
  const _AiConversationModel._() : super._();

  factory _AiConversationModel.fromJson(Map<String, dynamic> json) =
      _$AiConversationModelImpl.fromJson;

  @override
  @JsonKey(name: 'conversation_id')
  int get conversationId;
  @override
  String? get title; // Assumes JSON key is also 'title'
  @override
  @JsonKey(name: 'created_at')
  String? get createdAtString; // Read as String first
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAtString; // Read as String first
  @override
  @JsonKey(name: 'first_message')
  String? get firstMessage;
  @override
  @JsonKey(name: 'message_count')
  int? get messageCount;

  /// Create a copy of AiConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiConversationModelImplCopyWith<_$AiConversationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
