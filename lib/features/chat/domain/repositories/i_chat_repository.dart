import 'package:dartz/dartz.dart';

import '../entities/chat_enums.dart';
import '../entities/chat_session.dart';
import '../entities/message.dart';
import '../failures/chat_failure.dart';

/// 消息状态更新实体
class MessageStatusUpdate {
  /// 消息ID
  final String messageId;
  
  /// 新的消息状态
  final MessageStatus status;
  
  /// 创建消息状态更新
  const MessageStatusUpdate(this.messageId, this.status);
}

/// 聊天仓库接口
///
/// 定义聊天功能的所有数据操作方法，是Domain层与Data层之间的桥梁
abstract class IChatRepository {
  /// 获取当前用户的所有聊天会话
  ///
  /// 返回一个[Stream]，当会话列表发生变化时会发出新的列表
  Stream<List<ChatSession>> getChatSessions();
  
  /// 获取指定会话的详细信息
  ///
  /// [sessionId] 会话ID
  /// 
  /// 返回会话详情或失败信息
  Future<Either<ChatFailure, ChatSession>> getSessionDetail(String sessionId);
  
  /// 创建新的聊天会话
  ///
  /// [targetUserId] 对方用户ID
  /// [initialMessage] 可选的初始消息
  /// 
  /// 返回新创建的会话或失败信息
  Future<Either<ChatFailure, ChatSession>> createSession({
    required String targetUserId,
    Message? initialMessage,
  });
  
  /// 标记会话为已读
  ///
  /// [sessionId] 会话ID
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> markSessionAsRead(String sessionId);
  
  /// 更新会话状态
  ///
  /// [sessionId] 会话ID
  /// [status] 新的会话状态
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  );
  
  /// 删除会话
  ///
  /// [sessionId] 会话ID
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> deleteSession(String sessionId);
  
  /// 获取会话历史消息
  ///
  /// [sessionId] 会话ID
  /// [beforeMessageId] 可选，获取此消息ID之前的消息
  /// [limit] 获取的消息数量上限
  /// 
  /// 返回消息列表或失败信息
  Future<Either<ChatFailure, List<Message>>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  );
  
  /// 发送消息
  ///
  /// [message] 要发送的消息
  /// 
  /// 返回发送后的消息（可能包含服务器分配的ID）或失败信息
  Future<Either<ChatFailure, Message>> sendMessage(Message message);
  
  /// 撤回消息
  ///
  /// [messageId] 要撤回的消息ID
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> revokeMessage(String messageId);
  
  /// 删除消息
  ///
  /// [messageId] 要删除的消息ID
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> deleteMessage(String messageId);
  
  /// 监听新消息
  ///
  /// 返回一个[Stream]，当收到新消息时会发出
  Stream<Message> observeMessages();
  
  /// 监听消息状态更新
  ///
  /// 返回一个[Stream]，当消息状态变化时会发出
  Stream<MessageStatusUpdate> observeMessageStatusUpdates();
  
  /// 尝试重试操作
  ///
  /// [operation] 要重试的操作函数
  /// [maxRetries] 最大重试次数
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, T>> retryOperation<T>(
    Future<Either<ChatFailure, T>> Function() operation,
    int maxRetries,
  );
  
  /// 清除消息错误状态
  ///
  /// [messageId] 消息ID
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, void>> clearError(String messageId);
  
  /// 批量加载会话中的消息
  ///
  /// [sessionId] 会话ID
  /// [fromTimestamp] 从此时间戳开始加载
  /// [limit] 加载的消息数量上限
  /// 
  /// 返回消息列表或失败信息
  Future<Either<ChatFailure, List<Message>>> batchLoadMessages(
    String sessionId,
    DateTime fromTimestamp,
    int limit,
  );
  
  /// 搜索消息
  ///
  /// [query] 搜索关键词
  /// [sessionId] 可选，限制在指定会话中搜索
  /// 
  /// 返回搜索结果或失败信息
  Future<Either<ChatFailure, List<Message>>> searchMessages(
    String query, {
    String? sessionId,
  });
  
  /// 更新本地会话状态
  ///
  /// [sessionId] 会话ID
  /// [isPinned] 是否置顶
  /// [isMuted] 是否静音
  /// 
  /// 返回操作结果或失败信息
  Future<Either<ChatFailure, ChatSession>> updateLocalSessionState(
    String sessionId, {
    bool? isPinned,
    bool? isMuted,
  });
} 