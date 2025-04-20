import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart'; // Optional: for DI later

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
    // Register handlers for other events later
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
} 