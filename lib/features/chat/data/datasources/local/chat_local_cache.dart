import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/message.dart';

/// 抽象类：定义聊天数据的本地缓存操作
abstract class IChatLocalCache {
  /// 保存会话列表到缓存。
  /// 通常是全量替换。
  Future<void> saveChatSessions(List<ChatSession> sessions);

  /// 从缓存获取会话列表。
  Future<List<ChatSession>> getChatSessions();

  /// 保存指定会话的消息列表到缓存。
  /// [chatId]: 会话 ID。
  /// [messages]: 该会话的消息列表 (通常是全量替换或增量添加)。
  Future<void> saveMessages(int chatId, List<Message> messages);

  /// 从缓存获取指定会话的消息列表。
  Future<List<Message>> getMessages(int chatId);

  /// 添加或更新单个消息到缓存。
  /// 用于新发送/接收的消息或状态更新。
  Future<void> addOrUpdateMessage(Message message);

  /// 从缓存中删除指定消息。
  Future<void> deleteMessage(int messageId);

   /// 从缓存中删除指定会话的所有消息。
   Future<void> clearSessionMessages(int chatId);

  /// 清除所有聊天相关的缓存。
  Future<void> clearAllCache();
} 