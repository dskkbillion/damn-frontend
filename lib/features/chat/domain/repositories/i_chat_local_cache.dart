import '../entities/chat_enums.dart';
import '../entities/chat_session.dart';
import '../entities/message.dart';

/// 聊天本地缓存接口
///
/// 负责聊天数据的本地持久化存储
abstract class IChatLocalCache {
  /// 会话缓存

  /// 保存会话列表
  ///
  /// [sessions] 要保存的会话列表
  Future<void> saveSessions(List<ChatSession> sessions);

  /// 保存单个会话
  ///
  /// [session] 要保存的会话
  Future<void> saveSession(ChatSession session);

  /// 获取本地存储的会话列表
  ///
  /// 返回本地缓存的会话列表
  Future<List<ChatSession>> getSessions();

  /// 获取单个会话
  ///
  /// [sessionId] 会话ID
  ///
  /// 返回会话信息，如果不存在则返回null
  Future<ChatSession?> getSession(String sessionId);

  /// 更新会话已读状态
  ///
  /// [sessionId] 会话ID
  Future<void> updateSessionReadStatus(String sessionId);

  /// 更新会话本地状态
  ///
  /// [sessionId] 会话ID
  /// [isPinned] 是否置顶
  /// [isMuted] 是否静音
  Future<void> updateSessionLocalState(
    String sessionId, {
    bool? isPinned,
    bool? isMuted,
  });

  /// 删除会话
  ///
  /// [sessionId] 会话ID
  Future<void> deleteSession(String sessionId);

  /// 消息缓存

  /// 保存消息列表
  ///
  /// [sessionId] 会话ID
  /// [messages] 要保存的消息列表
  Future<void> saveMessages(String sessionId, List<Message> messages);

  /// 保存单条消息
  ///
  /// [message] 要保存的消息
  Future<void> saveMessage(Message message);

  /// 获取本地存储的消息列表
  ///
  /// [sessionId] 会话ID
  /// [limit] 获取的消息数量上限
  /// [beforeMessageId] 可选，获取此消息ID之前的消息
  ///
  /// 返回本地缓存的消息列表
  Future<List<Message>> getMessages(
    String sessionId,
    int limit,
    String? beforeMessageId,
  );

  /// 获取单条消息
  ///
  /// [messageId] 消息ID
  ///
  /// 返回消息，如果不存在则返回null
  Future<Message?> getMessage(String messageId);

  /// 更新消息状态
  ///
  /// [messageId] 消息ID
  /// [status] 新的消息状态
  Future<void> updateMessageStatus(String messageId, MessageStatus status);

  /// 更新消息同步状态
  ///
  /// [messageId] 消息ID
  /// [syncStatus] 新的同步状态
  Future<void> updateMessageSyncStatus(
    String messageId,
    MessageSyncStatus syncStatus,
  );

  /// 标记消息为已删除
  ///
  /// [messageId] 消息ID
  Future<void> markMessageAsDeleted(String messageId);

  /// 清除会话的所有消息
  ///
  /// [sessionId] 会话ID
  Future<void> clearSessionMessages(String sessionId);

  /// 清除过期消息
  ///
  /// [expiration] 过期时间，比如7天前
  Future<void> clearExpiredMessages(Duration expiration);

  /// 缓存管理

  /// 设置缓存大小限制
  ///
  /// [maxSize] 最大缓存大小（字节）
  Future<void> setCacheSizeLimit(int maxSize);

  /// 清除所有缓存
  Future<void> clearAllCache();

  /// 获取缓存大小
  ///
  /// 返回当前缓存占用的空间（字节）
  Future<int> getCacheSize();

  /// 搜索消息
  ///
  /// [query] 搜索关键词
  /// [sessionId] 可选，限制在指定会话中搜索
  ///
  /// 返回符合条件的消息列表
  Future<List<Message>> searchMessages(
    String query, {
    String? sessionId,
  });

  /// 批量更新消息状态
  ///
  /// [sessionId] 会话ID
  /// [status] 新的消息状态
  Future<void> batchUpdateMessageStatus(
    String sessionId,
    MessageStatus status,
  );
} 