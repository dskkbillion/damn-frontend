import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../entities/chat_enums.dart';
import '../entities/chat_session.dart';
import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 创建会话参数
///
/// 封装创建新会话所需的参数
class CreateSessionParams extends Equatable {
  /// 目标用户ID
  final String targetUserId;
  
  /// 初始消息内容（可选）
  final String? initialMessage;
  
  /// 初始消息类型
  final MessageType messageType;

  /// 创建会话参数
  ///
  /// [targetUserId] 目标用户ID
  /// [initialMessage] 初始消息内容
  /// [messageType] 初始消息类型，默认为文本
  const CreateSessionParams({
    required this.targetUserId,
    this.initialMessage,
    this.messageType = MessageType.TEXT,
  });

  @override
  List<Object?> get props => [targetUserId, initialMessage, messageType];
}

/// 创建会话用例
///
/// 创建新的聊天会话，可选择同时发送初始消息
class CreateSessionUseCase implements UseCase<Future<Either<ChatFailure, ChatSession>>, CreateSessionParams> {
  final IChatRepository _chatRepository;
  final String _currentUserId;

  /// 创建会话用例构造函数
  ///
  /// [chatRepository] 聊天仓库接口
  /// [currentUserId] 当前用户ID
  const CreateSessionUseCase(this._chatRepository, this._currentUserId);

  @override
  Future<Either<ChatFailure, ChatSession>> call(CreateSessionParams params) async {
    // 创建初始消息（如果有）
    Message? initialMessage;
    if (params.initialMessage != null && params.initialMessage!.isNotEmpty) {
      initialMessage = Message(
        id: const Uuid().v4(), // 生成唯一ID
        sessionId: '', // 会话ID将在仓库层设置
        content: params.initialMessage!,
        senderId: _currentUserId,
        senderType: MessageSenderType.USER,
        messageSource: MessageSourceType.USER,
        receiverId: params.targetUserId,
        receiverType: MessageReceiverType.USER,
        timestamp: DateTime.now(),
        status: MessageStatus.SENDING,
        type: params.messageType,
        syncStatus: MessageSyncStatus.PENDING,
      );
    }

    // 创建会话
    return _chatRepository.createSession(
      targetUserId: params.targetUserId,
      initialMessage: initialMessage,
    );
  }
} 