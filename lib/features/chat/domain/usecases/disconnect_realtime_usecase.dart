import 'package:dartz/dartz.dart';

import '../entities/failure.dart';
import '../repositories/i_chat_realtime_service.dart';

/// 断开实时聊天服务连接用例。
class DisconnectRealtimeUseCase {
  final IChatRealtimeService _realtimeService;

  DisconnectRealtimeUseCase(this._realtimeService);

  /// 调用此 UseCase 断开实时服务连接。
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, void>> call() {
    return _realtimeService.disconnect();
  }
} 