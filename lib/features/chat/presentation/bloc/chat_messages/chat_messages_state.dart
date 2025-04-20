part of 'chat_messages_bloc.dart';

@immutable
abstract class ChatMessagesState extends Equatable {
  const ChatMessagesState();

  @override
  List<Object?> get props => [];
}

class ChatMessagesInitial extends ChatMessagesState {
  const ChatMessagesInitial();
}

class ChatMessagesLoading extends ChatMessagesState {
  const ChatMessagesLoading();
}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<ChatMessage> messages;
  final Participant opponent; // Assuming opponent info is fetched
  final int currentUserId; // Need current user ID to determine message alignment
  final String? error; // Optional error message

  const ChatMessagesLoaded({
    required this.messages,
    required this.opponent,
    required this.currentUserId,
    this.error,
  });

  @override
  List<Object?> get props => [messages, opponent, currentUserId, error];

  ChatMessagesLoaded copyWith({
    List<ChatMessage>? messages,
    Participant? opponent,
    int? currentUserId,
    String? error,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      opponent: opponent ?? this.opponent,
      currentUserId: currentUserId ?? this.currentUserId,
      error: error,
    );
  }
}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
} 