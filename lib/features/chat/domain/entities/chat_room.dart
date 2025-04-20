import 'package:equatable/equatable.dart';

import 'chat_message.dart';
import 'participant.dart';

/// Represents a chat room/conversation.
class ChatRoom extends Equatable {
  final int id;
  final Participant participant1;
  final Participant participant2; // Use specific participants for clarity
  final int unreadCount;
  final ChatMessage? lastMessage;
  // participants list can be a getter if needed: get participants => [participant1, participant2];
  // lastActivityTime can be a getter: get lastActivityTime => lastMessage?.createTime;

  const ChatRoom({
    required this.id,
    required this.participant1,
    required this.participant2,
    required this.unreadCount,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [
        id,
        participant1,
        participant2,
        unreadCount,
        lastMessage,
      ];

  // Derived: Get last activity time
  DateTime? get lastActivityTime => lastMessage?.createTime;

  ChatRoom copyWith({
    int? id,
    Participant? participant1,
    Participant? participant2,
    int? unreadCount,
    ChatMessage? lastMessage,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  // Derived: Get the opponent participant (assuming one is the current user)
  Participant getOpponent(int currentUserId) {
    return participant1.id == currentUserId ? participant2 : participant1;
  }
} 