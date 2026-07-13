import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
// Optional: for DI later
import 'package:flutter/foundation.dart'; // Add this for @immutable in part files

// Use package imports to avoid relative path issues
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // For NoParams
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/create_chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_room.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

// @injectable // Optional: for DI later
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRoomList getChatRoomList;
  final CreateChatRoom createChatRoom;
  final DeleteChatRoom deleteChatRoom;
  final IChatLocalDataSource localDataSource;
  final EventBus _eventBus = EventBus();
  StreamSubscription<ChatListUpdateEvent>? _chatListUpdateSubscription;
  static const Duration _reuseWindow = Duration(seconds: 30);
  DateTime? _lastSuccessfulLoadAt;
  bool _isLoadingChatRooms = false;

  ChatListBloc({
    required this.getChatRoomList,
    required this.createChatRoom,
    required this.deleteChatRoom,
    required this.localDataSource,
  })
      : super(const ChatListState()) {
    on<LoadChatRoomList>(_onLoadChatRoomList);
    on<RefreshChatList>(_onRefreshChatList);
    on<StartAdminChatRequested>(_onStartAdminChatRequested);
    on<ClearNavigationTrigger>(_onClearNavigationTrigger);
    on<UpdateChatRoomUnreadCount>(_onUpdateChatRoomUnreadCount);
    on<UpdateChatRoomLastMessage>(_onUpdateChatRoomLastMessage);
    on<_HandleChatListUpdate>(_onHandleChatListUpdate);
    on<DeleteChatRoomRequested>(_onDeleteChatRoomRequested);

    // 监听聊天列表更新事件
    _chatListUpdateSubscription = _eventBus.chatListUpdateStream.listen((event) {
      if (isClosed) return;
      AppLogger.d('[ChatListBloc] Received ChatListUpdateEvent for chatId: ${event.chatId}');
      add(_HandleChatListUpdate(event));
    });
  }

  Future<void> _onLoadChatRoomList(
    LoadChatRoomList event,
    Emitter<ChatListState> emit,
  ) async {
    AppLogger.d("[ChatListBloc] Handling LoadChatRoomList event...");

    final lastLoadedAt = _lastSuccessfulLoadAt;
    if (_isLoadingChatRooms) {
      AppLogger.d('[ChatListBloc] Skip duplicate load while request is in flight.');
      return;
    }
    if (lastLoadedAt != null &&
        state.status == ChatListStatus.success &&
        state.chatRooms.isNotEmpty &&
        DateTime.now().difference(lastLoadedAt) < _reuseWindow) {
      AppLogger.d('[ChatListBloc] Reuse recent chat list within $_reuseWindow.');
      return;
    }
    _isLoadingChatRooms = true;

    // Step 1: Show cached data immediately if available (stale-while-revalidate)
    final cachedRooms = await localDataSource.getCachedChatRoomList();
    if (cachedRooms != null && cachedRooms.isNotEmpty) {
      AppLogger.d('[ChatListBloc] Showing ${cachedRooms.length} cached chat rooms while refreshing.');
      emit(state.copyWith(
        status: ChatListStatus.success,
        chatRooms: cachedRooms,
        isRefreshing: true,
      ));
    } else {
      emit(state.copyWith(status: ChatListStatus.loading));
    }

    // Step 2: Fetch from remote
    final failureOrChatRooms = await getChatRoomList(NoParams());

    if (failureOrChatRooms.isLeft()) {
      final failure = (failureOrChatRooms as Left).value as Failure;
      AppLogger.d('[ChatListBloc] Failed to load chat rooms: $failure');
      if (cachedRooms != null && cachedRooms.isNotEmpty) {
        // Keep showing cached data, just stop the refreshing indicator
        emit(state.copyWith(isRefreshing: false));
      } else {
        emit(state.copyWith(
          status: ChatListStatus.failure,
          errorMessage: failure.toString(),
          isRefreshing: false,
        ));
      }
    } else {
      final chatRooms = (failureOrChatRooms as Right).value as List<ChatRoom>;
      AppLogger.d('[ChatListBloc] Successfully loaded ${chatRooms.length} chat rooms.');
      await localDataSource.cacheChatRoomList(chatRooms);
      _lastSuccessfulLoadAt = DateTime.now();
      emit(state.copyWith(
        status: ChatListStatus.success,
        chatRooms: chatRooms,
        isRefreshing: false,
      ));
    }
    _isLoadingChatRooms = false;
  }

  // Handler for the RefreshChatList event
  Future<void> _onRefreshChatList(
    RefreshChatList event,
    Emitter<ChatListState> emit,
  ) async {
    AppLogger.d('[ChatListBloc] Handling RefreshChatList event...');
    // Don't necessarily show loading indicator for a background refresh,
    // unless you want a pull-to-refresh visual later.
    // You could emit a specific status like `refreshing` if needed.
    // emit(state.copyWith(status: ChatListStatus.loading)); // Optional: Show loading

    final failureOrChatRooms = await getChatRoomList(NoParams());

    failureOrChatRooms.fold(
      (failure) {
        AppLogger.d('[ChatListBloc] Failed to refresh chat rooms: $failure');
        // Optionally emit a failure state, or just log it
        // emit(state.copyWith(status: ChatListStatus.failure, errorMessage: failure.toString())); 
      },
      (chatRooms) {
        AppLogger.d('[ChatListBloc] Successfully refreshed ${chatRooms.length} chat rooms.');
        // Emit success with the potentially updated list (unread counts)
        emit(state.copyWith(
            status: ChatListStatus.success, // Ensure status is success
            chatRooms: chatRooms));
      },
    );
  }

  // Handler for starting admin chat
  Future<void> _onStartAdminChatRequested(
    StartAdminChatRequested event,
    Emitter<ChatListState> emit,
  ) async {
    AppLogger.d("[ChatListBloc] Handling StartAdminChatRequested event...");
    // Optionally emit a loading state specific to this action if needed
    // emit(state.copyWith(status: ChatListStatus.loading)); 
    
    final result = await createChatRoom(const CreateChatRoomParams(participantId: 0)); // Admin refer_id is 0
    
    result.fold(
      (failure) {
         AppLogger.d("[ChatListBloc] Failed to create/get admin chat room: ${failure.message}");
         // Emit failure state, potentially with a message for the user
         emit(state.copyWith(status: ChatListStatus.failure, errorMessage: "无法连接到系统管理员: ${failure.message}"));
      },
      (chatId) {
        AppLogger.d("[ChatListBloc] Successfully created/retrieved admin chat room ID: $chatId. Triggering navigation.");
        // Emit state to trigger navigation
        emit(state.copyWith(status: ChatListStatus.success, navigateToChatId: chatId));
      },
    );
  }

  // Handler to clear the navigation trigger
  void _onClearNavigationTrigger(
    ClearNavigationTrigger event,
    Emitter<ChatListState> emit,
  ) {
    AppLogger.d("[ChatListBloc] Clearing navigation trigger.");
    // Emit state with navigateToChatId set to null using the flag
    emit(state.copyWith(clearNavigateToChatId: true)); 
  }

  // Handler to update unread count for a specific chat room
  void _onUpdateChatRoomUnreadCount(
    UpdateChatRoomUnreadCount event,
    Emitter<ChatListState> emit,
  ) {
    AppLogger.d('[ChatListBloc] Updating unread count for chatId ${event.chatId} to ${event.unreadCount}');
    
    // 更新对应聊天室的未读数量
    final updatedChatRooms = state.chatRooms.map((room) {
      if (room.id == event.chatId) {
        return room.copyWith(unreadCount: event.unreadCount);
      }
      return room;
    }).toList();
    
    emit(state.copyWith(chatRooms: updatedChatRooms));
  }

  void _onUpdateChatRoomLastMessage(
    UpdateChatRoomLastMessage event,
    Emitter<ChatListState> emit,
  ) {
    AppLogger.d('[ChatListBloc] Updating last message for chatId ${event.chatId}');

    // 更新对应聊天室的最后一条消息
    final updatedChatRooms = state.chatRooms.map((room) {
      if (room.id == event.chatId) {
        // 更新最后消息
        return room.copyWith(
          lastMessage: event.lastMessage,
        );
      }
      return room;
    }).toList();

    // 按最后活动时间重新排序（最新的在前）
    updatedChatRooms.sort((a, b) {
      final aTime = a.lastActivityTime;
      final bTime = b.lastActivityTime;
      // 处理空值情况
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    emit(state.copyWith(chatRooms: updatedChatRooms));
  }

  // 处理来自 EventBus 的聊天列表更新事件
  void _onHandleChatListUpdate(_HandleChatListUpdate event, Emitter<ChatListState> emit) {
    final updateEvent = event.updateEvent;
    AppLogger.d('[ChatListBloc] Processing chat list update for chatId: ${updateEvent.chatId}');
    AppLogger.d('[ChatListBloc] resetUnread: ${updateEvent.resetUnread}, unreadCountDelta: ${updateEvent.unreadCountDelta}');

    // 查找对应的聊天室
    final roomIndex = state.chatRooms.indexWhere((room) => room.id == updateEvent.chatId);

    if (roomIndex == -1) {
      AppLogger.d('[ChatListBloc] Chat room not found in current list, refreshing...');
      // 如果聊天室不在列表中，可能是新创建的，需要刷新列表
      add(RefreshChatList());
      return;
    }

    final room = state.chatRooms[roomIndex];
    var updatedRoom = room;

    // 更新最后消息
    if (updateEvent.lastMessage != null) {
      updatedRoom = updatedRoom.copyWith(
        lastMessage: ChatMessage(
          id: 0, // 临时ID，因为我们只关心显示内容
          context: updateEvent.lastMessage!,
          senderId: 0, // 临时senderId
          chatId: updateEvent.chatId,
          createTime: updateEvent.lastMessageTime ?? DateTime.now(),
          withdrawFlag: updateEvent.lastMessageWithdrawFlag ?? false,
          type: updateEvent.lastMessageType ?? 'text',
        ),
      );
    }

    // 更新未读数
    if (updateEvent.resetUnread) {
      AppLogger.d('[ChatListBloc] Resetting unread count for chatId: ${updateEvent.chatId}, old unreadCount: ${updatedRoom.unreadCount}');
      updatedRoom = updatedRoom.copyWith(unreadCount: 0);
      AppLogger.d('[ChatListBloc] After reset, new unreadCount: ${updatedRoom.unreadCount}');
    } else if (updateEvent.unreadCountDelta != null) {
      final oldUnreadCount = updatedRoom.unreadCount ?? 0;
      final newUnreadCount = oldUnreadCount + updateEvent.unreadCountDelta!;
      AppLogger.d('[ChatListBloc] Updating unread count for chatId: ${updateEvent.chatId}, old: $oldUnreadCount, delta: ${updateEvent.unreadCountDelta}, new: $newUnreadCount');
      updatedRoom = updatedRoom.copyWith(
        unreadCount: newUnreadCount >= 0 ? newUnreadCount : 0,
      );
    }

    // 创建更新后的列表
    final updatedChatRooms = List<ChatRoom>.from(state.chatRooms);
    updatedChatRooms[roomIndex] = updatedRoom;

    // 按最后活动时间重新排序（最新的在前）
    updatedChatRooms.sort((a, b) {
      final aTime = a.lastActivityTime;
      final bTime = b.lastActivityTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    // 发出新状态
    emit(state.copyWith(chatRooms: updatedChatRooms));
    AppLogger.d('[ChatListBloc] Chat list updated for chatId: ${updateEvent.chatId}');
  }

  // Handler for deleting a chat room
  Future<void> _onDeleteChatRoomRequested(
    DeleteChatRoomRequested event,
    Emitter<ChatListState> emit,
  ) async {
    AppLogger.d('[ChatListBloc] Handling DeleteChatRoomRequested for chatId: ${event.chatId}');

    // 先从本地列表中移除（乐观更新）
    final updatedChatRooms = state.chatRooms.where((room) => room.id != event.chatId).toList();
    emit(state.copyWith(chatRooms: updatedChatRooms));

    // 调用后端API删除
    final result = await deleteChatRoom(DeleteChatRoomParams(chatIds: [event.chatId]));

    result.fold(
      (failure) {
        AppLogger.d('[ChatListBloc] Failed to delete chat room: ${failure.message}');
        // 删除失败，恢复列表并显示错误
        emit(state.copyWith(
          chatRooms: state.chatRooms, // 恢复原列表会触发刷新
          errorMessage: '删除失败: ${failure.message}',
        ));
        // 刷新列表以恢复数据
        add(RefreshChatList());
      },
      (_) {
        AppLogger.d('[ChatListBloc] Successfully deleted chat room: ${event.chatId}');
        // 删除成功，列表已经更新
      },
    );
  }

  @override
  Future<void> close() {
    _chatListUpdateSubscription?.cancel();
    return super.close();
  }
} 
