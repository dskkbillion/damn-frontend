part of 'chat_list_bloc.dart';

// NO IMPORTS HERE

enum ChatListStatus { initial, loading, success, failure }

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatRoom> chatRooms;
  final String? errorMessage;
  // Add field to trigger navigation
  final int? navigateToChatId; 

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chatRooms = const <ChatRoom>[],
    this.errorMessage,
    this.navigateToChatId, // Initialize
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatRoom>? chatRooms,
    String? errorMessage,
    int? navigateToChatId,
    bool clearNavigateToChatId = false, // Flag to clear navigation trigger
  }) {
    return ChatListState(
      status: status ?? this.status,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage ?? this.errorMessage,
      // If clearNavigateToChatId is true, set to null, otherwise update or keep existing
      navigateToChatId: clearNavigateToChatId ? null : (navigateToChatId ?? this.navigateToChatId),
    );
  }

  @override
  List<Object?> get props => [status, chatRooms, errorMessage, navigateToChatId];
} 