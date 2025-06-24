import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_room_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';

abstract class IChatRemoteDataSource {
  Future<List<ChatRoomDto>> getChatRooms();
  Future<List<ChatMessageDto>> getMessages(int chatId, {int pageNum = 1, int pageSize = 20});
  Future<ChatMessageDto> sendMessage(ChatMessage message); // Send Entity, receive DTO
  Future<ChatRoomDto> getRoomDetails(int chatId);
  Future<int> createRoom(
    int participantId, {
    int? productId, // 新增可选的商品ID参数
  });
  Future<void> revokeMessage(int messageId);
  Future<void> deleteChatMessages(List<int> messageIds, int chatId); // Match repository method
} 