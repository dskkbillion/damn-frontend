part of 'chat_sessions_bloc.dart';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/failure.dart';

/// ChatSessionsBloc 的事件
abstract class ChatSessionsEvent extends Equatable {
  const ChatSessionsEvent();

  @override
  List<Object> get props => [];
}

/// Event to load the initial list of chat sessions.
class LoadChatSessions extends ChatSessionsEvent {
  final bool forceRefresh; // Optional: force fetching from remote

  const LoadChatSessions({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

/// Event triggered when the underlying session data stream updates 
/// (e.g., from repository observation or realtime service).
class _SessionsUpdated extends ChatSessionsEvent {
  final List<ChatSession> sessions;

  const _SessionsUpdated(this.sessions);

  @override
  List<Object> get props => [sessions];
}

/// Event triggered when a single session needs an update (e.g., new message arrival in THIS session)
/// This might be triggered by the MessageBloc or RealtimeService.
class UpdateSingleSession extends ChatSessionsEvent {
   final ChatSession updatedSession;

   const UpdateSingleSession(this.updatedSession);

   @override
   List<Object> get props => [updatedSession];
}

/// Event to mark a specific chat session as read.
class MarkSessionAsRead extends ChatSessionsEvent {
  final int chatId;

  const MarkSessionAsRead(this.chatId);

  @override
  List<Object> get props => [chatId];
}

/// 实时会话加载错误事件 (内部使用，由 Stream 触发)
class _ChatSessionsUpdateError extends ChatSessionsEvent {
  final Failure failure;

  const _ChatSessionsUpdateError(this.failure);

  @override
  List<Object> get props => [failure];
} 