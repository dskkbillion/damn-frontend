import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/failure.dart';
import '../entities/message.dart';

/// 聊天实时服务接口 (WebSocket)
abstract class IChatRealtimeService {
  /// 连接到实时消息服务器。
  ///
  /// 需要先获取用户的 `commonUserId` 来构建连接 URL。
  /// 连接成功后应自动进行身份验证和心跳启动。
  /// 返回 `Failure` 如果连接或认证失败。
  Future<Either<Failure, void>> connect();

  /// 断开与实时消息服务器的连接。
  ///
  /// 返回 `Failure` 如果断开过程中发生错误。
  Future<Either<Failure, void>> disconnect();

  /// 监听接收到的新消息。
  ///
  /// 当服务器通过 WebSocket 推送新消息时，此流会发出 `Message` 对象。
  /// 如果在接收过程中发生错误（如解析失败），流可能会发出错误。
  Stream<Message> get incomingMessages;

  /// 监听 WebSocket 的连接状态。
  ///
  /// 流会发出 `ConnectionStatus` 枚举值，指示当前连接状态。
  Stream<ConnectionStatus> get connectionStatus;

  /// 启动心跳机制。
  ///
  /// [interval] 指定发送心跳包的时间间隔，默认为 20 秒。
  /// 启动后，服务会按指定间隔自动发送心跳包以保持连接活跃。
  /// 返回 `Failure` 如果启动失败。
  Future<Either<Failure, void>> startHeartbeat({Duration interval = const Duration(seconds: 20)});

  /// 停止心跳机制。
  ///
  /// 返回 `Failure` 如果停止过程中发生错误。
  Future<Either<Failure, void>> stopHeartbeat();

  /// 监听心跳状态。
  ///
  /// 流会发出 `HeartbeatStatus` 枚举值，指示心跳的健康状况。
  /// 例如，如果心跳连续失败或超时，可以发出 `HeartbeatStatus.failed` 或 `HeartbeatStatus.timeout`。
  Stream<HeartbeatStatus> get heartbeatStatus;
} 