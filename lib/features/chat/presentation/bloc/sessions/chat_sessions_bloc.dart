import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/usecases/get_chat_sessions_usecase.dart';
import '../../../domain/usecases/observe_chat_sessions_usecase.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/failure.dart';
import './chat_sessions_event.dart';
import './chat_sessions_state.dart';

/// 管理会话列表状态的 Bloc
class ChatSessionsBloc extends Bloc<ChatSessionsEvent, ChatSessionsState> {
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final ObserveChatSessionsUseCase _observeChatSessionsUseCase;
  final MarkSessionAsReadUseCase _markSessionAsReadUseCase;
  StreamSubscription<Either<Failure, List<ChatSession>>>? _sessionsSubscription;

  ChatSessionsBloc({
    required GetChatSessionsUseCase getChatSessionsUseCase,
    required ObserveChatSessionsUseCase observeChatSessionsUseCase,
    required MarkSessionAsReadUseCase markSessionAsReadUseCase,
  })
      : _getChatSessionsUseCase = getChatSessionsUseCase,
        _observeChatSessionsUseCase = observeChatSessionsUseCase,
        _markSessionAsReadUseCase = markSessionAsReadUseCase,
        super(ChatSessionsInitial()) {
    on<LoadChatSessions>(_onLoadChatSessions);
    on<_SessionsUpdated>(_onSessionsUpdated);
    on<MarkSessionAsRead>(_onMarkSessionAsRead);
    on<UpdateSingleSession>(_onUpdateSingleSession);

    // Start observing immediately when the Bloc is created
    _observeSessions();
  }

  void _observeSessions() {
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _observeChatSessionsUseCase().listen(
      (eitherResult) {
        eitherResult.fold(
          (failure) => add(const _SessionsErrorEvent()),
          (sessions) => add(_SessionsUpdated(sessions)),
        );
      },
      onError: (_) => add(const _SessionsErrorEvent()),
    );
  }

  Future<void> _onLoadChatSessions(
    LoadChatSessions event,
    Emitter<ChatSessionsState> emit,
  ) async {
    // Show loading only if state is initial or forced refresh
    if (state is ChatSessionsInitial || event.forceRefresh) {
      emit(ChatSessionsLoading(state.sessions)); // Keep old data while loading if available
    }
    
    final result = await _getChatSessionsUseCase();
    // The observer should ideally pick up the change after getChatSessions updates the source.
    // If the observer doesn't update immediately, we might need to manually emit here.
    // However, relying on the observer is cleaner.
    
    // Handle potential immediate failure from getChatSessions
    result.fold(
      (failure) {
        // If observer hasn't updated yet, show error state
        if (state is ChatSessionsLoading || state is ChatSessionsInitial) {
          emit(ChatSessionsError(failure, state.sessions));
        }
        // Error will also be potentially caught by the observer stream later
      },
      (_) {
        // Success from getChatSessions. 
        // We expect _observeSessions to emit _SessionsUpdated soon.
        // If we still show loading, keep showing it until observer updates.
        if (state is ChatSessionsLoading) {
          // Stay in loading state, waiting for observer
        } else if (state is ChatSessionsInitial) {
          // Might transition to loading briefly if observer is slow
          emit(ChatSessionsLoading(state.sessions)); 
        }
      }
    );
  }

  void _onSessionsUpdated(_SessionsUpdated event, Emitter<ChatSessionsState> emit) {
    // Sort sessions by last message timestamp, newest first
    final sortedSessions = List<ChatSession>.from(event.sessions);
    sortedSessions.sort((a, b) {
      final timeA = a.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = b.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeB.compareTo(timeA); // Descending order
    });
    emit(ChatSessionsLoaded(sortedSessions));
  }

  Future<void> _onMarkSessionAsRead(
    MarkSessionAsRead event,
    Emitter<ChatSessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatSessionsLoaded) {
      // Optimistically update the UI first
      final updatedSessions = currentState.sessions.map((s) {
        if (s.id == event.chatId) {
          return s.copyWith(messageNum: 0);
        }
        return s;
      }).toList();
      emit(ChatSessionsLoaded(updatedSessions));
      
      // Then call the use case
      final result = await _markSessionAsReadUseCase(event.chatId);
      result.fold(
        (failure) {
          // Handle failure, maybe revert optimistic update or show snackbar
          print("Failed to mark session ${event.chatId} as read: ${failure.message}");
          // Revert UI change on failure? (Could cause flicker)
          // emit(ChatSessionsLoaded(currentState.sessions)); 
        },
        (_) {
          // Success - UI already updated optimistically
          print("Session ${event.chatId} marked as read successfully (API)");
        }
      );
    }
  }

  void _onUpdateSingleSession(UpdateSingleSession event, Emitter<ChatSessionsState> emit) {
    final currentState = state;
    if (currentState is ChatSessionsLoaded || currentState is ChatSessionsLoading || currentState is ChatSessionsError) {
      final currentList = List<ChatSession>.from(currentState.sessions);
      final index = currentList.indexWhere((s) => s.id == event.updatedSession.id);
      
      if (index != -1) {
        currentList[index] = event.updatedSession;
      } else {
        // New session, add it
        currentList.insert(0, event.updatedSession); // Add to beginning before sort
      }
      
      // Re-sort after update/add
      currentList.sort((a, b) {
        final timeA = a.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = b.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return timeB.compareTo(timeA); // Descending order
      });
      
      // Emit the correct state type with the updated list
      if (currentState is ChatSessionsLoaded) {
        emit(ChatSessionsLoaded(currentList));
      } else if (currentState is ChatSessionsLoading) {
        emit(ChatSessionsLoading(currentList));
      } else if (currentState is ChatSessionsError) {
        // Keep the error state but update the data
        emit(ChatSessionsError((currentState as ChatSessionsError).failure, currentList));
      }
    } else if (currentState is ChatSessionsInitial) {
      // If initial, just load the single session received
      emit(ChatSessionsLoaded([event.updatedSession]));
    }
  }

  // Handle internal error event from the stream observer
  void _onErrorEvent(_SessionsErrorEvent event, Emitter<ChatSessionsState> emit) {
    // Only transition to error state if not already showing loaded data
    if (state is! ChatSessionsLoaded) { 
      emit(ChatSessionsError(const GenericFailure("Failed to observe sessions"), state.sessions));
    } else {
      // Optionally log the error or show a non-blocking indicator
      print("Error observing sessions, but keeping existing data displayed.");
    }
  }

  @override
  Future<void> close() {
    _sessionsSubscription?.cancel();
    return super.close();
  }
} 