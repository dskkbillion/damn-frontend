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
  
  // 商品相关字段
  final String? productId;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  
  // participants list can be a getter if needed: get participants => [participant1, participant2];
  // lastActivityTime can be a getter: get lastActivityTime => lastMessage?.createTime;

  const ChatRoom({
    required this.id,
    required this.participant1,
    required this.participant2,
    required this.unreadCount,
    this.lastMessage,
    this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
  });

  @override
  List<Object?> get props => [
        id,
        participant1,
        participant2,
        unreadCount,
        lastMessage,
        productId,
        productName,
        productImage,
        productPrice,
      ];

  // Derived: Get last activity time
  DateTime? get lastActivityTime => lastMessage?.createTime;
  
  // Derived: Check if this chat room is associated with a product
  bool get hasProduct => productId != null && productId!.isNotEmpty;

  ChatRoom copyWith({
    int? id,
    Participant? participant1,
    Participant? participant2,
    int? unreadCount,
    ChatMessage? lastMessage,
    String? productId,
    String? productName,
    String? productImage,
    double? productPrice,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
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