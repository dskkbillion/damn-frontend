import '../entities/enums.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 监听实时服务连接状态用例。
class ObserveConnectionStatusUseCase {
  final IChatRealtimeService _realtimeService;

  ObserveConnectionStatusUseCase(this._realtimeService);

  /// 调用此 UseCase 开始监听连接状态。
  /// 返回一个 Stream，持续发出当前的 `ConnectionStatus`。
  Stream<ConnectionStatus> call() {
    return _realtimeService.connectionStatus;
  }
} 