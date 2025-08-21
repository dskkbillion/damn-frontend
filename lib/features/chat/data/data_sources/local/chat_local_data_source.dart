import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:dskk_flutter_refactor/core/database/app_database.dart';
import 'package:dskk_flutter_refactor/features/chat/data/models/participant_dto.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';

abstract class IChatLocalDataSource {
  // Chat Messages
  Future<List<ChatMessage>> getCachedMessages(int chatId, {int limit = 50, int offset = 0});
  Stream<List<ChatMessage>> watchCachedMessages(int chatId);
  Future<void> cacheMessage(ChatMessage message);
  Future<void> cacheMessages(List<ChatMessage> messages);
  Future<void> updateMessageStatus(int messageId, MessageStatus status);
  Future<void> markMessageAsWithdrawn(int messageId);
  
  // Chat Rooms
  Future<List<ChatRoom>> getCachedChatRooms();
  Stream<List<ChatRoom>> watchCachedChatRooms();
  Future<ChatRoom?> getCachedChatRoom(int chatId);
  Future<void> cacheChatRoom(ChatRoom room);
  Future<void> cacheChatRooms(List<ChatRoom> rooms);
  Future<void> updateChatRoomUnreadCount(int chatId, int unreadCount);
  
  // Message Queue
  Future<void> addToQueue(int chatId, String content, String messageType);
  Future<List<MessageQueueItem>> getPendingMessages();
  Stream<List<MessageQueueItem>> watchPendingMessages();
  Future<void> updateQueueItemStatus(int itemId, String status, {String? errorMessage});
  Future<void> incrementRetryCount(int itemId);
  Future<void> removeFromQueue(int itemId);
  Future<void> clearFailedMessages();
}

class ChatLocalDataSourceImpl implements IChatLocalDataSource {
  final AppDatabase _database;
  
  ChatLocalDataSourceImpl(this._database);
  
  @override
  Future<List<ChatMessage>> getCachedMessages(int chatId, {int limit = 50, int offset = 0}) async {
    final cached = await _database.getChatMessages(chatId, limit: limit, offset: offset);
    return cached.map(_toChatMessage).toList();
  }
  
  @override
  Stream<List<ChatMessage>> watchCachedMessages(int chatId) {
    return _database.watchChatMessages(chatId).map(
      (cached) => cached.map(_toChatMessage).toList(),
    );
  }
  
  @override
  Future<void> cacheMessage(ChatMessage message) async {
    final cache = _toChatMessageCache(message);
    await _database.insertChatMessage(cache);
  }
  
  @override
  Future<void> cacheMessages(List<ChatMessage> messages) async {
    final caches = messages.map(_toChatMessageCache).toList();
    await _database.insertChatMessages(caches);
  }
  
  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    await _database.updateMessageStatus(messageId, _statusToString(status));
  }
  
  @override
  Future<void> markMessageAsWithdrawn(int messageId) async {
    await _database.markMessageAsWithdrawn(messageId);
  }
  
  @override
  Future<List<ChatRoom>> getCachedChatRooms() async {
    final cached = await _database.getChatRooms();
    final rooms = <ChatRoom>[];
    
    for (final cache in cached) {
      final room = await _toChatRoom(cache);
      if (room != null) {
        rooms.add(room);
      }
    }
    
    return rooms;
  }
  
  @override
  Stream<List<ChatRoom>> watchCachedChatRooms() {
    return _database.watchChatRooms().asyncMap((cached) async {
      final rooms = <ChatRoom>[];
      
      for (final cache in cached) {
        final room = await _toChatRoom(cache);
        if (room != null) {
          rooms.add(room);
        }
      }
      
      return rooms;
    });
  }
  
  @override
  Future<ChatRoom?> getCachedChatRoom(int chatId) async {
    final cache = await _database.getChatRoom(chatId);
    if (cache == null) return null;
    return _toChatRoom(cache);
  }
  
  @override
  Future<void> cacheChatRoom(ChatRoom room) async {
    final cache = _toChatRoomCache(room);
    await _database.insertChatRoom(cache);
  }
  
  @override
  Future<void> cacheChatRooms(List<ChatRoom> rooms) async {
    final caches = rooms.map(_toChatRoomCache).toList();
    await _database.insertChatRooms(caches);
  }
  
  @override
  Future<void> updateChatRoomUnreadCount(int chatId, int unreadCount) async {
    await _database.updateChatRoomUnreadCount(chatId, unreadCount);
  }
  
  @override
  Future<void> addToQueue(int chatId, String content, String messageType) async {
    final item = MessageQueueCompanion.insert(
      chatId: chatId,
      content: content,
      messageType: messageType,
    );
    await _database.addToMessageQueue(item);
  }
  
  @override
  Future<List<MessageQueueItem>> getPendingMessages() {
    return _database.getPendingMessages();
  }
  
  @override
  Stream<List<MessageQueueItem>> watchPendingMessages() {
    return _database.watchPendingMessages();
  }
  
  @override
  Future<void> updateQueueItemStatus(int itemId, String status, {String? errorMessage}) async {
    await _database.updateQueueItemStatus(itemId, status, errorMessage: errorMessage);
  }
  
  @override
  Future<void> incrementRetryCount(int itemId) async {
    await _database.incrementQueueItemRetry(itemId);
  }
  
  @override
  Future<void> removeFromQueue(int itemId) async {
    await _database.deleteQueueItem(itemId);
  }
  
  @override
  Future<void> clearFailedMessages() async {
    await _database.clearFailedQueueItems();
  }
  
  // Helper methods for conversion
  ChatMessage _toChatMessage(ChatMessageCache cache) {
    return ChatMessage(
      id: cache.id,
      chatId: cache.chatId,
      senderId: cache.senderId,
      memberId: cache.memberId,
      doctorId: cache.doctorId,
      context: cache.content,
      type: cache.messageType,
      createTime: cache.createTime,
      withdrawFlag: cache.withdrawFlag,
      readFlg: cache.readFlag,
      status: _stringToStatus(cache.status),
    );
  }
  
  ChatMessageCache _toChatMessageCache(ChatMessage message) {
    return ChatMessageCache(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      memberId: message.memberId,
      doctorId: message.doctorId,
      content: message.context,
      messageType: message.type,
      createTime: message.createTime,
      withdrawFlag: message.withdrawFlag,
      readFlag: message.readFlg,
      status: _statusToString(message.status),
      metadata: null,
      localTimestamp: DateTime.now(),
    );
  }
  
  Future<ChatRoom?> _toChatRoom(ChatRoomCache cache) async {
    try {
      final p1Data = jsonDecode(cache.participant1) as Map<String, dynamic>;
      final p2Data = jsonDecode(cache.participant2) as Map<String, dynamic>;
      
      final participant1 = ParticipantDto.fromJson(p1Data).toEntity();
      final participant2 = ParticipantDto.fromJson(p2Data).toEntity();
      
      ChatMessage? lastMessage;
      if (cache.lastMessageId != null) {
        final messages = await _database.getChatMessages(cache.id, limit: 1);
        if (messages.isNotEmpty) {
          lastMessage = _toChatMessage(messages.first);
        }
      }
      
      Map<String, dynamic>? productInfo;
      if (cache.productInfo != null) {
        productInfo = jsonDecode(cache.productInfo!) as Map<String, dynamic>;
      }
      
      return ChatRoom(
        id: cache.id,
        participant1: participant1,
        participant2: participant2,
        unreadCount: cache.unreadCount,
        lastMessage: lastMessage,
        productId: productInfo?['productId'] as String?,
        productName: productInfo?['productName'] as String?,
        productImage: productInfo?['productImage'] as String?,
        productPrice: productInfo?['productPrice'] as double?,
      );
    } catch (e) {
      print('Error converting ChatRoomCache to ChatRoom: $e');
      return null;
    }
  }
  
  ChatRoomCache _toChatRoomCache(ChatRoom room) {
    final p1Json = jsonEncode(ParticipantDto.fromEntity(room.participant1).toJson());
    final p2Json = jsonEncode(ParticipantDto.fromEntity(room.participant2).toJson());
    
    String? productInfo;
    if (room.hasProduct) {
      productInfo = jsonEncode({
        'productId': room.productId,
        'productName': room.productName,
        'productImage': room.productImage,
        'productPrice': room.productPrice,
      });
    }
    
    return ChatRoomCache(
      id: room.id,
      participant1: p1Json,
      participant2: p2Json,
      unreadCount: room.unreadCount,
      lastMessageId: room.lastMessage?.id,
      productInfo: productInfo,
      lastActivityTime: room.lastActivityTime,
      updatedAt: DateTime.now(),
    );
  }
  
  MessageStatus _stringToStatus(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'failed':
        return MessageStatus.failed;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
  
  String _statusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.failed:
        return 'failed';
      case MessageStatus.read:
        return 'read';
    }
  }
}