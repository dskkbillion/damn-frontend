import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../domain/entities/chat_enums.dart';
import '../models/chat_session_dto.dart';
import '../models/message_dto.dart';
import '../models/user_dto.dart';

/// 聊天本地数据源
///
/// 负责聊天数据的本地持久化存储
class ChatLocalDataSource {
  static const String _dbName = 'chat_app.db';
  static const int _dbVersion = 1;
  
  static const String _sessionTable = 'chat_sessions';
  static const String _messageTable = 'messages';
  static const String _userTable = 'users';
  static const String _sessionStateKey = 'chat_session_states';
  
  late Database _database;
  late SharedPreferences _prefs;
  
  /// 创建一个聊天本地数据源
  ///
  /// 初始化数据库和共享首选项
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _openDatabase();
  }
  
  /// 打开/创建数据库
  Future<Database> _openDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        // 创建会话表
        await db.execute('''
          CREATE TABLE $_sessionTable(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            user_id TEXT NOT NULL,
            target_user_id TEXT NOT NULL,
            last_message TEXT,
            unread_count INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        
        // 创建消息表
        await db.execute('''
          CREATE TABLE $_messageTable(
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            content TEXT NOT NULL,
            sender_id TEXT NOT NULL,
            sender_type TEXT NOT NULL,
            message_source TEXT NOT NULL,
            receiver_id TEXT NOT NULL,
            receiver_type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            status TEXT NOT NULL,
            type TEXT NOT NULL,
            parent_message_id TEXT,
            metadata TEXT,
            FOREIGN KEY (session_id) REFERENCES $_sessionTable (id) ON DELETE CASCADE
          )
        ''');
        
        // 创建用户表
        await db.execute('''
          CREATE TABLE $_userTable(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            avatar TEXT,
            online_status TEXT,
            bio TEXT,
            is_system INTEGER NOT NULL DEFAULT 0
          )
        ''');
        
        // 创建索引
        await db.execute('CREATE INDEX message_session_idx ON $_messageTable (session_id)');
        await db.execute('CREATE INDEX message_timestamp_idx ON $_messageTable (timestamp)');
      },
      version: _dbVersion,
    );
  }
  
  /// 保存会话
  Future<void> saveSession(ChatSessionDto session) async {
    await _database.insert(
      _sessionTable,
      session.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // 如果有最后一条消息，同时保存
    if (session.lastMessageDto != null) {
      await saveMessage(session.lastMessageDto!);
    }
  }
  
  /// 批量保存会话
  Future<void> saveSessions(List<ChatSessionDto> sessions) async {
    final batch = _database.batch();
    
    for (final session in sessions) {
      batch.insert(
        _sessionTable,
        session.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // 如果有最后一条消息，同时保存
      if (session.lastMessageDto != null) {
        batch.insert(
          _messageTable,
          session.lastMessageDto!.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    
    await batch.commit(noResult: true);
  }
  
  /// 获取会话列表
  Future<List<ChatSessionDto>> getSessions() async {
    final sessionsMap = await _database.query(_sessionTable);
    
    final List<ChatSessionDto> sessions = [];
    for (final sessionMap in sessionsMap) {
      // 补充本地状态
      final sessionId = sessionMap['id'] as String;
      final localState = _getSessionLocalState(sessionId);
      
      // 创建会话DTO
      final dto = ChatSessionDto.fromJson(sessionMap);
      
      // 获取最后一条消息
      final lastMessageId = sessionMap['last_message'];
      if (lastMessageId != null) {
        final messageMap = await _database.query(
          _messageTable,
          where: 'id = ?',
          whereArgs: [lastMessageId],
        );
        
        if (messageMap.isNotEmpty) {
          sessions.add(
            _addLocalStateToSession(dto, localState['pinned'], localState['muted'])
          );
        }
      } else {
        sessions.add(
          _addLocalStateToSession(dto, localState['pinned'], localState['muted'])
        );
      }
    }
    
    return sessions;
  }
  
  /// 获取单个会话
  Future<ChatSessionDto?> getSession(String sessionId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _sessionTable,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    // 补充本地状态
    final localState = _getSessionLocalState(sessionId);
    
    // 创建会话DTO
    final dto = ChatSessionDto.fromJson(maps.first);
    
    // 获取最后一条消息
    final lastMessageId = maps.first['last_message'];
    if (lastMessageId != null) {
      final messageMap = await _database.query(
        _messageTable,
        where: 'id = ?',
        whereArgs: [lastMessageId],
      );
      
      if (messageMap.isNotEmpty) {
        final lastMessage = MessageDto.fromJson(messageMap.first);
        // TODO: 需要处理lastMessageDto的设置
      }
    }
    
    return _addLocalStateToSession(dto, localState['pinned'], localState['muted']);
  }
  
  /// 更新会话已读状态
  Future<void> updateSessionReadStatus(String sessionId) async {
    await _database.update(
      _sessionTable,
      {'unread_count': 0},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
  
  /// 更新会话本地状态
  Future<void> updateSessionLocalState(
    String sessionId, {
    bool? isPinned,
    bool? isMuted,
  }) async {
    final allStates = await _getAllSessionLocalStates();
    final sessionState = allStates[sessionId] ?? {'pinned': false, 'muted': false};
    
    if (isPinned != null) {
      sessionState['pinned'] = isPinned;
    }
    
    if (isMuted != null) {
      sessionState['muted'] = isMuted;
    }
    
    allStates[sessionId] = sessionState;
    await _saveAllSessionLocalStates(allStates);
  }
  
  /// 删除会话
  Future<void> deleteSession(String sessionId) async {
    await _database.delete(
      _sessionTable,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    
    // 删除会话相关的所有消息
    await _database.delete(
      _messageTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    
    // 删除本地状态
    final allStates = await _getAllSessionLocalStates();
    allStates.remove(sessionId);
    await _saveAllSessionLocalStates(allStates);
  }
  
  /// 保存消息
  Future<void> saveMessage(MessageDto message) async {
    await _database.insert(
      _messageTable,
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// 批量保存消息
  Future<void> saveMessages(String sessionId, List<MessageDto> messages) async {
    final batch = _database.batch();
    
    for (final message in messages) {
      batch.insert(
        _messageTable,
        message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  /// 获取消息列表
  Future<List<MessageDto>> getMessages(
    String sessionId,
    int limit,
    String? beforeMessageId,
  ) async {
    String? beforeTimestamp;
    
    if (beforeMessageId != null) {
      final beforeMessage = await getMessage(beforeMessageId);
      if (beforeMessage != null) {
        beforeTimestamp = beforeMessage.timestamp;
      }
    }
    
    final List<Map<String, dynamic>> maps;
    
    if (beforeTimestamp != null) {
      maps = await _database.query(
        _messageTable,
        where: 'session_id = ? AND timestamp < ?',
        whereArgs: [sessionId, beforeTimestamp],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
    } else {
      maps = await _database.query(
        _messageTable,
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
    }
    
    return maps.map((map) => MessageDto.fromJson(map)).toList();
  }
  
  /// 获取单条消息
  Future<MessageDto?> getMessage(String messageId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _messageTable,
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return MessageDto.fromJson(maps.first);
  }
  
  /// 更新消息状态
  Future<void> updateMessageStatus(String messageId, String status) async {
    await _database.update(
      _messageTable,
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
  
  /// 批量更新消息状态
  Future<void> batchUpdateMessageStatus(
    String sessionId,
    String status,
  ) async {
    await _database.update(
      _messageTable,
      {'status': status},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
  
  /// 标记消息为已删除
  Future<void> markMessageAsDeleted(String messageId) async {
    await updateMessageStatus(messageId, 'deleted');
  }
  
  /// 清除会话的所有消息
  Future<void> clearSessionMessages(String sessionId) async {
    await _database.delete(
      _messageTable,
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
  
  /// 清除过期消息
  Future<void> clearExpiredMessages(Duration expiration) async {
    final cutoffDate = DateTime.now().subtract(expiration);
    final cutoffTimestamp = cutoffDate.toIso8601String();
    
    await _database.delete(
      _messageTable,
      where: 'timestamp < ?',
      whereArgs: [cutoffTimestamp],
    );
  }
  
  /// 搜索消息
  Future<List<MessageDto>> searchMessages(
    String query, {
    String? sessionId,
  }) async {
    final String whereClause;
    final List<dynamic> whereArgs;
    
    if (sessionId != null) {
      whereClause = 'session_id = ? AND content LIKE ?';
      whereArgs = [sessionId, '%$query%'];
    } else {
      whereClause = 'content LIKE ?';
      whereArgs = ['%$query%'];
    }
    
    final List<Map<String, dynamic>> maps = await _database.query(
      _messageTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
    );
    
    return maps.map((map) => MessageDto.fromJson(map)).toList();
  }
  
  /// 保存用户
  Future<void> saveUser(UserDto user) async {
    await _database.insert(
      _userTable,
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// 获取用户
  Future<UserDto?> getUser(String userId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _userTable,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return UserDto.fromJson(maps.first);
  }
  
  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    final messagesCount = Sqflite.firstIntValue(
      await _database.rawQuery('SELECT COUNT(*) FROM $_messageTable')
    ) ?? 0;
    
    // 假设每条消息平均500字节
    return messagesCount * 500;
  }
  
  /// 清除所有缓存
  Future<void> clearAllCache() async {
    await _database.delete(_messageTable);
    await _database.delete(_sessionTable);
    await _database.delete(_userTable);
    await _prefs.remove(_sessionStateKey);
  }
  
  /// 获取指定会话的本地状态
  Map<String, bool> _getSessionLocalState(String sessionId) {
    final allStates = _getAllSessionLocalStatesSync();
    return allStates[sessionId] ?? {'pinned': false, 'muted': false};
  }
  
  /// 获取所有会话的本地状态（同步版本）
  Map<String, Map<String, bool>> _getAllSessionLocalStatesSync() {
    final stateJson = _prefs.getString(_sessionStateKey);
    if (stateJson == null) {
      return {};
    }
    
    try {
      final Map<String, dynamic> allStates = jsonDecode(stateJson);
      final result = <String, Map<String, bool>>{};
      
      allStates.forEach((key, value) {
        if (value is Map) {
          result[key] = {
            'pinned': value['pinned'] ?? false,
            'muted': value['muted'] ?? false,
          };
        }
      });
      
      return result;
    } catch (e) {
      return {};
    }
  }
  
  /// 获取所有会话的本地状态
  Future<Map<String, Map<String, bool>>> _getAllSessionLocalStates() async {
    return _getAllSessionLocalStatesSync();
  }
  
  /// 保存所有会话的本地状态
  Future<void> _saveAllSessionLocalStates(Map<String, Map<String, bool>> states) async {
    await _prefs.setString(_sessionStateKey, jsonEncode(states));
  }
  
  /// 为会话添加本地状态
  ChatSessionDto _addLocalStateToSession(
    ChatSessionDto session,
    bool isPinned,
    bool isMuted,
  ) {
    // TODO: 需要修改ChatSessionDto模型以支持这些字段
    // 目前先返回原始会话
    return session;
  }
  
  /// 关闭数据库
  Future<void> close() async {
    await _database.close();
  }
} 