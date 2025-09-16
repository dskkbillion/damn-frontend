import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart'; // Optional: for DI later
import 'package:flutter/foundation.dart'; // Add this for @immutable in part files

// Use package imports to avoid relative path issues
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // For NoParams
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/create_chat_room.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

// @injectable // Optional: for DI later
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRoomList getChatRoomList;
  final CreateChatRoom createChatRoom;
  final EventBus _eventBus = EventBus();
  StreamSubscription<ChatListUpdateEvent>? _chatListUpdateSubscription;

  ChatListBloc({
    required this.getChatRoomList,
    required this.createChatRoom,
  })
      : super(const ChatListState()) {
    on<LoadChatRoomList>(_onLoadChatRoomList);
    on<RefreshChatList>(_onRefreshChatList);
    on<StartAdminChatRequested>(_onStartAdminChatRequested);
    on<ClearNavigationTrigger>(_onClearNavigationTrigger);
    on<UpdateChatRoomUnreadCount>(_onUpdateChatRoomUnreadCount);
    on<UpdateChatRoomLastMessage>(_onUpdateChatRoomLastMessage);

    // 监听聊天列表更新事件
    _chatListUpdateSubscription = _eventBus.chatListUpdateStream.listen((event) {
      print('[ChatListBloc] Received ChatListUpdateEvent for chatId: ${event.chatId}');
      _handleChatListUpdate(event);
    });
  }

  Future<void> _onLoadChatRoomList(
    LoadChatRoomList event,
    Emitter<ChatListState> emit,
  ) async {
    print("[ChatListBloc] Handling LoadChatRoomList event...");
    emit(state.copyWith(status: ChatListStatus.loading));
    
    final failureOrChatRooms = await getChatRoomList(NoParams());

    failureOrChatRooms.fold(
      (failure) {
        print('[ChatListBloc] Failed to load chat rooms: $failure');
        emit(state.copyWith(
            status: ChatListStatus.failure,
            errorMessage: failure.toString())); // Provide a user-friendly message later
      },
      (chatRooms) {
        print('[ChatListBloc] Successfully loaded ${chatRooms.length} chat rooms.');
        emit(state.copyWith(
            status: ChatListStatus.success,
            chatRooms: chatRooms));
      },
    );
  }

  // Handler for the RefreshChatList event
  Future<void> _onRefreshChatList(
    RefreshChatList event,
    Emitter<ChatListState> emit,
  ) async {
    print('[ChatListBloc] Handling RefreshChatList event...');
    // Don't necessarily show loading indicator for a background refresh,
    // unless you want a pull-to-refresh visual later.
    // You could emit a specific status like `refreshing` if needed.
    // emit(state.copyWith(status: ChatListStatus.loading)); // Optional: Show loading

    final failureOrChatRooms = await getChatRoomList(NoParams());

    failureOrChatRooms.fold(
      (failure) {
        print('[ChatListBloc] Failed to refresh chat rooms: $failure');
        // Optionally emit a failure state, or just log it
        // emit(state.copyWith(status: ChatListStatus.failure, errorMessage: failure.toString())); 
      },
      (chatRooms) {
        print('[ChatListBloc] Successfully refreshed ${chatRooms.length} chat rooms.');
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
    print("[ChatListBloc] Handling StartAdminChatRequested event...");
    // Optionally emit a loading state specific to this action if needed
    // emit(state.copyWith(status: ChatListStatus.loading)); 
    
    final result = await createChatRoom(const CreateChatRoomParams(participantId: 0)); // Admin refer_id is 0
    
    result.fold(
      (failure) {
         print("[ChatListBloc] Failed to create/get admin chat room: ${failure.message}");
         // Emit failure state, potentially with a message for the user
         emit(state.copyWith(status: ChatListStatus.failure, errorMessage: "无法连接到系统管理员: ${failure.message}"));
      },
      (chatId) {
        print("[ChatListBloc] Successfully created/retrieved admin chat room ID: $chatId. Triggering navigation.");
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
    print("[ChatListBloc] Clearing navigation trigger.");
    // Emit state with navigateToChatId set to null using the flag
    emit(state.copyWith(clearNavigateToChatId: true)); 
  }

  // Handler to update unread count for a specific chat room
  void _onUpdateChatRoomUnreadCount(
    UpdateChatRoomUnreadCount event,
    Emitter<ChatListState> emit,
  ) {
    print('[ChatListBloc] Updating unread count for chatId ${event.chatId} to ${event.unreadCount}');
    
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
    print('[ChatListBloc] Updating last message for chatId ${event.chatId}');

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

  // 处理聊天列表更新事件
  void _handleChatListUpdate(ChatListUpdateEvent event) {
    print('[ChatListBloc] Processing chat list update for chatId: ${event.chatId}');

    // 查找对应的聊天室
    final roomIndex = state.chatRooms.indexWhere((room) => room.id == event.chatId);

    if (roomIndex == -1) {
      print('[ChatListBloc] Chat room not found in current list, refreshing...');
      // 如果聊天室不在列表中，可能是新创建的，需要刷新列表
      add(RefreshChatList());
      return;
    }

    final room = state.chatRooms[roomIndex];
    var updatedRoom = room;

    // 更新最后消息
    if (event.lastMessage != null) {
      updatedRoom = updatedRoom.copyWith(
        lastMessage: ChatMessage(
          id: '', // 临时ID，因为我们只关心显示内容
          content: event.lastMessage!,
          senderId: '',
          chatId: event.chatId,
          timestamp: event.lastMessageTime ?? DateTime.now(),
          isRead: false,
        ),
      );
    }

    // 更新未读数
    if (event.resetUnread) {
      updatedRoom = updatedRoom.copyWith(unreadCount: 0);
    } else if (event.unreadCountDelta != null) {
      final newUnreadCount = (updatedRoom.unreadCount ?? 0) + event.unreadCountDelta!;
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

    // 触发UI更新
    add(UpdateChatRoomLastMessage(chatId: event.chatId, lastMessage: updatedRoom.lastMessage));
  }

  @override
  Future<void> close() {
    _chatListUpdateSubscription?.cancel();
    return super.close();
  }
} 