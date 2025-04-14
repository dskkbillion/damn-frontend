import '../entities/enums.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 监听 WebSocket 心跳状态用例。
class ObserveHeartbeatStatusUseCase {
  final IChatRealtimeService _realtimeService;

  ObserveHeartbeatStatusUseCase(this._realtimeService);

  /// 调用此 UseCase 开始监听心跳状态。
  /// 返回一个 Stream，持续发出当前的 `HeartbeatStatus`。
  Stream<HeartbeatStatus> call() {
    return _realtimeService.heartbeatStatus;
  }
} 