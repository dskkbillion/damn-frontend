import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 连接到实时聊天服务用例。
class ConnectRealtimeUseCase {
  final IChatRealtimeService _realtimeService;

  ConnectRealtimeUseCase(this._realtimeService);

  /// 调用此 UseCase 连接到实时服务。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call() {
    return _realtimeService.connect();
  }
} 