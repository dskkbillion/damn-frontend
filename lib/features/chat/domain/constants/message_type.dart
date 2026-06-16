/// 聊天消息类型常量，对应后端消息 type 字段值。
abstract final class ChatMessageType {
  static const text = 'text';
  static const image = 'image';
  static const audio = 'audio';
  static const revoke = 'revoke';
  static const allocate = 'allocate';
  static const file = 'file';

  /// #377 第②层：AI 会话 summary 的新类型（加法引入，写入端切到它）。
  /// 渲染端双认 [allocate]（历史数据）+ [aiSummary]（新写入），历史数据免迁移。
  static const aiSummary = 'ai_summary';
}
