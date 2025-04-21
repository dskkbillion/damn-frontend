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
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

@injectable // Optional: for DI later
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatRoomList _getChatRoomList;

  ChatListBloc({required GetChatRoomList getChatRoomList}) 
      : _getChatRoomList = getChatRoomList,
        super(const ChatListState()) {
    on<LoadChatRoomList>(_onLoadChatRoomList);
    // Register the handler for the refresh event
    on<RefreshChatList>(_onRefreshChatList); 
  }

  Future<void> _onLoadChatRoomList(
    LoadChatRoomList event,
    Emitter<ChatListState> emit,
  ) async {
    print('[ChatListBloc] Handling LoadChatRoomList event...');
    emit(state.copyWith(status: ChatListStatus.loading));
    
    final failureOrChatRooms = await _getChatRoomList(NoParams());

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

    final failureOrChatRooms = await _getChatRoomList(NoParams());

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
} 