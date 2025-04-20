import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart'; // Needed for toEntity
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

@freezed
class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    required int id,
    required int chatId,
    int? doctorId,
    int? memberId,
    required String context,
    required String type,
    String? createTime, // API might return string
    @Default(false) bool withdrawFlag,
    bool? readFlg,
    // Add other fields from API response if necessary (e.g., senderDelFlag, receiverDelFlag)
  }) = _ChatMessageDto;

  // Private constructor for Freezed
  const ChatMessageDto._();

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);

  // Factory constructor to convert from Entity (useful for sending messages if needed)
  factory ChatMessageDto.fromEntity(ChatMessage entity) {
    return ChatMessageDto(
      id: entity.id > 0 ? entity.id : 0, // Use 0 or similar for new messages
      chatId: entity.chatId,
      context: entity.context,
      type: entity.type,
      memberId: entity.memberId, 
      doctorId: entity.doctorId,
      // Fields not typically sent or derived by backend:
      // createTime: entity.createTime.toIso8601String(), // If needed
      withdrawFlag: entity.withdrawFlag,
      // readFlg: entity.readFlg, 
    );
  }

  // Method to convert DTO to Entity
  ChatMessage toEntity({required int currentUserId, required int senderId}) {
     DateTime parsedCreateTime;
     try {
        // Handle potential null or invalid date string from API
        parsedCreateTime = createTime != null ? DateTime.parse(createTime!) : DateTime.now();
     } catch (e) {
        print("Error parsing createTime '$createTime': $e");
        parsedCreateTime = DateTime.now(); // Fallback to now
     }

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId, // Determined externally
      memberId: memberId,
      doctorId: doctorId,
      context: context,
      type: withdrawFlag ? 'revoke' : type, // Handle revoked messages
      createTime: parsedCreateTime,
      withdrawFlag: withdrawFlag,
      readFlg: readFlg,
      status: MessageStatus.sent, // Assume sent if received from API/WS
    );
  }
} 