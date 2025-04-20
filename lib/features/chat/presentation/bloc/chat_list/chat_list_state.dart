part of 'chat_list_bloc.dart';

// NO IMPORTS HERE

enum ChatListStatus { initial, loading, success, failure }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatRoom> chatRooms;
  final String? errorMessage;
  // Add currentUserId later if needed by ChatListItem for rendering logic
  // final int? currentUserId; 

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chatRooms = const <ChatRoom>[],
    this.errorMessage,
    // this.currentUserId,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatRoom>? chatRooms,
    String? errorMessage,
    // int? currentUserId,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage ?? this.errorMessage,
      // currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props => [status, chatRooms, errorMessage]; // Add currentUserId if used
} 