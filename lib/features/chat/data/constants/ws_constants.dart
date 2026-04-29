/// WebSocket 消息 action 类型常量。
abstract final class WsAction {
  static const chat = 'CHAT';
  static const pong = 'PONG';
  static const loginSuccess = 'LOGIN_SUCCESS';
  static const loginFail = 'LOGIN_FAIL';
  static const chatWithdraw = 'CHAT_WITHDRAW';
  static const notification = 'NOTIFICATION';
}

/// WebSocket 发送消息的 type 字段常量。
abstract final class WsMessageType {
  static const auth = 'auth';
  static const ping = 'ping';
}

/// WebSocket 连接相关常量。
abstract final class WsConstants {
  /// WebSocket URL 中的角色路径段（小写）。
  /// 与 ParticipantType.member ('MEMBER') 语义相关但大小写不同，
  /// 独立定义避免运行时 toLowerCase() 的脆弱依赖。
  static const rolePath = 'member';
}
