/// 聊天模块通用常量，消除魔法数字。
abstract final class ChatConstants {
  /// 系统管理员的 referId
  static const adminReferId = 0;

  /// 通知中心的假聊天室 ID
  static const notificationCenterChatId = -2;

  /// 通知中心的假参与者 ID
  static const notificationCenterParticipantId = 2;

  /// 当前用户的假参与者 ID（用于构造假聊天室）
  static const currentUserFakeParticipantId = -1;

  /// 消息撤回时间限制
  static const revokeTimeLimit = Duration(minutes: 2);

  /// WebSocket 心跳间隔
  static const wsHeartbeatInterval = Duration(seconds: 30);

  /// WebSocket PONG 超时时间（发 ping 后等待 pong 的最大时长）
  static const wsPongTimeout = Duration(seconds: 10);

  /// WebSocket 重连延迟
  static const wsReconnectDelay = Duration(seconds: 5);

  /// WebSocket 最大重连次数
  static const wsMaxReconnectAttempts = 5;

  /// 默认分页大小
  static const defaultPageSize = 20;

  /// 乐观消息临时 ID 基数（生成范围: [base, base*2)）
  static const optimisticMessageIdBase = 1000000;
}
