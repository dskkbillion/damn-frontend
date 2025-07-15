import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart'; // Optional: for DI later
import 'package:flutter/foundation.dart'; // Add this for @immutable in part files

// Use package imports to avoid relative path issues
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // For NoParams
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
        return room.copyWith(lastMessage: event.lastMessage);
      }
      return room;
    }).toList();
    
    emit(state.copyWith(chatRooms: updatedChatRooms));
  }
} 