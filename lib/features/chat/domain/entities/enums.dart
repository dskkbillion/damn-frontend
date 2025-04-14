import 'package:equatable/equatable.dart';

/// 消息类型枚举
enum MessageType {
  /// 文本消息
  text,

  /// 图片消息
  image,

  /// 音频消息
  audio,

  /// 未知或不支持的消息类型
  unknown,
}

/// 消息发送状态枚举 (本地维护)
enum MessageSendStatus {
  /// 正在发送中
  sending,

  /// 已发送成功
  sent,

  /// 发送失败
  failed,

  /// 无状态 (例如接收到的消息)
  none,
}

/// WebSocket 连接状态枚举
enum ConnectionStatus {
  /// 已连接
  connected,

  /// 已断开连接
  disconnected,

  /// 正在连接中
  connecting,

  /// 连接错误
  error,
}

/// WebSocket 心跳状态枚举
enum HeartbeatStatus {
  /// 心跳正常
  ok,

  /// 心跳失败
  failed,

  /// 心跳超时
  timeout,
} 