part of 'chat_list_bloc.dart';

// Imports must be in the main library file (chat_list_bloc.dart)

@immutable
abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger loading the chat room list.
class LoadChatRoomList extends ChatListEvent {}

// Event to refresh the chat room list (e.g., after returning from a chat)
class RefreshChatList extends ChatListEvent {}

// Event to initiate creating/getting chat room with admin
class StartAdminChatRequested extends ChatListEvent {}

// Event to clear the navigation trigger after navigation has occurred
class ClearNavigationTrigger extends ChatListEvent {}

// Add other events like UpdateChatRoomListWithNewMessage later 