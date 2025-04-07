import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_session.dart';

/// 会话状态基类
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// 会话列表初始状态
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// 会话列表加载中状态
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// 会话列表加载成功状态
class ChatLoaded extends ChatState {
  /// 会话列表
  final List<ChatSession> sessions;
  
  /// 是否刷新中
  final bool isRefreshing;
  
  /// 是否还有更多会话
  final bool hasReachedMax;

  const ChatLoaded({
    required this.sessions,
    this.isRefreshing = false,
    this.hasReachedMax = false,
  });

  /// 创建新的状态实例，但部分字段值已更新
  ChatLoaded copyWith({
    List<ChatSession>? sessions,
    bool? isRefreshing,
    bool? hasReachedMax,
  }) {
    return ChatLoaded(
      sessions: sessions ?? this.sessions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [sessions, isRefreshing, hasReachedMax];
}

/// 会话操作中状态
class ChatActionInProgress extends ChatState {
  /// 正在执行的操作描述
  final String action;
  
  /// 操作的会话ID
  final String sessionId;

  const ChatActionInProgress({
    required this.action,
    required this.sessionId,
  });

  @override
  List<Object> get props => [action, sessionId];
}

/// 会话操作失败状态
class ChatActionFailed extends ChatState {
  /// 错误消息
  final String message;
  
  /// 失败的会话ID
  final String? sessionId;
  
  /// 失败的操作
  final String? action;

  const ChatActionFailed({
    required this.message,
    this.sessionId,
    this.action,
  });

  @override
  List<Object?> get props => [message, sessionId, action];
}

/// 会话列表加载失败状态
class ChatLoadFailure extends ChatState {
  /// 错误消息
  final String message;

  const ChatLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

/// 新会话创建成功状态
class NewSessionCreated extends ChatState {
  /// 创建的会话
  final ChatSession session;

  const NewSessionCreated(this.session);

  @override
  List<Object> get props => [session];
}

/// 会话已删除状态
class SessionDeleted extends ChatState {
  /// 删除的会话ID
  final String sessionId;

  const SessionDeleted(this.sessionId);

  @override
  List<Object> get props => [sessionId];
} 