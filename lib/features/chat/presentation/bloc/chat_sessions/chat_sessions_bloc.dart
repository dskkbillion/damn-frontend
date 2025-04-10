import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/usecases/usecases.dart';
import 'chat_sessions_event.dart';
import 'chat_sessions_state.dart';

/// 聊天会话Bloc
class ChatSessionsBloc extends Bloc<ChatSessionsEvent, ChatSessionsState> {
  final ManageSessionUseCase _manageSessionUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final ManageNotificationsUseCase _manageNotificationsUseCase;
  final ReceiveMessageUseCase _receiveMessageUseCase;
  
  late StreamSubscription<Message> _messagesSubscription;
  late StreamSubscription<List<ChatSession>> _sessionsSubscription;

  ChatSessionsBloc({
    required ManageSessionUseCase manageSessionUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required ManageNotificationsUseCase manageNotificationsUseCase,
    required ReceiveMessageUseCase receiveMessageUseCase,
  }) : _manageSessionUseCase = manageSessionUseCase,
       _createSessionUseCase = createSessionUseCase,
       _manageNotificationsUseCase = manageNotificationsUseCase,
       _receiveMessageUseCase = receiveMessageUseCase,
       super(const ChatSessionsInitial()) {
    on<ChatSessionsLoadEvent>(_onLoadSessions);
    on<ChatSessionCreateEvent>(_onCreateSession);
    on<ChatSessionDeleteEvent>(_onDeleteSession);
    on<ChatSessionUpdateSettingsEvent>(_onUpdateSettings);
    on<ChatSessionMarkAsReadEvent>(_onMarkAsRead);
    on<ChatSessionNewMessageEvent>(_onNewMessage);
    
    // 监听新消息，更新对应的会话
    _messagesSubscription = _receiveMessageUseCase.execute().listen((message) {
      add(ChatSessionNewMessageEvent(sessionId: message.sessionId));
    });
    
    // 监听会话列表变化
    _sessionsSubscription = _manageSessionUseCase.getSessions().listen((sessions) {
      if (state is ChatSessionsLoaded) {
        emit(ChatSessionsLoaded(sessions: sessions));
      }
    });
  }

  @override
  Future<void> close() {
    _messagesSubscription.cancel();
    _sessionsSubscription.cancel();
    return super.close();
  }

  /// 处理加载会话列表事件
  Future<void> _onLoadSessions(
    ChatSessionsLoadEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    emit(const ChatSessionsLoading());
    
    try {
      final sessions = await _manageSessionUseCase.getSessions().first;
      
      // 按最新消息时间和置顶状态排序
      final sortedSessions = _sortSessions(sessions);
      
      emit(ChatSessionsLoaded(sessions: sortedSessions));
    } catch (e) {
      emit(ChatSessionsError(message: e.toString()));
    }
  }

  /// 处理创建会话事件
  Future<void> _onCreateSession(
    ChatSessionCreateEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    emit(const ChatSessionsLoading());
    
    try {
      // 创建消息实体（如果提供了初始消息）
      Message? initialMessage;
      if (event.initialMessage != null && event.initialMessage!.isNotEmpty) {
        // 这里需要构建Message对象，实际实现应该由Repository来完成
        // 这里仅做示例
      }
      
      // 创建会话
      final result = await _createSessionUseCase.execute(
        event.targetUserId,
        initialMessage: initialMessage,
      );
      
      result.fold(
        (failure) => emit(ChatSessionsError(message: failure.message)),
        (session) {
          emit(ChatSessionCreated(session: session));
          
          // 如果已加载会话列表，则更新列表
          if (state is ChatSessionsLoaded) {
            final currentState = state as ChatSessionsLoaded;
            final updatedSessions = List<ChatSession>.from(currentState.sessions);
            
            // 检查是否已存在该会话
            final existingIndex = updatedSessions.indexWhere((s) => s.id == session.id);
            if (existingIndex >= 0) {
              updatedSessions[existingIndex] = session;
            } else {
              updatedSessions.add(session);
            }
            
            emit(ChatSessionsLoaded(sessions: _sortSessions(updatedSessions)));
          }
        },
      );
    } catch (e) {
      emit(ChatSessionsError(message: e.toString()));
    }
  }

  /// 处理删除会话事件
  Future<void> _onDeleteSession(
    ChatSessionDeleteEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    if (state is ChatSessionsLoaded) {
      final currentState = state as ChatSessionsLoaded;
      
      try {
        final result = await _manageSessionUseCase.deleteSession(event.sessionId);
        
        result.fold(
          (failure) => emit(ChatSessionsError(message: failure.message)),
          (_) {
            // 从本地状态中移除会话
            final updatedSessions = currentState.sessions
                .where((session) => session.id != event.sessionId)
                .toList();
            
            emit(currentState.copyWith(sessions: updatedSessions));
          },
        );
      } catch (e) {
        emit(ChatSessionsError(message: e.toString()));
      }
    }
  }

  /// 处理更新会话设置事件
  Future<void> _onUpdateSettings(
    ChatSessionUpdateSettingsEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    if (state is ChatSessionsLoaded) {
      final currentState = state as ChatSessionsLoaded;
      
      try {
        // 创建通知设置参数
        final settings = NotificationSettings(
          sessionId: event.sessionId,
          isPinned: event.isPinned,
          isMuted: event.isMuted,
        );
        
        // 更新通知设置
        final result = await _manageNotificationsUseCase.updateNotificationSettings(settings);
        
        result.fold(
          (failure) => emit(ChatSessionsError(message: failure.message)),
          (updatedSession) {
            // 更新本地状态
            final sessionIndex = currentState.sessions.indexWhere(
              (session) => session.id == event.sessionId,
            );
            
            if (sessionIndex >= 0) {
              final updatedSessions = List<ChatSession>.from(currentState.sessions);
              updatedSessions[sessionIndex] = updatedSession;
              
              emit(ChatSessionsLoaded(sessions: _sortSessions(updatedSessions)));
              emit(ChatSessionSettingsUpdated(
                sessionId: event.sessionId,
                isPinned: event.isPinned,
                isMuted: event.isMuted,
              ));
            }
          },
        );
      } catch (e) {
        emit(ChatSessionsError(message: e.toString()));
      }
    }
  }

  /// 处理标记会话已读事件
  Future<void> _onMarkAsRead(
    ChatSessionMarkAsReadEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    if (state is ChatSessionsLoaded) {
      final currentState = state as ChatSessionsLoaded;
      
      try {
        final result = await _manageSessionUseCase.markAsRead(event.sessionId);
        
        result.fold(
          (failure) => emit(ChatSessionsError(message: failure.message)),
          (_) {
            // 更新本地状态
            final sessionIndex = currentState.sessions.indexWhere(
              (session) => session.id == event.sessionId,
            );
            
            if (sessionIndex >= 0) {
              final updatedSessions = List<ChatSession>.from(currentState.sessions);
              updatedSessions[sessionIndex] = updatedSessions[sessionIndex].copyWith(
                unreadCount: 0,
              );
              
              emit(currentState.copyWith(sessions: updatedSessions));
            }
          },
        );
      } catch (e) {
        emit(ChatSessionsError(message: e.toString()));
      }
    }
  }

  /// 处理新消息事件
  Future<void> _onNewMessage(
    ChatSessionNewMessageEvent event,
    Emitter<ChatSessionsState> emit,
  ) async {
    if (state is ChatSessionsLoaded) {
      final currentState = state as ChatSessionsLoaded;
      
      // 查找对应的会话
      final sessionIndex = currentState.sessions.indexWhere(
        (session) => session.id == event.sessionId,
      );
      
      if (sessionIndex >= 0) {
        // 更新会话的未读数量和位置
        final updatedSessions = List<ChatSession>.from(currentState.sessions);
        final currentSession = updatedSessions[sessionIndex];
        
        updatedSessions[sessionIndex] = currentSession.copyWith(
          unreadCount: currentSession.unreadCount + event.unreadCountIncrement,
          updatedAt: DateTime.now(),
        );
        
        emit(currentState.copyWith(sessions: _sortSessions(updatedSessions)));
      } else {
        // 如果会话不存在，可能需要重新加载会话列表
        add(const ChatSessionsLoadEvent());
      }
    }
  }

  /// 对会话列表进行排序（按置顶状态和最新消息时间）
  List<ChatSession> _sortSessions(List<ChatSession> sessions) {
    return sessions
      ..sort((a, b) {
        // 先按置顶状态排序
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        
        // 再按最新消息时间排序（降序）
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }
} 