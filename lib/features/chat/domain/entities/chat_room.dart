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
  // FIX: Compare using referId, not internal id
  Participant getOpponent(int currentUserReferId) {
    // Ensure participant1 and participant2 are non-null before accessing referId
    // Although the constructor requires them, adding checks for safety.
    if (participant1.referId == currentUserReferId) {
       return participant2;
    }
    if (participant2.referId == currentUserReferId) {
       return participant1;
    }
    // This case should ideally not happen if the ChatRoom entity is constructed correctly
    // based on a valid DTO and the current user is indeed a participant.
    // Returning participant1 as a fallback, but consider logging an error.
    print("Warning: Could not determine opponent in getOpponent. currentUserReferId: $currentUserReferId, p1.referId: ${participant1.referId}, p2.referId: ${participant2.referId}");
    return participant1; // Fallback, might be wrong
  }
} 