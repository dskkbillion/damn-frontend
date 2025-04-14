import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../domain/entities/message.dart';

/// 连接状态枚举
enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
}

/// 心跳状态枚举
enum HeartbeatStatus {
  ok,       // Heartbeat successful
  failed,   // Heartbeat failed (e.g., no pong received)
  timeout,  // Connection might be stale
}

/// 抽象类：定义与聊天实时服务相关的操作
abstract class IChatRealtimeService {
  /// 连接到 WebSocket 服务器。
  /// 需要先获取 `commonUserId`。
  Future<Either<Failure, void>> connect(int commonUserId);

  /// 断开 WebSocket 连接。
  Future<Either<Failure, void>> disconnect();

  /// 监听传入的新消息。
  Stream<Message> get incomingMessages;

  /// 监听 WebSocket 连接状态。
  Stream<ConnectionStatus> get connectionStatus;

  /// 启动心跳机制。
  /// [interval]：心跳发送间隔。
  Future<Either<Failure, void>> startHeartbeat({Duration interval = const Duration(seconds: 20)});

  /// 停止心跳机制。
  Future<Either<Failure, void>> stopHeartbeat();

  /// 监听心跳状态。
  Stream<HeartbeatStatus> get heartbeatStatus;
} 