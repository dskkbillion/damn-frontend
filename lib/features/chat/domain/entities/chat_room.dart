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

  // 原始角色ID - 用于准确判断身份
  final int? doctorId; // 卖家ID
  final int? memberId; // 买家ID
  
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
    this.doctorId,
    this.memberId,
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
        doctorId,
        memberId,
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
    int? doctorId,
    int? memberId,
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
      doctorId: doctorId ?? this.doctorId,
      memberId: memberId ?? this.memberId,
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
  
  // Helper getter for participants list
  List<Participant> get participants => [participant1, participant2];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1': _participantToJson(participant1),
      'participant2': _participantToJson(participant2),
      'unreadCount': unreadCount,
      'lastMessage': lastMessage?.toJson(),
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
    };
  }
  
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as int,
      participant1: _participantFromJson(json['participant1']),
      participant2: _participantFromJson(json['participant2']),
      unreadCount: json['unreadCount'] as int,
      lastMessage: json['lastMessage'] != null 
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      productImage: json['productImage'] as String?,
      productPrice: (json['productPrice'] as num?)?.toDouble(),
    );
  }
  
  static Map<String, dynamic> _participantToJson(Participant participant) {
    return {
      'id': participant.id,
      'nickName': participant.nickName,
      'avatar': participant.avatar,
      'type': participant.type,
      'referId': participant.referId,
    };
  }
  
  static Participant _participantFromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as int,
      nickName: json['nickName'] as String?,
      avatar: json['avatar'] as String?,
      type: json['type'] as String?,
      referId: json['referId'] as int?,
    );
  }
} 