import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/participant_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/product_vo_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
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
         // AppLogger.d("[ChatRoomDto] Successfully parsed lastActivity: ${chatMessageNewVo!.createTime} -> $lastActivity");
       } catch (e) {
         AppLogger.d("[ChatRoomDto] Error parsing last activity time: ${chatMessageNewVo!.createTime}, error: $e");
         lastActivity = null; // Fallback
       }
     }

    // memberId = 发送者的 CommonUser.id（后端保证非空）
    int? lastMessageSenderId;
    if (chatMessageNewVo != null) {
        if (chatMessageNewVo!.memberId == null) {
          throw Exception(
            "lastMessage in room $id has no memberId, violating backend contract. "
            "doctorId: ${chatMessageNewVo!.doctorId}",
          );
        }
        lastMessageSenderId = chatMessageNewVo!.memberId!;
    }

    // 转换DTO为实体
    final memberEntity = member.toEntity();
    final doctorEntity = doctor.toEntity();

    Participant currentUserParticipant;
    Participant opponentParticipant;

    // ID 契约（后端保证）：
    // - participant.id = CommonUser.id = commonUserId（前端 SecureStorage 中存储的值）
    // - participant.referId = Member.id（原始用户表主键，聊天模块不使用）
    // - 匹配当前用户只需比较 participant.id == currentUserId
    // - 无 fallback 分支，匹配失败直接抛异常暴露问题
    if (memberEntity.id == currentUserId) {
      currentUserParticipant = memberEntity;
      opponentParticipant = doctorEntity;
    } else if (doctorEntity.id == currentUserId) {
      currentUserParticipant = doctorEntity;
      opponentParticipant = memberEntity;
    } else {
      throw Exception(
        "Cannot determine current user in chat room $id. "
        "currentUserId(commonUserId): $currentUserId, "
        "member.id: ${memberEntity.id}, doctor.id: ${doctorEntity.id}",
      );
    }

    return ChatRoom(
      id: id,
      // participant1 总是当前用户，participant2 总是对方
      participant1: currentUserParticipant,
      participant2: opponentParticipant,
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
      // 传递原始的角色ID，用于准确判断身份
      doctorId: doctor.id,  // 卖家的participant ID
      memberId: member.id,  // 买家的participant ID
    );
  }
} 