import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
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

    // 转换DTO为实体
    final memberEntity = member.toEntity();
    final doctorEntity = doctor.toEntity();
    
    Participant currentUserParticipant;
    Participant opponentParticipant;
    
    // 根据API数据结构：member是买家，doctor是卖家
    // 确保participant1总是当前用户，participant2总是对方
    // 首先尝试使用id进行匹配（participant内部ID）
    if (memberEntity.id == currentUserId) {
      // 当前用户是买家(member)
      currentUserParticipant = memberEntity;
      opponentParticipant = doctorEntity; // 对方是卖家(doctor)
      print("[ChatRoomDto] Current user (by id) is MEMBER (buyer), opponent is DOCTOR (seller): ${doctorEntity.nickName}");
    } else if (doctorEntity.id == currentUserId) {
      // 当前用户是卖家(doctor)
      currentUserParticipant = doctorEntity;
      opponentParticipant = memberEntity; // 对方是买家(member)
      print("[ChatRoomDto] Current user (by id) is DOCTOR (seller), opponent is MEMBER (buyer): ${memberEntity.nickName}");
    } else if (memberEntity.referId == currentUserId) {
      // 尝试使用referId进行匹配（外部引用ID）
      currentUserParticipant = memberEntity;
      opponentParticipant = doctorEntity;
      print("[ChatRoomDto] Current user (by referId) is MEMBER (buyer), opponent is DOCTOR (seller): ${doctorEntity.nickName}");
    } else if (doctorEntity.referId == currentUserId) {
      currentUserParticipant = doctorEntity;
      opponentParticipant = memberEntity;
      print("[ChatRoomDto] Current user (by referId) is DOCTOR (seller), opponent is MEMBER (buyer): ${memberEntity.nickName}");
    } else {
      // 无法确定当前用户身份，这是一个严重错误
      print("[ChatRoomDto] ERROR: Cannot determine current user identity!");
      print("[ChatRoomDto] currentUserId: $currentUserId");
      print("[ChatRoomDto] member.id: ${memberEntity.id}, member.referId: ${memberEntity.referId}");
      print("[ChatRoomDto] doctor.id: ${doctorEntity.id}, doctor.referId: ${doctorEntity.referId}");
      // 抛出异常，让问题暴露出来而不是隐藏
      throw Exception("Cannot determine current user identity in chat room $id. CurrentUserId: $currentUserId doesn't match any participant.");
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
    );
  }
} 