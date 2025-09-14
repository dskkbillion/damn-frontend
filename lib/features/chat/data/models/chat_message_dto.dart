import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart'; // Needed for toEntity
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

@freezed
class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    int? id, // Make id optional for WebSocket messages
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
      id: entity.id > 0 ? entity.id : null, // Use null for new messages
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
          // 处理API返回的时间格式："2025-08-21 02:14:02"
          // 服务器返回的是北京时间（UTC+8），需要转换为本地时间
          String isoTimeString = createTime!;
          if (createTime!.contains(' ') && !createTime!.contains('T')) {
            isoTimeString = createTime!.replaceFirst(' ', 'T');
          }
          
          // 服务器时间是北京时间（UTC+8）
          // 1. 先解析为DateTime（会被当作本地时区）
          final serverTime = DateTime.parse(isoTimeString);
          
          // 2. 创建一个UTC时间（假设服务器时间是UTC+8）
          // 北京时间减去8小时得到UTC时间
          final utcTime = serverTime.subtract(const Duration(hours: 8));
          
          // 3. 转换为本地时间
          parsedCreateTime = DateTime.utc(
            utcTime.year,
            utcTime.month,
            utcTime.day,
            utcTime.hour,
            utcTime.minute,
            utcTime.second,
            utcTime.millisecond,
            utcTime.microsecond,
          ).toLocal();
          
          print("[ChatMessageDto] Server time (Beijing): $createTime -> Local time: $parsedCreateTime");
        } else {
          print("[ChatMessageDto] createTime is null or empty, using current time");
          parsedCreateTime = DateTime.now();
        }
     } catch (e) {
        print("[ChatMessageDto] Error parsing createTime '$createTime': $e, using current time");
        parsedCreateTime = DateTime.now(); // Fallback to now
     }

    // 添加调试信息
    print("[ChatMessageDto] 转换消息 - ID: $id, memberId: $memberId, doctorId: $doctorId, senderId传入值: $senderId");
    print("[ChatMessageDto] withdrawFlag: $withdrawFlag, type: $type, context: '$context'");
    
    return ChatMessage(
      id: id ?? DateTime.now().millisecondsSinceEpoch, // Generate temporary ID if null
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