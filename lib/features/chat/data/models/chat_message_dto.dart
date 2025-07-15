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
        if (createTime != null && createTime!.isNotEmpty) {
          // 处理API返回的时间格式："2025-05-14 09:49:46"
          // 将空格替换为T，使其符合ISO 8601格式
          String isoTimeString = createTime!;
          if (createTime!.contains(' ') && !createTime!.contains('T')) {
            isoTimeString = createTime!.replaceFirst(' ', 'T');
          }
          parsedCreateTime = DateTime.parse(isoTimeString);
          print("[ChatMessageDto] Successfully parsed createTime: $createTime -> $parsedCreateTime");
        } else {
          print("[ChatMessageDto] createTime is null or empty, using current time");
          parsedCreateTime = DateTime.now();
        }
     } catch (e) {
        print("[ChatMessageDto] Error parsing createTime '$createTime': $e, using current time");
        parsedCreateTime = DateTime.now(); // Fallback to now
     }

    // 添加调试信息
    print("[ChatMessageDto] 转换消息 - ID: $id, withdrawFlag: $withdrawFlag, type: $type, context: '$context'");
    
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      memberId: memberId,
      doctorId: doctorId,
      context: context, // 保持原始内容，不做显示处理
      type: type, // 保持原始类型
      createTime: parsedCreateTime,
      withdrawFlag: withdrawFlag,
      readFlg: readFlg,
      status: MessageStatus.sent, // Assume sent if received from API/WS
    );
  }
} 