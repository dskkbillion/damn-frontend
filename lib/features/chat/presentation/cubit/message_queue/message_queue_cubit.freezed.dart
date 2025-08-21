// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_queue_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessageQueueState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageQueueStateCopyWith<$Res> {
  factory $MessageQueueStateCopyWith(
          MessageQueueState value, $Res Function(MessageQueueState) then) =
      _$MessageQueueStateCopyWithImpl<$Res, MessageQueueState>;
}

/// @nodoc
class _$MessageQueueStateCopyWithImpl<$Res, $Val extends MessageQueueState>
    implements $MessageQueueStateCopyWith<$Res> {
  _$MessageQueueStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
          _$IdleImpl value, $Res Function(_$IdleImpl) then) =
      __$$IdleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<MessageQueueItem> queueItems, int queueSize});
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$MessageQueueStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queueItems = null,
    Object? queueSize = null,
  }) {
    return _then(_$IdleImpl(
      queueItems: null == queueItems
          ? _value._queueItems
          : queueItems // ignore: cast_nullable_to_non_nullable
              as List<MessageQueueItem>,
      queueSize: null == queueSize
          ? _value.queueSize
          : queueSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl(
      {final List<MessageQueueItem> queueItems = const [], this.queueSize = 0})
      : _queueItems = queueItems;

  final List<MessageQueueItem> _queueItems;
  @override
  @JsonKey()
  List<MessageQueueItem> get queueItems {
    if (_queueItems is EqualUnmodifiableListView) return _queueItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queueItems);
  }

  @override
  @JsonKey()
  final int queueSize;

  @override
  String toString() {
    return 'MessageQueueState.idle(queueItems: $queueItems, queueSize: $queueSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdleImpl &&
            const DeepCollectionEquality()
                .equals(other._queueItems, _queueItems) &&
            (identical(other.queueSize, queueSize) ||
                other.queueSize == queueSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_queueItems), queueSize);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdleImplCopyWith<_$IdleImpl> get copyWith =>
      __$$IdleImplCopyWithImpl<_$IdleImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) {
    return idle(queueItems, queueSize);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) {
    return idle?.call(queueItems, queueSize);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(queueItems, queueSize);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements MessageQueueState {
  const factory _Idle(
      {final List<MessageQueueItem> queueItems,
      final int queueSize}) = _$IdleImpl;

  List<MessageQueueItem> get queueItems;
  int get queueSize;

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdleImplCopyWith<_$IdleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
          _$ProcessingImpl value, $Res Function(_$ProcessingImpl) then) =
      __$$ProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int currentItem, int totalItems});
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$MessageQueueStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
      _$ProcessingImpl _value, $Res Function(_$ProcessingImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentItem = null,
    Object? totalItems = null,
  }) {
    return _then(_$ProcessingImpl(
      currentItem: null == currentItem
          ? _value.currentItem
          : currentItem // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl({this.currentItem = 0, this.totalItems = 0});

  @override
  @JsonKey()
  final int currentItem;
  @override
  @JsonKey()
  final int totalItems;

  @override
  String toString() {
    return 'MessageQueueState.processing(currentItem: $currentItem, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingImpl &&
            (identical(other.currentItem, currentItem) ||
                other.currentItem == currentItem) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentItem, totalItems);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      __$$ProcessingImplCopyWithImpl<_$ProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) {
    return processing(currentItem, totalItems);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) {
    return processing?.call(currentItem, totalItems);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(currentItem, totalItems);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements MessageQueueState {
  const factory _Processing({final int currentItem, final int totalItems}) =
      _$ProcessingImpl;

  int get currentItem;
  int get totalItems;

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PausedImplCopyWith<$Res> {
  factory _$$PausedImplCopyWith(
          _$PausedImpl value, $Res Function(_$PausedImpl) then) =
      __$$PausedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PausedImplCopyWithImpl<$Res>
    extends _$MessageQueueStateCopyWithImpl<$Res, _$PausedImpl>
    implements _$$PausedImplCopyWith<$Res> {
  __$$PausedImplCopyWithImpl(
      _$PausedImpl _value, $Res Function(_$PausedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PausedImpl implements _Paused {
  const _$PausedImpl();

  @override
  String toString() {
    return 'MessageQueueState.paused()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PausedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) {
    return paused();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) {
    return paused?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) {
    return paused(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) {
    return paused?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (paused != null) {
      return paused(this);
    }
    return orElse();
  }
}

abstract class _Paused implements MessageQueueState {
  const factory _Paused() = _$PausedImpl;
}

/// @nodoc
abstract class _$$ItemSentImplCopyWith<$Res> {
  factory _$$ItemSentImplCopyWith(
          _$ItemSentImpl value, $Res Function(_$ItemSentImpl) then) =
      __$$ItemSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int remainingItems});
}

/// @nodoc
class __$$ItemSentImplCopyWithImpl<$Res>
    extends _$MessageQueueStateCopyWithImpl<$Res, _$ItemSentImpl>
    implements _$$ItemSentImplCopyWith<$Res> {
  __$$ItemSentImplCopyWithImpl(
      _$ItemSentImpl _value, $Res Function(_$ItemSentImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingItems = null,
  }) {
    return _then(_$ItemSentImpl(
      remainingItems: null == remainingItems
          ? _value.remainingItems
          : remainingItems // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ItemSentImpl implements _ItemSent {
  const _$ItemSentImpl({required this.remainingItems});

  @override
  final int remainingItems;

  @override
  String toString() {
    return 'MessageQueueState.itemSent(remainingItems: $remainingItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemSentImpl &&
            (identical(other.remainingItems, remainingItems) ||
                other.remainingItems == remainingItems));
  }

  @override
  int get hashCode => Object.hash(runtimeType, remainingItems);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemSentImplCopyWith<_$ItemSentImpl> get copyWith =>
      __$$ItemSentImplCopyWithImpl<_$ItemSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) {
    return itemSent(remainingItems);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) {
    return itemSent?.call(remainingItems);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (itemSent != null) {
      return itemSent(remainingItems);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) {
    return itemSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) {
    return itemSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (itemSent != null) {
      return itemSent(this);
    }
    return orElse();
  }
}

abstract class _ItemSent implements MessageQueueState {
  const factory _ItemSent({required final int remainingItems}) = _$ItemSentImpl;

  int get remainingItems;

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemSentImplCopyWith<_$ItemSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$MessageQueueStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'MessageQueueState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<MessageQueueItem> queueItems, int queueSize)
        idle,
    required TResult Function(int currentItem, int totalItems) processing,
    required TResult Function() paused,
    required TResult Function(int remainingItems) itemSent,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult? Function(int currentItem, int totalItems)? processing,
    TResult? Function()? paused,
    TResult? Function(int remainingItems)? itemSent,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<MessageQueueItem> queueItems, int queueSize)? idle,
    TResult Function(int currentItem, int totalItems)? processing,
    TResult Function()? paused,
    TResult Function(int remainingItems)? itemSent,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Paused value) paused,
    required TResult Function(_ItemSent value) itemSent,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Paused value)? paused,
    TResult? Function(_ItemSent value)? itemSent,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Processing value)? processing,
    TResult Function(_Paused value)? paused,
    TResult Function(_ItemSent value)? itemSent,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements MessageQueueState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of MessageQueueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
