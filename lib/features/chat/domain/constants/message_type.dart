/// 聊天消息类型常量，对应后端消息 type 字段值。
abstract final class ChatMessageType {
  static const text = 'text';
  static const image = 'image';
  static const audio = 'audio';
  static const revoke = 'revoke';
  static const allocate = 'allocate';
  static const file = 'file';
}
