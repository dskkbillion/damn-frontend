import 'dart:convert';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_local_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';

/// Implementation of local chat data source using SharedPreferences
class ChatLocalDataSourceImpl implements IChatLocalDataSource {
  final SharedPreferences _prefs;
  
  static const String _messagesPrefix = 'chat_messages_';
  static const String _chatRoomPrefix = 'chat_room_';
  static const String _lastMessageIdPrefix = 'last_message_id_';
  static const String _paymentPromptPrefix = 'payment_prompt_sent_';
  static const String _paymentPromptCountPrefix = 'payment_prompt_count_';
  static const String _chatRoomListKey = 'chat_room_list';

  // In-memory cache for fast access (avoids JSON round-trip on repeated reads)
  static List<ChatRoom>? _cachedRoomList;
  
  ChatLocalDataSourceImpl({
    required SharedPreferences prefs,
  }) : _prefs = prefs;
  
  @override
  Future<void> cacheMessages(int chatId, List<ChatMessage> messages) async {
    try {
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await _prefs.setString(
        '$_messagesPrefix$chatId',
        jsonEncode(messagesJson),
      );
      
      // Also cache the last message ID for pagination
      if (messages.isNotEmpty) {
        final lastId = messages.map((m) => m.id).reduce((a, b) => a > b ? a : b);
        await _prefs.setInt('$_lastMessageIdPrefix$chatId', lastId);
      }
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error caching messages: $e');
    }
  }
  
  @override
  Future<List<ChatMessage>?> getCachedMessages(int chatId) async {
    try {
      final cachedData = _prefs.getString('$_messagesPrefix$chatId');
      if (cachedData == null) return null;
      
      final List<dynamic> messagesJson = jsonDecode(cachedData);
      return messagesJson
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error getting cached messages: $e');
      return null;
    }
  }
  
  @override
  Future<void> clearCachedMessages(int chatId) async {
    await _prefs.remove('$_messagesPrefix$chatId');
    await _prefs.remove('$_lastMessageIdPrefix$chatId');
  }
  
  @override
  Future<void> cacheChatRoom(ChatRoom chatRoom) async {
    try {
      await _prefs.setString(
        '$_chatRoomPrefix${chatRoom.id}',
        jsonEncode(chatRoom.toJson()),
      );
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error caching chat room: $e');
    }
  }
  
  @override
  Future<ChatRoom?> getCachedChatRoom(int chatId) async {
    try {
      final cachedData = _prefs.getString('$_chatRoomPrefix$chatId');
      if (cachedData == null) return null;
      
      final Map<String, dynamic> roomJson = jsonDecode(cachedData);
      return ChatRoom.fromJson(roomJson);
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error getting cached chat room: $e');
      return null;
    }
  }
  
  @override
  Future<void> cacheChatRoomList(List<ChatRoom> rooms) async {
    try {
      _cachedRoomList = rooms;
      final roomsJson = rooms.map((r) => r.toJson()).toList();
      await _prefs.setString(_chatRoomListKey, jsonEncode(roomsJson));
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error caching chat room list: $e');
    }
  }

  @override
  Future<List<ChatRoom>?> getCachedChatRoomList() async {
    // Return in-memory cache if available
    if (_cachedRoomList != null) return _cachedRoomList;
    try {
      final cachedData = _prefs.getString(_chatRoomListKey);
      if (cachedData == null) return null;
      final List<dynamic> roomsJson = jsonDecode(cachedData);
      _cachedRoomList = roomsJson
          .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
          .toList();
      return _cachedRoomList;
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error getting cached chat room list: $e');
      return null;
    }
  }

  @override
  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_messagesPrefix) || 
          key.startsWith(_chatRoomPrefix) ||
          key.startsWith(_lastMessageIdPrefix)) {
        await _prefs.remove(key);
      }
    }
  }
  
  @override
  Future<int?> getLastMessageId(int chatId) async {
    return _prefs.getInt('$_lastMessageIdPrefix$chatId');
  }
  
  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    // This would require maintaining a separate index of message IDs to chat IDs
    // For simplicity, we'll need to iterate through all cached chats
    // In a production app, you'd want a more efficient solution
    
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_messagesPrefix)) {
        final cachedData = _prefs.getString(key);
        if (cachedData != null) {
          try {
            final List<dynamic> messagesJson = jsonDecode(cachedData);
            var updated = false;
            
            for (var i = 0; i < messagesJson.length; i++) {
              if (messagesJson[i]['id'] == messageId) {
                messagesJson[i]['status'] = status.name;
                updated = true;
                break;
              }
            }
            
            if (updated) {
              await _prefs.setString(key, jsonEncode(messagesJson));
              break;
            }
          } catch (e) {
            AppLogger.d('[ChatLocalDataSource] Error updating message status: $e');
          }
        }
      }
    }
  }
  
  @override
  Future<void> markMessagesAsRead(int chatId, List<int> messageIds) async {
    try {
      final cachedData = _prefs.getString('$_messagesPrefix$chatId');
      if (cachedData == null) return;
      
      final List<dynamic> messagesJson = jsonDecode(cachedData);
      var updated = false;
      
      for (var i = 0; i < messagesJson.length; i++) {
        if (messageIds.contains(messagesJson[i]['id'])) {
          messagesJson[i]['readFlg'] = true;
          messagesJson[i]['status'] = MessageStatus.read.name;
          updated = true;
        }
      }
      
      if (updated) {
        await _prefs.setString('$_messagesPrefix$chatId', jsonEncode(messagesJson));
      }
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error marking messages as read: $e');
    }
  }
  
  @override
  Future<void> savePaymentPromptStatus(int chatId, bool sent) async {
    try {
      await _prefs.setBool('$_paymentPromptPrefix$chatId', sent);
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error saving payment prompt status: $e');
    }
  }
  
  @override
  Future<bool> getPaymentPromptStatus(int chatId) async {
    try {
      return _prefs.getBool('$_paymentPromptPrefix$chatId') ?? false;
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error getting payment prompt status: $e');
      return false;
    }
  }
  
  @override
  Future<int> getPaymentPromptCount(int chatId) async {
    try {
      // Try to get count first
      final count = _prefs.getInt('$_paymentPromptCountPrefix$chatId');
      if (count != null) {
        return count;
      }
      
      // Fallback: migrate from old bool value
      final oldStatus = await getPaymentPromptStatus(chatId);
      if (oldStatus) {
        // If old status was true (sent), set count to 1
        await savePaymentPromptCount(chatId, 1);
        return 1;
      }
      
      return 0;
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error getting payment prompt count: $e');
      return 0;
    }
  }
  
  @override
  Future<void> savePaymentPromptCount(int chatId, int count) async {
    try {
      await _prefs.setInt('$_paymentPromptCountPrefix$chatId', count);
      
      // Also update old status for backward compatibility
      if (count > 0) {
        await savePaymentPromptStatus(chatId, true);
      }
    } catch (e) {
      AppLogger.d('[ChatLocalDataSource] Error saving payment prompt count: $e');
    }
  }
}