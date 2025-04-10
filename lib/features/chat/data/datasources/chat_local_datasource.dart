import 'dart:async';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/models.dart';
import '../../domain/entities/entities.dart';
import '../../../../core/error/exceptions.dart';

/// 聊天本地数据源接口
abstract class ChatLocalDataSource implements IChatLocalCache {
  /// 保存会话
  Future<void> saveSession(ChatSessionDto session);
  
  /// 获取单个会话
  Future<ChatSessionDto?> getSession(String sessionId);
  
  /// 缓存消息历史
  Future<void> cacheMessages(String sessionId, List<MessageDto> messages);
  
  /// 缓存单条消息
  Future<void> cacheMessage(MessageDto message);
  
  /// 获取本地未发送的消息
  Future<List<MessageDto>> getPendingMessages();
  
  /// 获取会话最后一条消息
  Future<MessageDto?> getLastMessage(String sessionId);
  
  /// 初始化数据库连接
  Future<void> init();
  
  /// 关闭数据库连接
  Future<void> close();
}

/// 聊天本地数据源实现 (使用Hive)
class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String _sessionBoxName = 'chat_sessions';
  static const String _messageBoxName = 'chat_messages';
  static const String _cacheSettingsKey = 'chat_cache_settings';
  
  Box<Map>? _sessionBox;
  Box<Map>? _messageBox;
  SharedPreferences? _prefs;
  final uuid = const Uuid();
  int _maxCacheSizeMB = 100; // 默认100MB
  
  /// 初始化数据源
  @override
  Future<void> init() async {
    // 注册适配器（如果需要）
    
    // 打开Hive盒子
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      _sessionBox = await Hive.openBox<Map>(_sessionBoxName);
    }
    
    if (!Hive.isBoxOpen(_messageBoxName)) {
      _messageBox = await Hive.openBox<Map>(_messageBoxName);
    }
    
    // 获取SharedPreferences实例
    _prefs = await SharedPreferences.getInstance();
    
    // 加载缓存设置
    _loadCacheSettings();
  }
  
  /// 加载缓存设置
  void _loadCacheSettings() {
    if (_prefs != null) {
      _maxCacheSizeMB = _prefs!.getInt('chat_max_cache_size') ?? 100;
    }
  }
  
  @override
  Future<void> close() async {
    await _sessionBox?.close();
    await _messageBox?.close();
  }
  
  @override
  Future<void> saveSession(ChatSessionDto session) async {
    try {
      if (_sessionBox == null) {
        await init();
      }
      
      await _sessionBox!.put(session.id, session.toJson());
    } catch (e) {
      throw CacheException(message: 'Failed to save session: $e');
    }
  }
  
  @override
  Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      if (_sessionBox == null) {
        await init();
      }
      
      // 转换为DTO并保存
      for (final session in sessions) {
        final dto = ChatSessionDto.fromDomain(session);
        await _sessionBox!.put(session.id, dto.toJson());
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save sessions: $e');
    }
  }
  
  @override
  Future<List<ChatSession>> getSessions() async {
    try {
      if (_sessionBox == null) {
        await init();
      }
      
      return _sessionBox!.values
          .map((json) => ChatSessionDto.fromJson(Map<String, dynamic>.from(json)).toDomain())
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get sessions: $e');
    }
  }
  
  @override
  Future<ChatSessionDto?> getSession(String sessionId) async {
    try {
      if (_sessionBox == null) {
        await init();
      }
      
      final sessionJson = _sessionBox!.get(sessionId);
      if (sessionJson == null) {
        return null;
      }
      
      return ChatSessionDto.fromJson(Map<String, dynamic>.from(sessionJson));
    } catch (e) {
      throw CacheException(message: 'Failed to get session: $e');
    }
  }
  
  @override
  Future<void> updateSessionReadStatus(String sessionId) async {
    try {
      if (_sessionBox == null) {
        await init();
      }
      
      final sessionJson = _sessionBox!.get(sessionId);
      if (sessionJson != null) {
        final session = ChatSessionDto.fromJson(Map<String, dynamic>.from(sessionJson));
        final updatedSession = ChatSessionDto(
          id: session.id,
          title: session.title,
          userId: session.userId,
          targetUserId: session.targetUserId,
          lastMessage: session.lastMessage,
          unreadCount: 0, // 设置未读数为0
          createdAt: session.createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        
        await _sessionBox!.put(sessionId, updatedSession.toJson());
      }
    } catch (e) {
      throw CacheException(message: 'Failed to update session read status: $e');
    }
  }
  
  @override
  Future<void> saveMessages(String sessionId, List<Message> messages) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 转换为DTO
      final messageDtos = messages.map((message) => MessageDto.fromDomain(message)).toList();
      await cacheMessages(sessionId, messageDtos);
    } catch (e) {
      throw CacheException(message: 'Failed to save messages: $e');
    }
  }
  
  @override
  Future<void> cacheMessages(String sessionId, List<MessageDto> messages) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 批量保存
      final batch = <String, Map<String, dynamic>>{};
      for (final message in messages) {
        final key = '${sessionId}_${message.id}';
        batch[key] = message.toJson();
      }
      
      await _messageBox!.putAll(batch);
      
      // 如果有新消息，更新会话最后一条消息
      if (messages.isNotEmpty) {
        final session = await getSession(sessionId);
        if (session != null) {
          // 找出时间戳最大的消息
          final lastMessage = messages.reduce((a, b) => 
            a.timestamp > b.timestamp ? a : b);
          
          final updatedSession = ChatSessionDto(
            id: session.id,
            title: session.title,
            userId: session.userId,
            targetUserId: session.targetUserId,
            lastMessage: lastMessage,
            unreadCount: session.unreadCount,
            createdAt: session.createdAt,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          
          await saveSession(updatedSession);
        }
      }
      
      // 清理过期消息
      await _cleanupOldMessages();
    } catch (e) {
      throw CacheException(message: 'Failed to cache messages: $e');
    }
  }
  
  @override
  Future<void> cacheMessage(MessageDto message) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      final key = '${message.sessionId}_${message.id}';
      await _messageBox!.put(key, message.toJson());
      
      // 更新会话的最后一条消息
      final session = await getSession(message.sessionId);
      if (session != null) {
        final lastMessage = session.lastMessage;
        
        // 如果没有最后一条消息或者当前消息更新，则更新会话
        if (lastMessage == null || message.timestamp > lastMessage.timestamp) {
          final updatedSession = ChatSessionDto(
            id: session.id,
            title: session.title,
            userId: session.userId,
            targetUserId: session.targetUserId,
            lastMessage: message,
            unreadCount: session.unreadCount,
            createdAt: session.createdAt,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          
          await saveSession(updatedSession);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache message: $e');
    }
  }
  
  @override
  Future<List<Message>> getMessages(String sessionId, int limit, String? beforeMessageId) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 获取该会话的所有消息
      final messages = <MessageDto>[];
      final keys = _messageBox!.keys.where((key) => (key as String).startsWith('${sessionId}_'));
      
      for (final key in keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          messages.add(message);
        }
      }
      
      // 按时间戳排序（从新到旧）
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // 如果指定了beforeMessageId，则获取该消息之前的消息
      if (beforeMessageId != null) {
        final index = messages.indexWhere((m) => m.id == beforeMessageId);
        if (index != -1 && index < messages.length - 1) {
          return messages.sublist(index + 1, min(index + 1 + limit, messages.length))
              .map((dto) => dto.toDomain())
              .toList();
        }
      }
      
      // 否则返回最新的limit条消息
      return messages.take(limit).map((dto) => dto.toDomain()).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get messages: $e');
    }
  }
  
  int min(int a, int b) => a < b ? a : b;
  
  @override
  Future<List<MessageDto>> getPendingMessages() async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      final pendingMessages = <MessageDto>[];
      
      for (final key in _messageBox!.keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          final status = message.additionalData?['sync_status'] as String?;
          
          // 找出待同步的消息
          if (status == 'PENDING' || status == 'FAILED') {
            pendingMessages.add(message);
          }
        }
      }
      
      return pendingMessages;
    } catch (e) {
      throw CacheException(message: 'Failed to get pending messages: $e');
    }
  }
  
  @override
  Future<MessageDto?> getLastMessage(String sessionId) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 获取该会话的所有消息
      final messages = <MessageDto>[];
      final keys = _messageBox!.keys.where((key) => (key as String).startsWith('${sessionId}_'));
      
      for (final key in keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          messages.add(message);
        }
      }
      
      if (messages.isEmpty) {
        return null;
      }
      
      // 按时间戳排序（从新到旧）并返回第一条
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages.first;
    } catch (e) {
      throw CacheException(message: 'Failed to get last message: $e');
    }
  }
  
  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 查找包含此消息ID的所有键
      final keys = _messageBox!.keys.where((key) => (key as String).endsWith('_$messageId'));
      
      for (final key in keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          
          // 构建新的additionalData
          final Map<String, dynamic> additionalData = {...message.additionalData ?? {}};
          additionalData['status'] = status.toString().split('.').last;
          
          // 如果是已读状态，添加读取时间
          if (status == MessageStatus.READ) {
            additionalData['read_time'] = DateTime.now().millisecondsSinceEpoch;
          }
          
          // 创建更新后的消息
          final updatedMessage = MessageDto(
            id: message.id,
            sessionId: message.sessionId,
            content: message.content,
            senderId: message.senderId,
            receiverId: message.receiverId,
            type: message.type,
            timestamp: message.timestamp,
            readTime: status == MessageStatus.READ ? DateTime.now().millisecondsSinceEpoch : message.readTime,
            role: message.role,
            messageType: message.messageType,
            parentMessageId: message.parentMessageId,
            additionalData: additionalData,
          );
          
          await _messageBox!.put(key, updatedMessage.toJson());
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to update message status: $e');
    }
  }
  
  @override
  Future<void> clearSessionMessages(String sessionId) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      // 查找该会话的所有消息
      final keys = _messageBox!.keys.where((key) => (key as String).startsWith('${sessionId}_')).toList();
      
      // 批量删除
      await _messageBox!.deleteAll(keys);
    } catch (e) {
      throw CacheException(message: 'Failed to clear session messages: $e');
    }
  }
  
  @override
  Future<void> clearExpiredMessages(Duration expiration) async {
    try {
      if (_messageBox == null) {
        await init();
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final expirationTime = now - expiration.inMilliseconds;
      
      final keysToDelete = <dynamic>[];
      
      for (final key in _messageBox!.keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          
          // 如果消息超过过期时间，添加到待删除列表
          if (message.timestamp < expirationTime) {
            keysToDelete.add(key);
          }
        }
      }
      
      // 批量删除
      if (keysToDelete.isNotEmpty) {
        await _messageBox!.deleteAll(keysToDelete);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear expired messages: $e');
    }
  }
  
  @override
  Future<void> setCacheSizeLimit(int maxSize) async {
    try {
      _maxCacheSizeMB = maxSize;
      
      if (_prefs != null) {
        await _prefs!.setInt('chat_max_cache_size', maxSize);
      }
      
      // 检查并清理缓存
      await _enforceStorageLimit();
    } catch (e) {
      throw CacheException(message: 'Failed to set cache size limit: $e');
    }
  }
  
  /// 执行存储限制，如果超出则删除旧消息
  Future<void> _enforceStorageLimit() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final hiveDir = path.join(dir.path, 'hive');
      
      // 获取消息盒子的文件大小
      final messageBoxFile = path.join(hiveDir, '$_messageBoxName.hive');
      final file = File(messageBoxFile);
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        
        // 如果超出限制，删除旧消息
        if (sizeInMB > _maxCacheSizeMB) {
          // 删除最老的消息，直到达到限制的80%
          await _cleanupOldMessages();
        }
      }
    } catch (e) {
      print('Error enforcing storage limit: $e');
    }
  }
  
  /// 清理旧消息
  Future<void> _cleanupOldMessages() async {
    if (_messageBox == null) {
      return;
    }
    
    try {
      // 获取所有消息并按时间排序
      final allMessages = <MessageDto>[];
      
      for (final key in _messageBox!.keys) {
        final jsonData = _messageBox!.get(key);
        if (jsonData != null) {
          final message = MessageDto.fromJson(Map<String, dynamic>.from(jsonData));
          allMessages.add(message);
        }
      }
      
      // 按时间从旧到新排序
      allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // 获取当前存储大小
      final dir = await getApplicationDocumentsDirectory();
      final hiveDir = path.join(dir.path, 'hive');
      final messageBoxFile = path.join(hiveDir, '$_messageBoxName.hive');
      final file = File(messageBoxFile);
      
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        
        // 如果超出限制
        if (sizeInMB > _maxCacheSizeMB) {
          // 删除旧消息，目标是达到限制的80%
          final targetSize = _maxCacheSizeMB * 0.8;
          final deleteCount = (allMessages.length * (1 - targetSize / sizeInMB)).round();
          
          if (deleteCount > 0) {
            // 获取要删除的消息
            final messagesToDelete = allMessages.take(deleteCount).toList();
            
            // 删除消息
            for (final message in messagesToDelete) {
              final key = '${message.sessionId}_${message.id}';
              await _messageBox!.delete(key);
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old messages: $e');
    }
  }
} 