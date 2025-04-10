import '../entities/entities.dart';

/// 聊天本地缓存接口
abstract class IChatLocalCache {
  /// 保存会话列表
  /// 
  /// [sessions] 要保存的会话列表
  Future<void> saveSessions(List<ChatSession> sessions);
  
  /// 获取本地会话列表
  Future<List<ChatSession>> getSessions();
  
  /// 更新会话已读状态
  /// 
  /// [sessionId] 会话ID
  Future<void> updateSessionReadStatus(String sessionId);
  
  /// 更新会话设置
  /// 
  /// [sessionId] 会话ID
  /// [muted] 是否静音通知
  /// [pinned] 是否置顶会话
  Future<void> updateSessionSettings(String sessionId, bool muted, bool pinned);
  
  /// 保存消息
  /// 
  /// [sessionId] 会话ID
  /// [messages] 要保存的消息列表
  Future<void> saveMessages(String sessionId, List<Message> messages);
  
  /// 获取本地消息
  /// 
  /// [sessionId] 会话ID
  /// [limit] 返回消息数量限制
  /// [beforeMessageId] 可选的消息ID，获取此ID之前的消息
  Future<List<Message>> getMessages(String sessionId, int limit, String? beforeMessageId);
  
  /// 更新消息状态
  /// 
  /// [messageId] 消息ID
  /// [status] 新的消息状态
  Future<void> updateMessageStatus(String messageId, MessageStatus status);
  
  /// 清除会话消息
  /// 
  /// [sessionId] 会话ID
  Future<void> clearSessionMessages(String sessionId);
  
  /// 清除过期消息
  /// 
  /// [expiration] 过期时间
  Future<void> clearExpiredMessages(Duration expiration);
  
  /// 设置缓存大小限制
  /// 
  /// [maxSize] 最大缓存大小(MB)
  Future<void> setCacheSizeLimit(int maxSize);
} 