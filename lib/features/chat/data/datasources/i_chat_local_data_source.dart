import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';

/// Interface for local chat data source (caching)
abstract class IChatLocalDataSource {
  /// Cache chat messages
  Future<void> cacheMessages(int chatId, List<ChatMessage> messages);
  
  /// Get cached messages
  Future<List<ChatMessage>?> getCachedMessages(int chatId);
  
  /// Clear cached messages for a chat
  Future<void> clearCachedMessages(int chatId);
  
  /// Cache chat room details
  Future<void> cacheChatRoom(ChatRoom chatRoom);
  
  /// Get cached chat room
  Future<ChatRoom?> getCachedChatRoom(int chatId);
  
  /// Clear all cache
  Future<void> clearAllCache();
  
  /// Get last message ID for pagination
  Future<int?> getLastMessageId(int chatId);
  
  /// Update message status locally
  Future<void> updateMessageStatus(int messageId, MessageStatus status);
  
  /// Mark messages as read
  Future<void> markMessagesAsRead(int chatId, List<int> messageIds);
}