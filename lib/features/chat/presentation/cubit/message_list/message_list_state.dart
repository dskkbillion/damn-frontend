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
    // 轻咨询模式相关字段
    @Default(0) int substantiveMessageCount,  // 实质性消息计数
    @Default(false) bool isPaid,  // 是否已付费
    @Default(false) bool hasShownPaymentDialog,  // 是否已显示过付费弹窗
    String? userRole,  // 用户角色 (MEMBER/DOCTOR)
    String? productId,  // 关联商品ID
  }) = _Loaded;
  
  const factory MessageListState.error(String message) = _Error;
}