import 'package:equatable/equatable.dart';

/// 聊天会话事件基类
abstract class ChatSessionsEvent extends Equatable {
  const ChatSessionsEvent();

  @override
  List<Object?> get props => [];
}

/// 加载会话列表事件
class ChatSessionsLoadEvent extends ChatSessionsEvent {
  const ChatSessionsLoadEvent();
}

/// 创建新会话事件
class ChatSessionCreateEvent extends ChatSessionsEvent {
  /// 目标用户ID
  final String targetUserId;
  
  /// 初始消息内容（可选）
  final String? initialMessage;

  const ChatSessionCreateEvent({
    required this.targetUserId,
    this.initialMessage,
  });

  @override
  List<Object?> get props => [targetUserId, initialMessage];
}

/// 删除会话事件
class ChatSessionDeleteEvent extends ChatSessionsEvent {
  /// 会话ID
  final String sessionId;

  const ChatSessionDeleteEvent({
    required this.sessionId,
  });

  @override
  List<Object?> get props => [sessionId];
}

/// 更新会话设置事件
class ChatSessionUpdateSettingsEvent extends ChatSessionsEvent {
  /// 会话ID
  final String sessionId;
  
  /// 是否置顶
  final bool isPinned;
  
  /// 是否静音
  final bool isMuted;

  const ChatSessionUpdateSettingsEvent({
    required this.sessionId,
    required this.isPinned,
    required this.isMuted,
  });

  @override
  List<Object?> get props => [sessionId, isPinned, isMuted];
}

/// 标记会话已读事件
class ChatSessionMarkAsReadEvent extends ChatSessionsEvent {
  /// 会话ID
  final String sessionId;

  const ChatSessionMarkAsReadEvent({
    required this.sessionId,
  });

  @override
  List<Object?> get props => [sessionId];
}

/// 接收新消息事件
class ChatSessionNewMessageEvent extends ChatSessionsEvent {
  /// 会话ID
  final String sessionId;
  
  /// 更新未读数量（增加）
  final int unreadCountIncrement;

  const ChatSessionNewMessageEvent({
    required this.sessionId,
    this.unreadCountIncrement = 1,
  });

  @override
  List<Object?> get props => [sessionId, unreadCountIncrement];
} 