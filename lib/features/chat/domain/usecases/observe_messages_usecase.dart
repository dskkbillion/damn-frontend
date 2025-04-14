import 'dart:async';
import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../entities/message.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 监听指定会话的新消息流 (通过 WebSocket)。
/// 注意：此 UseCase 只监听实时服务推送的新消息，不负责获取历史消息。
class ObserveMessagesUseCase {
  final IChatRealtimeService _realtimeService;

  ObserveMessagesUseCase(this._realtimeService);

  /// 调用此 UseCase。
  /// [params] 包含需要监听的 `chatId`。
  /// 返回一个 Stream，该流会发出属于指定 `chatId` 的新消息 `Message`。
  /// 如果实时服务连接断开或发生错误，流可能会结束或发出错误。
  Stream<Message> call(ObserveMessagesParams params) {
    // 过滤实时服务的所有 incomingMessages，只保留属于目标 chatId 的消息
    return _realtimeService.incomingMessages
        .where((message) => message.chatId == params.chatId);
  }
}

/// ObserveMessagesUseCase 的参数
class ObserveMessagesParams {
  final int chatId;

  ObserveMessagesParams({required this.chatId});
} 