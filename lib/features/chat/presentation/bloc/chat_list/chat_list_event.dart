part of 'chat_list_bloc.dart';

// NO IMPORTS HERE

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger loading the chat room list.
class LoadChatRoomList extends ChatListEvent {}

// Add other events like UpdateChatRoomListWithNewMessage later 