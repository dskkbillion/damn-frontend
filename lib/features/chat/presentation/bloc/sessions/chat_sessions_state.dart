part of 'chat_sessions_bloc.dart';

abstract class ChatSessionsState extends Equatable {
  final List<ChatSession> sessions; // Keep track of sessions even in loading/error states

  const ChatSessionsState({this.sessions = const []});

  @override
  List<Object> get props => [sessions];
}

/// Initial state before any sessions are loaded.
class ChatSessionsInitial extends ChatSessionsState {}

/// State while sessions are being loaded (can hold previous data).
class ChatSessionsLoading extends ChatSessionsState {
  const ChatSessionsLoading(List<ChatSession> sessions) : super(sessions: sessions);
}

/// State when sessions have been successfully loaded.
class ChatSessionsLoaded extends ChatSessionsState {
  const ChatSessionsLoaded(List<ChatSession> sessions) : super(sessions: sessions);
}

/// State when an error occurred while loading sessions (can hold previous data).
class ChatSessionsError extends ChatSessionsState {
  final Failure failure;

  const ChatSessionsError(this.failure, List<ChatSession> sessions) : super(sessions: sessions);

  @override
  List<Object> get props => [failure, sessions];
}

/// Internal event to signal an error from the observer stream
/// This is used to avoid emitting ChatSessionsError directly from the listener
/// if we already have data loaded.
class _SessionsErrorEvent extends ChatSessionsEvent {
   const _SessionsErrorEvent();
} 