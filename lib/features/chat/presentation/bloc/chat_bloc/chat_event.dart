import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_enums.dart';
import '../../../domain/entities/chat_session.dart';

/// 会话事件基类
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// 加载会话列表事件
class LoadChats extends ChatEvent {
  const LoadChats();
}

/// 刷新会话列表事件
class RefreshChats extends ChatEvent {
  const RefreshChats();
}

/// 会话更新事件
class ChatsUpdated extends ChatEvent {
  /// 更新后的会话列表
  final List<ChatSession> sessions;

  const ChatsUpdated(this.sessions);

  @override
  List<Object> get props => [sessions];
}

/// 标记会话已读事件
class MarkSessionAsRead extends ChatEvent {
  /// 会话ID
  final String sessionId;

  const MarkSessionAsRead(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

/// 更新会话状态事件
class UpdateSessionStatus extends ChatEvent {
  /// 会话ID
  final String sessionId;
  
  /// 新状态
  final SessionStatus status;

  const UpdateSessionStatus({
    required this.sessionId,
    required this.status,
  });

  @override
  List<Object> get props => [sessionId, status];
}

/// 删除会话事件
class DeleteSession extends ChatEvent {
  /// 会话ID
  final String sessionId;

  const DeleteSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

/// 更新会话本地状态事件
class UpdateSessionLocalState extends ChatEvent {
  /// 会话ID
  final String sessionId;
  
  /// 是否置顶
  final bool? isPinned;
  
  /// 是否静音
  final bool? isMuted;

  const UpdateSessionLocalState({
    required this.sessionId,
    this.isPinned,
    this.isMuted,
  });

  @override
  List<Object?> get props => [sessionId, isPinned, isMuted];
}

/// 创建新会话事件
class CreateNewSession extends ChatEvent {
  /// 目标用户ID
  final String targetUserId;
  
  /// 初始消息内容
  final String? initialMessage;

  const CreateNewSession({
    required this.targetUserId,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [targetUserId, initialMessage];
}

/// 新消息通知事件
class NewMessageNotification extends ChatEvent {
  /// 会话ID
  final String sessionId;
  
  /// 消息内容
  final String content;
  
  /// 发送者名称
  final String senderName;

  const NewMessageNotification({
    required this.sessionId,
    required this.content,
    required this.senderName,
  });

  @override
  List<Object> get props => [sessionId, content, senderName];
} 