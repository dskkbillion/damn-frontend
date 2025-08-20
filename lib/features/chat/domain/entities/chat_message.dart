import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, failed, read } // Added read status if needed

// Minimal message for display purposes
class ChatMessage extends Equatable {
  final int id;
  final int chatId;
  final int senderId; // ID of the actual sender (either memberId or doctorId)
  final int? memberId; // Original member ID from API
  final int? doctorId; // Original doctor ID from API
  final String context;
  final String type; // 'text', 'image', 'audio', 'revoke', etc.
  final DateTime createTime;
  final bool withdrawFlag;
  final bool? readFlg; // From API
  final MessageStatus status; // Frontend status

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.memberId,
    this.doctorId,
    required this.context,
    required this.type,
    required this.createTime,
    required this.withdrawFlag,
    this.readFlg,
    this.status = MessageStatus.sent, // Default to sent if coming from API
  });

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        memberId,
        doctorId,
        context,
        type,
        createTime,
        withdrawFlag,
        readFlg,
        status,
      ];

  ChatMessage copyWith({
    int? id,
    int? chatId,
    int? senderId,
    int? memberId,
    int? doctorId,
    String? context,
    String? type,
    DateTime? createTime,
    bool? withdrawFlag,
    bool? readFlg,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      memberId: memberId ?? this.memberId,
      doctorId: doctorId ?? this.doctorId,
      context: context ?? this.context,
      type: type ?? this.type,
      createTime: createTime ?? this.createTime,
      withdrawFlag: withdrawFlag ?? this.withdrawFlag,
      readFlg: readFlg ?? this.readFlg,
      status: status ?? this.status,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'memberId': memberId,
      'doctorId': doctorId,
      'context': context,
      'type': type,
      'createTime': createTime.toIso8601String(),
      'withdrawFlag': withdrawFlag,
      'readFlg': readFlg,
      'status': status.toString().split('.').last,
    };
  }
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      senderId: json['senderId'] as int,
      memberId: json['memberId'] as int?,
      doctorId: json['doctorId'] as int?,
      context: json['context'] as String,
      type: json['type'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      withdrawFlag: json['withdrawFlag'] as bool,
      readFlg: json['readFlg'] as bool?,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }
} 