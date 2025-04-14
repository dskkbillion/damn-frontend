import 'package:hive/hive.dart';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/i_chat_local_cache.dart';
import '../models/hive/chat_session_hive_model.dart'; // 需要创建 Hive Model
import '../models/hive/message_hive_model.dart'; // 需要创建 Hive Model

/// 本地缓存实现 (使用 Hive)
class ChatLocalCacheImpl implements IChatLocalCache {
  // Define Box names
  static const String _sessionBoxName = 'chat_sessions';
  static const String _messageBoxPrefix = 'chat_messages_'; // Prefix for message boxes per chat

  // Helper to get the specific message box for a chat ID
  Future<Box<Message>> _getMessageBox(int chatId) async {
     final boxName = '$_messageBoxPrefix$chatId';
     if (Hive.isBoxOpen(boxName)) {
        return Hive.box<Message>(boxName);
     } else {
        return await Hive.openBox<Message>(boxName);
     }
  }

  Future<Box<ChatSession>> _getSessionBox() async {
     if (Hive.isBoxOpen(_sessionBoxName)) {
        return Hive.box<ChatSession>(_sessionBoxName);
     } else {
        return await Hive.openBox<ChatSession>(_sessionBoxName);
     }
  }

  @override
  Future<void> saveChatSessions(List<ChatSession> sessions) async {
    try {
      final box = await _getSessionBox();
      // Clear existing sessions and add new ones (full refresh)
      // Use a map for efficient lookup and update
      final sessionMap = { for (var s in sessions) s.id : s };
      await box.clear(); // Clear previous cache entirely
      await box.putAll(sessionMap);
       print("Saved ${sessions.length} sessions to local cache.");
    } catch (e) {
       print("Error saving chat sessions to Hive: $e");
       // Handle error appropriately, maybe throw a CacheException
       throw Exception("Failed to save sessions: $e");
    }
  }

  @override
  Future<List<ChatSession>> getChatSessions() async {
    try {
      final box = await _getSessionBox();
      // Sort sessions by last message time after retrieval
       final sessions = box.values.toList();
       sessions.sort((a, b) {
           final timeA = a.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
           final timeB = b.lastMessageTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
           return timeB.compareTo(timeA);
       });
       print("Retrieved ${sessions.length} sessions from local cache.");
       return sessions;
    } catch (e) {
       print("Error getting chat sessions from Hive: $e");
       return []; // Return empty list on error
    }
  }

  @override
  Future<void> saveMessages(int chatId, List<Message> messages) async {
    try {
      final box = await _getMessageBox(chatId);
      // Assuming full refresh for simplicity, could implement incremental updates
      // Use message ID or local ID as key
      final messageMap = { for (var m in messages) (m.id > 0 ? m.id.toString() : m.localId!) : m };
      await box.clear(); // Clear previous cache for this chat
      await box.putAll(messageMap); 
      print("Saved ${messages.length} messages for chat $chatId to local cache.");
    } catch (e) {
       print("Error saving messages for chat $chatId to Hive: $e");
       throw Exception("Failed to save messages for chat $chatId: $e");
    }
  }

  @override
  Future<List<Message>> getMessages(int chatId) async {
    try {
      final box = await _getMessageBox(chatId);
      final messages = box.values.toList();
       // Sort by creation time
       messages.sort((a, b) {
           final timeA = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
           final timeB = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
           return timeA.compareTo(timeB);
       });
      print("Retrieved ${messages.length} messages for chat $chatId from local cache.");
      return messages;
    } catch (e) {
       print("Error getting messages for chat $chatId from Hive: $e");
       return []; // Return empty list on error
    }
  }

  @override
  Future<void> addOrUpdateMessage(Message message) async {
     // Ensure message has a valid key (server ID or local ID)
     final key = message.id > 0 ? message.id.toString() : message.localId;
     if (key == null) {
        print("Error: Message has no valid ID or localId to use as cache key.");
        return; 
     }
     try {
       final box = await _getMessageBox(message.chatId);
       await box.put(key, message);
       print("Added/Updated message (key: $key) for chat ${message.chatId} in local cache.");
     } catch (e) {
        print("Error adding/updating message (key: $key) for chat ${message.chatId}: $e");
        throw Exception("Failed to add/update message: $e");
     }
  }

  @override
  Future<void> deleteMessage(int messageId) async {
      // We need to find which chat box this message belongs to.
      // This operation might be inefficient if not structured carefully.
      // Option 1: Iterate through all open message boxes (inefficient).
      // Option 2: Store a messageId -> chatId mapping (complex).
      // Option 3: Require chatId when deleting (changes interface).
      
      // For now, assuming we might need to iterate or have the chatId passed somehow.
      // Placeholder: Requires a better strategy or interface change.
      print("deleteMessage ($messageId) - Local cache implementation needs strategy.");
      // Example if chatId was known:
      // try {
      //   final box = await _getMessageBox(chatId);
      //   await box.delete(messageId.toString());
      // } catch (e) { ... }
      await Future.value(); // Placeholder
  }

 @override
 Future<void> clearSessionMessages(int chatId) async {
    try {
       final box = await _getMessageBox(chatId);
       await box.clear();
       await box.compact(); // Optional: compact to reclaim space
       print("Cleared all messages for chat $chatId from local cache.");
    } catch (e) {
        print("Error clearing messages for chat $chatId: $e");
        throw Exception("Failed to clear messages for chat $chatId: $e");
    }
 }

  @override
  Future<void> clearAllCache() async {
    try {
      final sessionBox = await _getSessionBox();
      await sessionBox.clear();
      print("Cleared chat session cache.");
      
      // TODO: Need a way to get all message box names to clear them.
      // Hive doesn't provide a built-in way to list all boxes easily.
      // Could store a list of active chat IDs in a separate box.
      print("clearAllCache - Clearing individual message boxes requires tracking active chat IDs.");
       // Example if active chat IDs were tracked:
      // final List<int> activeChatIds = await getListOfActiveChatIds(); 
      // for (int chatId in activeChatIds) {
      //    try {
      //       final msgBox = await _getMessageBox(chatId);
      //       await msgBox.clear();
      //       await msgBox.compact();
      //       await msgBox.deleteFromDisk(); // Or just clear?
      //    } catch (e) { print("Error clearing box for chat $chatId: $e"); }
      // }

    } catch (e) {
      print("Error clearing all chat cache: $e");
      throw Exception("Failed to clear all chat cache: $e");
    }
  }

   // Optional: Method to initialize Hive and register adapters at app startup
   static Future<void> initializeHive() async {
     // IMPORTANT: This method is illustrative. Actual Hive initialization and adapter registration
     // MUST happen in main.dart BEFORE runApp() is called.
     // final appDocumentDir = await getApplicationDocumentsDirectory();
     // Hive.init(appDocumentDir.path); 
      Hive.initFlutter(); // Use hive_flutter for web compatibility if needed
      
      // TODO (Critical): Register generated TypeAdapters in main.dart.
      // 1. Annotate ChatSession, Message, User (and nested classes/enums) with @HiveType/@HiveField.
      // 2. Run build_runner: flutter pub run build_runner build --delete-conflicting-outputs
      // 3. In main.dart (before runApp): Hive.registerAdapter(ChatSessionAdapter()); etc. for ALL generated adapters.
       // Hive.registerAdapter(ChatSessionAdapter()); 
       // Hive.registerAdapter(MessageAdapter());
       // Hive.registerAdapter(UserAdapter()); // If User is also cached directly
       print("Hive initialized and adapters registered (PLACEHOLDER - ensure actual registration happens).");
   }
}

// --- 需要创建对应的 Hive Model 和 Adapters ---
// lib/features/chat/data/models/hive/user_hive_model.dart
// lib/features/chat/data/models/hive/message_hive_model.dart
// lib/features/chat/data/models/hive/chat_session_hive_model.dart
nothing_here_yet3() { } 