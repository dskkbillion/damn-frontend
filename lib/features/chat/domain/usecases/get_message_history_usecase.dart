import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 消息历史查询参数
class MessageHistoryParams {
  /// 会话ID
  final String sessionId;
  
  /// 分页标记（消息ID），获取此ID之前的消息
  final String? beforeMessageId;
  
  /// 每页消息数量
  final int pageSize;
  
  /// 消息类型过滤
  final MessageType? typeFilter;
  
  /// 发送者ID过滤
  final String? senderIdFilter;

  const MessageHistoryParams({
    required this.sessionId,
    this.beforeMessageId,
    this.pageSize = 20,
    this.typeFilter,
    this.senderIdFilter,
  });
}

/// 获取消息历史用例
class GetMessageHistoryUseCase {
  final IChatRepository _chatRepository;

  GetMessageHistoryUseCase(this._chatRepository);

  /// 执行获取消息历史操作
  /// 
  /// [params] 查询参数
  /// 返回消息列表或失败
  Future<Either<Failure, List<Message>>> execute(MessageHistoryParams params) async {
    // 获取基础消息列表
    final messagesResult = await _chatRepository.getMessages(
      params.sessionId, 
      params.beforeMessageId, 
      params.pageSize
    );
    
    return messagesResult.fold(
      (failure) => Left(failure),
      (messages) {
        // 应用过滤器
        var filteredMessages = messages;
        
        // 按消息类型过滤
        if (params.typeFilter != null) {
          filteredMessages = filteredMessages.where(
            (msg) => msg.type == params.typeFilter
          ).toList();
        }
        
        // 按发送者过滤
        if (params.senderIdFilter != null) {
          filteredMessages = filteredMessages.where(
            (msg) => msg.senderId == params.senderIdFilter
          ).toList();
        }
        
        // 按时间排序（从新到旧）
        filteredMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return Right(filteredMessages);
      }
    );
  }
  
  /// 搜索消息内容
  /// 
  /// [sessionId] 会话ID
  /// [searchText] 搜索文本
  /// [limit] 返回结果数量限制
  /// 返回匹配的消息列表
  Future<Either<Failure, List<Message>>> searchMessages(
    String sessionId, 
    String searchText, 
    {int limit = 20}
  ) async {
    // 获取足够多的消息以进行搜索
    final messagesResult = await _chatRepository.getMessages(sessionId, null, 100);
    
    return messagesResult.fold(
      (failure) => Left(failure),
      (messages) {
        // 在消息内容中搜索
        final searchResults = messages
          .where((msg) => 
            msg.content.toLowerCase().contains(searchText.toLowerCase()))
          .take(limit)
          .toList();
        
        return Right(searchResults);
      }
    );
  }
} 