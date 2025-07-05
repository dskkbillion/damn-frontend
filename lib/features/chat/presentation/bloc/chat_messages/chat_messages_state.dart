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
  final int currentUserParticipantId; // FIX: Add current user's Participant ID
  final String? error; // Optional error message
  final bool isInitialLoad; // 标记是否是初始加载
  final bool hasNewMessage; // 标记是否有新消息
  final bool hasMore; // 标记是否有更多历史消息可加载
  final bool hasMessageRevoked; // 标记是否有消息被撤回
  final bool hasMessageSent; // 标记是否有消息发送成功

  const ChatMessagesLoaded({
    required this.messages,
    required this.opponent,
    required this.currentUserId,
    required this.currentUserParticipantId,
    this.error,
    this.isInitialLoad = true,
    this.hasNewMessage = false,
    this.hasMore = true,
    this.hasMessageRevoked = false,
    this.hasMessageSent = false,
  });

  @override
  List<Object?> get props => [messages, opponent, currentUserId, currentUserParticipantId, error, isInitialLoad, hasNewMessage, hasMore, hasMessageRevoked, hasMessageSent];

  ChatMessagesLoaded copyWith({
    List<ChatMessage>? messages,
    Participant? opponent,
    int? currentUserId,
    int? currentUserParticipantId,
    ValueGetter<String?>? error,
    bool? isInitialLoad,
    bool? hasNewMessage,
    bool? hasMore,
    bool? hasMessageRevoked,
    bool? hasMessageSent,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      opponent: opponent ?? this.opponent,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserParticipantId: currentUserParticipantId ?? this.currentUserParticipantId,
      error: error != null ? error() : this.error,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      hasNewMessage: hasNewMessage ?? this.hasNewMessage,
      hasMore: hasMore ?? this.hasMore,
      hasMessageRevoked: hasMessageRevoked ?? this.hasMessageRevoked,
      hasMessageSent: hasMessageSent ?? this.hasMessageSent,
    );
  }
}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  const ChatMessagesError(this.message);

  @override
  List<Object?> get props => [message];
} 