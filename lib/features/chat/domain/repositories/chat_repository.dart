import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../../../../core/error/failures.dart';

/// 会话状态枚举
enum SessionStatus {
  /// 正常
  NORMAL,
  /// 已删除
  DELETED,
  /// 已归档
  ARCHIVED,
  /// 已屏蔽
  BLOCKED,
}

/// 聊天仓库接口，定义了与聊天相关的数据操作契约
abstract class IChatRepository {
  /// 获取会话列表流
  Stream<List<ChatSession>> getChatSessions();
  
  /// 标记会话为已读
  /// 
  /// [sessionId] 要标记的会话ID
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> markSessionAsRead(String sessionId);
  
  /// 更新会话状态
  /// 
  /// [sessionId] 要更新的会话ID
  /// [status] 新的会话状态
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> updateSessionStatus(String sessionId, SessionStatus status);
  
  /// 删除会话
  /// 
  /// [sessionId] 要删除的会话ID
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> deleteSession(String sessionId);
  
  /// 获取会话详情
  /// 
  /// [sessionId] 会话ID
  /// 返回会话详情或失败
  Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId);
  
  /// 创建会话
  /// 
  /// [targetUserId] 目标用户ID
  /// [initialMessage] 可选的初始消息
  /// 返回创建的会话或失败
  Future<Either<Failure, ChatSession>> createSession(String targetUserId, {Message? initialMessage});
  
  /// 获取历史消息
  /// 
  /// [sessionId] 会话ID
  /// [beforeMessageId] 可选的消息ID，获取此ID之前的消息
  /// [limit] 返回消息数量限制
  /// 返回消息列表或失败
  Future<Either<Failure, List<Message>>> getMessages(String sessionId, String? beforeMessageId, int limit);
  
  /// 发送消息
  /// 
  /// [message] 要发送的消息
  /// 返回发送后的消息或失败
  Future<Either<Failure, Message>> sendMessage(Message message);
  
  /// 撤回消息
  /// 
  /// [messageId] 要撤回的消息ID
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> revokeMessage(String messageId);
  
  /// 删除消息
  /// 
  /// [messageId] 要删除的消息ID
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> deleteMessage(String messageId);
  
  /// 监听新消息流
  Stream<Message> observeMessages();
  
  /// 监听消息状态更新流
  Stream<MessageStatusUpdate> observeMessageStatusUpdates();
  
  /// 重试操作
  /// 
  /// [operation] 要重试的操作
  /// [maxRetries] 最大重试次数
  /// 返回重试后的结果
  Future<Either<Failure, T>> retryOperation<T>(Future<Either<Failure, T>> Function() operation, int maxRetries);
  
  /// 清除消息错误状态
  /// 
  /// [messageId] 消息ID
  /// 返回操作结果，成功或失败
  Future<Either<Failure, void>> clearError(String messageId);
} 