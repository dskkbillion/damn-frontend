part of 'message_queue_cubit.dart';

@freezed
class MessageQueueState with _$MessageQueueState {
  const factory MessageQueueState.idle({
    @Default([]) List<MessageQueueItem> queueItems,
    @Default(0) int queueSize,
  }) = _Idle;
  
  const factory MessageQueueState.processing({
    @Default(0) int currentItem,
    @Default(0) int totalItems,
  }) = _Processing;
  
  const factory MessageQueueState.paused() = _Paused;
  
  const factory MessageQueueState.itemSent({
    required int remainingItems,
  }) = _ItemSent;
  
  const factory MessageQueueState.error(String message) = _Error;
}