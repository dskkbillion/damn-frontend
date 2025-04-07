import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../entities/chat_enums.dart';
import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 发送消息参数
///
/// 封装发送新消息所需的参数
class SendMessageParams extends Equatable {
  /// 会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 消息类型
  final MessageType type;
  
  /// 接收者ID
  final String receiverId;
  
  /// 父消息ID（用于回复场景）
  final String? parentMessageId;
  
  /// 其他元数据
  final Map<String, dynamic>? metadata;

  /// 创建发送消息参数
  ///
  /// [sessionId] 会话ID
  /// [content] 消息内容
  /// [receiverId] 接收者ID
  /// [type] 消息类型，默认为文本
  /// [parentMessageId] 父消息ID，用于回复场景
  /// [metadata] 其他元数据，如图片URL等
  const SendMessageParams({
    required this.sessionId,
    required this.content,
    required this.receiverId,
    this.type = MessageType.TEXT,
    this.parentMessageId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    sessionId, 
    content, 
    type, 
    receiverId, 
    parentMessageId, 
    metadata,
  ];
}

/// 发送消息用例
///
/// 负责构建消息对象并发送，处理消息状态跟踪
class SendMessageUseCase implements UseCase<Future<Either<ChatFailure, Message>>, SendMessageParams> {
  final IChatRepository _chatRepository;
  final String _currentUserId;
  
  /// 创建发送消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  /// [currentUserId] 当前用户ID
  const SendMessageUseCase(this._chatRepository, this._currentUserId);

  @override
  Future<Either<ChatFailure, Message>> call(SendMessageParams params) async {
    // 验证消息内容
    if (params.content.trim().isEmpty && params.type == MessageType.TEXT) {
      return Left(ValidationFailure(message: '消息内容不能为空'));
    }
    
    // 创建唯一消息ID
    final messageId = const Uuid().v4();
    
    // 构建消息对象
    final message = Message(
      id: messageId,
      sessionId: params.sessionId,
      content: params.content,
      senderId: _currentUserId,
      senderType: MessageSenderType.USER,
      messageSource: MessageSourceType.USER,
      receiverId: params.receiverId,
      receiverType: MessageReceiverType.USER, // 假设接收者是用户
      timestamp: DateTime.now(),
      status: MessageStatus.SENDING,
      type: params.type,
      syncStatus: MessageSyncStatus.PENDING,
      parentMessageId: params.parentMessageId,
      metadata: params.metadata,
    );
    
    // 发送消息
    return _chatRepository.sendMessage(message);
  }
}

/// 重试失败消息用例
///
/// 尝试重新发送失败的消息
class RetryFailedMessageUseCase implements UseCase<Future<Either<ChatFailure, Message>>, String> {
  final IChatRepository _chatRepository;

  /// 创建重试失败消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const RetryFailedMessageUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, Message>> call(String messageId) async {
    // 先清除错误状态
    final clearResult = await _chatRepository.clearError(messageId);
    
    if (clearResult.isLeft()) {
      return clearResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unreachable'),
      );
    }
    
    // 尝试重新发送消息
    // 需要先获取消息详情
    final messageResult = await _chatRepository.getMessages(
      '', // 这里不关心sessionId，因为我们用messageId搜索
      messageId,
      1,
    );
    
    return messageResult.fold(
      (failure) => Left(failure),
      (messages) {
        if (messages.isEmpty) {
          return Left(NotFoundFailure(message: '未找到消息: $messageId'));
        }
        
        final message = messages.first;
        return _chatRepository.sendMessage(message);
      },
    );
  }
} 