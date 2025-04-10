import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/repositories.dart';

/// 连接状态
enum ConnectionState {
  /// 已连接
  CONNECTED,
  /// 连接中
  CONNECTING,
  /// 已断开
  DISCONNECTED,
  /// 连接错误
  ERROR,
}

/// 实时连接管理用例
class ManageRealtimeConnectionUseCase {
  final IChatRealtimeService _realtimeService;

  ManageRealtimeConnectionUseCase(this._realtimeService);

  /// 连接到实时消息服务
  /// 
  /// [token] 用户令牌
  /// 返回成功或失败
  Future<Either<Failure, void>> connect(String token) async {
    try {
      await _realtimeService.connect(token);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '连接实时服务失败: ${e.toString()}'));
    }
  }

  /// 断开实时消息服务连接
  /// 返回成功或失败
  Future<Either<Failure, void>> disconnect() async {
    try {
      await _realtimeService.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '断开连接失败: ${e.toString()}'));
    }
  }

  /// 重新连接实时消息服务
  /// 返回成功或失败
  Future<Either<Failure, void>> reconnect() async {
    try {
      await _realtimeService.reconnect();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '重新连接失败: ${e.toString()}'));
    }
  }

  /// 启动心跳保活
  /// 
  /// [interval] 心跳间隔时间，默认为20秒
  /// 返回成功或失败
  Future<Either<Failure, void>> startHeartbeat({Duration interval = const Duration(seconds: 20)}) async {
    try {
      await _realtimeService.startHeartbeat(interval);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '启动心跳保活失败: ${e.toString()}'));
    }
  }

  /// 停止心跳保活
  /// 返回成功或失败
  Future<Either<Failure, void>> stopHeartbeat() async {
    try {
      await _realtimeService.stopHeartbeat();
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '停止心跳保活失败: ${e.toString()}'));
    }
  }

  /// 获取连接状态流
  Stream<ConnectionState> getConnectionState() {
    return _realtimeService.connectionStatus.map((status) {
      switch (status) {
        case 'connected':
          return ConnectionState.CONNECTED;
        case 'connecting':
          return ConnectionState.CONNECTING;
        case 'disconnected':
          return ConnectionState.DISCONNECTED;
        case 'error':
          return ConnectionState.ERROR;
        default:
          return ConnectionState.DISCONNECTED;
      }
    });
  }

  /// 发送确认消息接收
  /// 
  /// [messageId] 消息ID
  /// 返回成功或失败
  Future<Either<Failure, void>> acknowledgeMessage(String messageId) async {
    try {
      await _realtimeService.acknowledgeMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure(message: '确认消息接收失败: ${e.toString()}'));
    }
  }
} 