import '../entities/chat_session.dart';
import '../entities/message.dart';

/// 聊天本地缓存接口
abstract class IChatLocalCache {
  /// 保存（覆盖）整个聊天会话列表到本地缓存。
  Future<void> saveChatSessions(List<ChatSession> sessions);

  /// 从本地缓存获取聊天会话列表。
  Future<List<ChatSession>> getChatSessions();

  /// 保存（覆盖）指定会话的消息列表到本地缓存。
  Future<void> saveMessages(int chatId, List<Message> messages);

  /// 从本地缓存获取指定会话的消息列表。
  /// 注意：此方法获取缓存中的所有消息。
  Future<List<Message>> getMessages(int chatId);

  /// 添加或更新单条消息到本地缓存。
  /// 如果消息已存在 (基于 id 或 localId)，则更新；否则添加。
  Future<void> addOrUpdateMessage(Message message);

  /// 从本地缓存中删除指定的消息。
  ///
  /// [messageId] 是要删除的消息的服务器 ID。
  /// 如果需要根据 localId 删除，可以考虑添加额外方法。
  Future<void> deleteMessage(int messageId);

  /// 清除指定会话的所有消息缓存。
  Future<void> clearSessionMessages(int chatId);

  /// 清除所有聊天相关的本地缓存（会话和消息）。
  Future<void> clearAllCache();
} 