import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_session.dart';
import '../../../domain/failures/chat_failure.dart';
import '../../../domain/usecases/create_session.dart';
import '../../../domain/usecases/get_chat_sessions.dart';
import '../../../domain/usecases/manage_session.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// 会话列表Bloc
///
/// 管理会话列表状态，处理会话相关操作
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // 用例
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final ManageSessionUseCase _manageSessionUseCase;

  // 订阅
  StreamSubscription? _sessionsSubscription;

  /// 创建会话列表Bloc
  ///
  /// [getChatSessionsUseCase] 获取会话列表用例
  /// [createSessionUseCase] 创建会话用例
  /// [manageSessionUseCase] 管理会话用例
  ChatBloc({
    required GetChatSessionsUseCase getChatSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required ManageSessionUseCase manageSessionUseCase,
  })  : _getChatSessionsUseCase = getChatSessionsUseCase,
        _createSessionUseCase = createSessionUseCase,
        _manageSessionUseCase = manageSessionUseCase,
        super(const ChatInitial()) {
    // 注册事件处理器
    on<LoadChats>(_onLoadChats);
    on<RefreshChats>(_onRefreshChats);
    on<ChatsUpdated>(_onChatsUpdated);
    on<MarkSessionAsRead>(_onMarkSessionAsRead);
    on<UpdateSessionStatus>(_onUpdateSessionStatus);
    on<DeleteSession>(_onDeleteSession);
    on<UpdateSessionLocalState>(_onUpdateSessionLocalState);
    on<CreateNewSession>(_onCreateNewSession);
    on<NewMessageNotification>(_onNewMessageNotification);
  }

  /// 处理加载会话列表事件
  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    
    // 监听会话列表流
    await _sessionsSubscription?.cancel();
    _sessionsSubscription = _getChatSessionsUseCase(const NoParams())
        .listen(
          (sessions) => add(ChatsUpdated(sessions)),
          onError: (error) => emit(ChatLoadFailure(message: error.toString())),
        );
  }

  /// 处理刷新会话列表事件
  Future<void> _onRefreshChats(RefreshChats event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(isRefreshing: true));
      // 刷新操作在仓库层处理
      // 这里不需要额外操作，因为会话列表流会自动更新
    }
  }

  /// 处理会话更新事件
  void _onChatsUpdated(ChatsUpdated event, Emitter<ChatState> emit) {
    emit(ChatLoaded(
      sessions: event.sessions,
      isRefreshing: false,
    ));
  }

  /// 处理标记会话已读事件
  Future<void> _onMarkSessionAsRead(MarkSessionAsRead event, Emitter<ChatState> emit) async {
    emit(ChatActionInProgress(
      action: '标记已读',
      sessionId: event.sessionId,
    ));

    final result = await _manageSessionUseCase(ManageSessionParams(
      sessionId: event.sessionId,
      markAsRead: true,
    ));

    result.fold(
      (failure) => emit(ChatActionFailed(
        message: _mapFailureToMessage(failure),
        sessionId: event.sessionId,
        action: '标记已读',
      )),
      (_) {
        // 不需要额外操作，会话列表流会自动更新
        if (state is ChatLoaded) {
          emit((state as ChatLoaded));
        }
      },
    );
  }

  /// 处理更新会话状态事件
  Future<void> _onUpdateSessionStatus(UpdateSessionStatus event, Emitter<ChatState> emit) async {
    emit(ChatActionInProgress(
      action: '更新状态',
      sessionId: event.sessionId,
    ));

    final result = await _manageSessionUseCase(ManageSessionParams(
      sessionId: event.sessionId,
      status: event.status,
    ));

    result.fold(
      (failure) => emit(ChatActionFailed(
        message: _mapFailureToMessage(failure),
        sessionId: event.sessionId,
        action: '更新状态',
      )),
      (_) {
        // 不需要额外操作，会话列表流会自动更新
        if (state is ChatLoaded) {
          emit((state as ChatLoaded));
        }
      },
    );
  }

  /// 处理删除会话事件
  Future<void> _onDeleteSession(DeleteSession event, Emitter<ChatState> emit) async {
    emit(ChatActionInProgress(
      action: '删除会话',
      sessionId: event.sessionId,
    ));

    final result = await _manageSessionUseCase(ManageSessionParams(
      sessionId: event.sessionId,
      isDelete: true,
    ));

    result.fold(
      (failure) => emit(ChatActionFailed(
        message: _mapFailureToMessage(failure),
        sessionId: event.sessionId,
        action: '删除会话',
      )),
      (_) => emit(SessionDeleted(event.sessionId)),
    );
  }

  /// 处理更新会话本地状态事件
  Future<void> _onUpdateSessionLocalState(UpdateSessionLocalState event, Emitter<ChatState> emit) async {
    emit(ChatActionInProgress(
      action: event.isPinned != null ? '置顶会话' : '静音会话',
      sessionId: event.sessionId,
    ));

    final result = await _manageSessionUseCase(ManageSessionParams(
      sessionId: event.sessionId,
      isPinned: event.isPinned,
      isMuted: event.isMuted,
    ));

    result.fold(
      (failure) => emit(ChatActionFailed(
        message: _mapFailureToMessage(failure),
        sessionId: event.sessionId,
        action: event.isPinned != null ? '置顶会话' : '静音会话',
      )),
      (_) {
        // 不需要额外操作，会话列表流会自动更新
        if (state is ChatLoaded) {
          emit((state as ChatLoaded));
        }
      },
    );
  }

  /// 处理创建新会话事件
  Future<void> _onCreateNewSession(CreateNewSession event, Emitter<ChatState> emit) async {
    emit(ChatActionInProgress(
      action: '创建会话',
      sessionId: event.targetUserId, // 临时使用targetUserId作为sessionId
    ));

    final result = await _createSessionUseCase(CreateSessionParams(
      targetUserId: event.targetUserId,
      initialMessage: event.initialMessage,
    ));

    result.fold(
      (failure) => emit(ChatActionFailed(
        message: _mapFailureToMessage(failure),
        action: '创建会话',
      )),
      (session) => emit(NewSessionCreated(session)),
    );
  }

  /// 处理新消息通知事件
  void _onNewMessageNotification(NewMessageNotification event, Emitter<ChatState> emit) {
    // 这里可以处理通知逻辑，例如显示系统通知
    // 实际的会话更新会通过会话列表流自动更新
  }

  /// 将失败对象转换为可读消息
  String _mapFailureToMessage(ChatFailure failure) {
    return failure.message ?? '操作失败';
  }

  @override
  Future<void> close() {
    _sessionsSubscription?.cancel();
    return super.close();
  }
} 