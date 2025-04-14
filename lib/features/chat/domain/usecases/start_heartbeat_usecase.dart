import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 启动 WebSocket 心跳用例。
class StartHeartbeatUseCase {
  final IChatRealtimeService _realtimeService;

  StartHeartbeatUseCase(this._realtimeService);

  /// 调用此 UseCase 启动心跳。
  /// [params] 可以包含心跳间隔等参数。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call(StartHeartbeatParams params) {
    return _realtimeService.startHeartbeat(interval: params.interval);
  }
}

/// StartHeartbeatUseCase 的参数
class StartHeartbeatParams {
  final Duration interval;

  StartHeartbeatParams({this.interval = const Duration(seconds: 20)});
} 