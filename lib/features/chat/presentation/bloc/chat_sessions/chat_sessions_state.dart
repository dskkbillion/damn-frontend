import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

/// 聊天会话状态基类
abstract class ChatSessionsState extends Equatable {
  const ChatSessionsState();
  
  @override
  List<Object?> get props => [];
}

/// 初始状态
class ChatSessionsInitial extends ChatSessionsState {
  const ChatSessionsInitial();
}

/// 加载中状态
class ChatSessionsLoading extends ChatSessionsState {
  const ChatSessionsLoading();
}

/// 已加载状态
class ChatSessionsLoaded extends ChatSessionsState {
  /// 会话列表
  final List<ChatSession> sessions;

  const ChatSessionsLoaded({
    required this.sessions,
  });

  /// 创建更新后的状态
  ChatSessionsLoaded copyWith({
    List<ChatSession>? sessions,
  }) {
    return ChatSessionsLoaded(
      sessions: sessions ?? this.sessions,
    );
  }

  @override
  List<Object?> get props => [sessions];
}

/// 错误状态
class ChatSessionsError extends ChatSessionsState {
  /// 错误消息
  final String message;

  const ChatSessionsError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// 会话创建成功状态
class ChatSessionCreated extends ChatSessionsState {
  /// 创建的会话
  final ChatSession session;

  const ChatSessionCreated({
    required this.session,
  });

  @override
  List<Object?> get props => [session];
}

/// 会话设置更新成功状态
class ChatSessionSettingsUpdated extends ChatSessionsState {
  /// 会话ID
  final String sessionId;
  
  /// 是否置顶
  final bool isPinned;
  
  /// 是否静音
  final bool isMuted;

  const ChatSessionSettingsUpdated({
    required this.sessionId,
    required this.isPinned,
    required this.isMuted,
  });

  @override
  List<Object?> get props => [sessionId, isPinned, isMuted];
} 