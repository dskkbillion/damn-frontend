import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/participant_dto.dart';
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
    // Add other fields from API response if necessary
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
         lastActivity = DateTime.parse(chatMessageNewVo!.createTime!);
       } catch (e) {
         print("Error parsing last activity time: ${chatMessageNewVo!.createTime}");
         lastActivity = null; // Fallback
       }
     }
    return ChatRoom(
      id: id,
      participant1: member.toEntity(),
      participant2: doctor.toEntity(),
      unreadCount: messageNum,
      lastMessage: chatMessageNewVo?.toEntity(
         currentUserId: currentUserId,
         senderId: chatMessageNewVo!.memberId == currentUserId ? chatMessageNewVo!.memberId! :
                   chatMessageNewVo!.doctorId == currentUserId ? chatMessageNewVo!.doctorId! :
                   (chatMessageNewVo!.memberId ?? chatMessageNewVo!.doctorId ?? 0)
      ),
    );
  }
} 