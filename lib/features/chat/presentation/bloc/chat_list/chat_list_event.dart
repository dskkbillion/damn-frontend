part of 'chat_list_bloc.dart';

// Imports must be in the main library file (chat_list_bloc.dart)

@immutable
abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger loading the chat room list.
class LoadChatRoomList extends ChatListEvent {}

// Event to refresh the chat room list (e.g., after returning from a chat)
class RefreshChatList extends ChatListEvent {}

// Event to initiate creating/getting chat room with admin
class StartAdminChatRequested extends ChatListEvent {}

// Event to clear the navigation trigger after navigation has occurred
class ClearNavigationTrigger extends ChatListEvent {}

/// Event to update the unread count for a specific chat room
class UpdateChatRoomUnreadCount extends ChatListEvent {
  final int chatId;
  final int unreadCount;

  const UpdateChatRoomUnreadCount({
    required this.chatId, 
    required this.unreadCount
  });

  @override
  List<Object?> get props => [chatId, unreadCount];
}

/// Event to update the last message for a specific chat room (e.g., after message revoked)
class UpdateChatRoomLastMessage extends ChatListEvent {
  final int chatId;
  final ChatMessage? lastMessage;

  const UpdateChatRoomLastMessage({
    required this.chatId, 
    this.lastMessage
  });

  @override
  List<Object?> get props => [chatId, lastMessage];
}

/// 内部事件：处理来自 EventBus 的聊天列表更新
class _HandleChatListUpdate extends ChatListEvent {
  final ChatListUpdateEvent updateEvent;

  const _HandleChatListUpdate(this.updateEvent);

  @override
  List<Object?> get props => [
    updateEvent.chatId,
    updateEvent.lastMessage,
    updateEvent.lastMessageTime,
    updateEvent.unreadCountDelta,
    updateEvent.resetUnread,
  ];
}

/// Event to delete a chat room
class DeleteChatRoomRequested extends ChatListEvent {
  final int chatId;

  const DeleteChatRoomRequested({required this.chatId});

  @override
  List<Object?> get props => [chatId];
} 