import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart'; // Assuming Failure is in core
import '../constants/chat_constants.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';

/// Abstract interface for chat data operations.
abstract class IChatRepository {
  /// Retrieves the list of chat rooms for the current user.
  Future<Either<Failure, List<ChatRoom>>> getChatRooms();

  /// Fetches the list of messages for a specific chat room.
  /// Implementations should handle marking messages as read implicitly.
  Future<Either<Failure, List<ChatMessage>>> getMessages(int chatId, {int pageNum = 1, int pageSize = ChatConstants.defaultPageSize});

  /// Fetches details for a specific chat room.
  Future<Either<Failure, ChatRoom>> getRoomDetails(int chatId);

  /// Sends a message.
  /// The input [ChatMessage] should contain necessary info like [chatId], [context], [type].
  /// The backend might assign the final [id] and [createTime].
  /// Returns the sent message with updated info from the backend.
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message);

  /// Creates a new chat room with the given participant.
  /// Returns the ID of the newly created chat room.
  /// [productId] is optional for product-specific conversations.
  Future<Either<Failure, int>> createRoom(
    int participantId, {
    int? productId, // 新增可选的商品ID参数
  });

  /// Revokes a message by its ID.
  Future<Either<Failure, void>> revokeMessage(int messageId);

  /// Deletes specified messages for the current user within a chat room.
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId);

  /// Deletes specified chat rooms.
  Future<Either<Failure, void>> deleteChatRooms(List<int> chatIds);
} 