import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 停止 WebSocket 心跳用例。
class StopHeartbeatUseCase {
  final IChatRealtimeService _realtimeService;

  StopHeartbeatUseCase(this._realtimeService);

  /// 调用此 UseCase 停止心跳。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call() {
    return _realtimeService.stopHeartbeat();
  }
} 