import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/participant_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/product_vo_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_dto.freezed.dart';
part 'chat_room_dto.g.dart';

@freezed
class ChatRoomDto with _$ChatRoomDto {
  const factory ChatRoomDto({
    required int id,
    required ParticipantDto member,
    required ParticipantDto doctor,
    @Default(0) int messageNum, // Unread count
    ChatMessageDto? chatMessageNewVo, // Latest message DTO
    // 新增商品相关字段
    int? productId,
    ProductVoDto? productVo,
  }) = _ChatRoomDto;

  // Private constructor for Freezed
  const ChatRoomDto._();

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomDtoFromJson(json);

  // Method to convert DTO to Entity
  ChatRoom toEntity({required int currentUserId}) {
     DateTime? lastActivity;
     if (chatMessageNewVo?.createTime != null) {
       try {
         // 处理API返回的时间格式："2025-05-14 09:49:46"
         // 将空格替换为T，使其符合ISO 8601格式
         String timeString = chatMessageNewVo!.createTime!;
         if (timeString.contains(' ') && !timeString.contains('T')) {
           timeString = timeString.replaceFirst(' ', 'T');
         }
         lastActivity = DateTime.parse(timeString);
         print("[ChatRoomDto] Successfully parsed lastActivity: ${chatMessageNewVo!.createTime} -> $lastActivity");
       } catch (e) {
         print("[ChatRoomDto] Error parsing last activity time: ${chatMessageNewVo!.createTime}, error: $e");
         lastActivity = null; // Fallback
       }
     }

    // FIX: Determine sender participant ID for the last message before calling its toEntity
    int? lastMessageSenderId;
    if (chatMessageNewVo != null) {
        lastMessageSenderId = chatMessageNewVo!.memberId ?? chatMessageNewVo!.doctorId ?? 0;
    }

    return ChatRoom(
      id: id,
      participant1: member.toEntity(),
      participant2: doctor.toEntity(),
      unreadCount: messageNum,
      lastMessage: chatMessageNewVo?.toEntity(
         currentUserId: currentUserId, // Pass commonUserId
         // FIX: Pass the determined sender participant ID (if message exists)
         senderId: lastMessageSenderId ?? 0 // Use 0 or handle null appropriately
      ),
      // 添加商品相关字段映射
      productId: productId?.toString(), // 将int转换为String
      productName: productVo?.name,
      productImage: productVo?.mainImage,
      productPrice: productVo?.sellingPrice,
    );
  }
} 