part of 'message_list_cubit.dart';

@freezed
class MessageListState with _$MessageListState {
  const factory MessageListState.initial() = _Initial;
  
  const factory MessageListState.loading() = _Loading;
  
  const factory MessageListState.loaded({
    required List<ChatMessage> messages,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
    String? loadMoreError,
    String? sendError,
    String? actionError,
  }) = _Loaded;
  
  const factory MessageListState.error(String message) = _Error;
}