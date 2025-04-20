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
} 