import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// 模拟聊天仓库实现，用于模块预览或测试
class MockChatRepository implements IChatRepository {
  final uuid = const Uuid();
  final List<ChatSession> _sessions = [];
  final Map<String, List<Message>> _messages = {};
  
  // 流控制器
  final _messagesController = StreamController<Message>.broadcast();
  final _messageStatusController = StreamController<MessageStatusUpdate>.broadcast();
  final _sessionsController = StreamController<List<ChatSession>>.broadcast();
  
  MockChatRepository() {
    _initMockData();
  }
  
  /// 初始化模拟数据
  void _initMockData() {
    // 添加一些模拟会话
    final user1 = User(
      id: 'user1',
      name: '王小明',
      avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      onlineStatus: OnlineStatus.ONLINE,
    );
    
    final user2 = User(
      id: 'user2',
      name: '李晓红',
      avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      onlineStatus: OnlineStatus.OFFLINE,
    );
    
    final user3 = User(
      id: 'user3',
      name: '张大山',
      avatar: 'https://randomuser.me/api/portraits/men/2.jpg',
      onlineStatus: OnlineStatus.BUSY,
    );
    
    final systemUser = User(
      id: 'system',
      name: '系统通知',
      avatar: null,
      onlineStatus: OnlineStatus.ONLINE,
    );
    
    // 创建会话
    final session1 = _createMockSession('session1', 'user1', user1.name, 2);
    final session2 = _createMockSession('session2', 'user2', user2.name, 0);
    final session3 = _createMockSession('session3', 'user3', user3.name, 5);
    final systemSession = _createMockSession('system', 'system', systemUser.name, 1);
    
    _sessions.addAll([session1, session2, session3, systemSession]);
    
    // 添加一些模拟消息
    _messages['session1'] = _createMockMessages('session1', 'user1', 'self', 10);
    _messages['session2'] = _createMockMessages('session2', 'user2', 'self', 15);
    _messages['session3'] = _createMockMessages('session3', 'user3', 'self', 5);
    _messages['system'] = _createSystemMessages('system', 'system', 'self', 3);
    
    // 更新会话的最后一条消息
    for (final session in _sessions) {
      final messages = _messages[session.id];
      if (messages != null && messages.isNotEmpty) {
        final lastMessage = messages.first; // 假设消息已按时间排序
        final updatedSession = session.copyWith(lastMessage: lastMessage);
        final index = _sessions.indexWhere((s) => s.id == session.id);
        if (index != -1) {
          _sessions[index] = updatedSession;
        }
      }
    }
    
    // 发送初始会话列表
    _sessionsController.add(_sessions);
  }
  
  /// 创建模拟会话
  ChatSession _createMockSession(String id, String targetUserId, String title, int unreadCount) {
    return ChatSession(
      id: id,
      userId: 'self',
      targetUserId: targetUserId,
      title: title,
      unreadCount: unreadCount,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: id.hashCode % 24)),
    );
  }
  
  /// 创建模拟消息
  List<Message> _createMockMessages(String sessionId, String senderId, String receiverId, int count) {
    final messages = <Message>[];
    final now = DateTime.now();
    bool isFromCurrentUser = false;
    
    for (int i = 0; i < count; i++) {
      final id = uuid.v4();
      final timestamp = now.subtract(Duration(minutes: i * 5));
      
      messages.add(Message(
        id: id,
        content: '这是一条模拟消息 #${count - i}',
        senderId: isFromCurrentUser ? receiverId : senderId,
        senderType: MessageSenderType.USER,
        messageSource: MessageSourceType.USER,
        receiverId: isFromCurrentUser ? senderId : receiverId,
        receiverType: MessageReceiverType.USER,
        timestamp: timestamp,
        status: isFromCurrentUser ? MessageStatus.SENT : MessageStatus.READ,
        type: MessageType.TEXT,
        syncStatus: MessageSyncStatus.SYNCED,
        sessionId: sessionId,
      ));
      
      // 切换发送者，模拟对话
      isFromCurrentUser = !isFromCurrentUser;
    }
    
    // 按时间排序（从新到旧）
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return messages;
  }
  
  /// 创建系统消息
  List<Message> _createSystemMessages(String sessionId, String senderId, String receiverId, int count) {
    final messages = <Message>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final id = uuid.v4();
      final timestamp = now.subtract(Duration(days: i));
      
      messages.add(Message(
        id: id,
        content: '这是一条系统通知 #${count - i}',
        senderId: senderId,
        senderType: MessageSenderType.SYSTEM,
        messageSource: MessageSourceType.SYSTEM_NOTIFICATION,
        receiverId: receiverId,
        receiverType: MessageReceiverType.USER,
        timestamp: timestamp,
        status: MessageStatus.READ,
        type: MessageType.SYSTEM,
        syncStatus: MessageSyncStatus.SYNCED,
        sessionId: sessionId,
      ));
    }
    
    // 按时间排序（从新到旧）
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return messages;
  }
  
  @override
  Stream<List<ChatSession>> getChatSessions() {
    return _sessionsController.stream;
  }
  
  @override
  Future<Either<Failure, void>> markSessionAsRead(String sessionId) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index != -1) {
      _sessions[index] = _sessions[index].copyWith(unreadCount: 0);
      _sessionsController.add(_sessions);
      return const Right(null);
    } else {
      return Left(ChatFailure(message: 'Session not found', code: 'SESSION_NOT_FOUND'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateSessionStatus(String sessionId, SessionStatus status) async {
    // 简单实现，不做实际状态变更
    return const Right(null);
  }
  
  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index != -1) {
      _sessions.removeAt(index);
      _messages.remove(sessionId);
      _sessionsController.add(_sessions);
      return const Right(null);
    } else {
      return Left(ChatFailure(message: 'Session not found', code: 'SESSION_NOT_FOUND'));
    }
  }
  
  @override
  Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId) async {
    final session = _sessions.firstWhere(
      (session) => session.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );
    
    return Right(session);
  }
  
  @override
  Future<Either<Failure, ChatSession>> createSession(String targetUserId, {Message? initialMessage}) async {
    // 检查是否已存在会话
    final existingSessionIndex = _sessions.indexWhere((session) => session.targetUserId == targetUserId);
    if (existingSessionIndex != -1) {
      return Right(_sessions[existingSessionIndex]);
    }
    
    // 创建新会话
    final sessionId = uuid.v4();
    final session = ChatSession(
      id: sessionId,
      userId: 'self',
      targetUserId: targetUserId,
      title: '新会话 $targetUserId',
      unreadCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _sessions.add(session);
    _messages[sessionId] = [];
    
    // 如果有初始消息，添加它
    if (initialMessage != null) {
      final message = initialMessage.copyWith(
        id: uuid.v4(),
        timestamp: DateTime.now(),
        status: MessageStatus.SENT,
        syncStatus: MessageSyncStatus.SYNCED,
        sessionId: sessionId,
      );
      
      _messages[sessionId]!.add(message);
      
      // 更新会话的最后一条消息
      final updatedSession = session.copyWith(lastMessage: message);
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }
    }
    
    _sessionsController.add(_sessions);
    
    return Right(session);
  }
  
  @override
  Future<Either<Failure, List<Message>>> getMessages(String sessionId, String? beforeMessageId, int limit) async {
    if (!_messages.containsKey(sessionId)) {
      return const Right([]);
    }
    
    final messages = _messages[sessionId]!;
    
    if (beforeMessageId != null) {
      final index = messages.indexWhere((message) => message.id == beforeMessageId);
      if (index != -1 && index < messages.length - 1) {
        return Right(messages.sublist(index + 1, (index + 1 + limit).clamp(0, messages.length)));
      }
    }
    
    return Right(messages.take(limit).toList());
  }
  
  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
    
    final sessionId = message.sessionId;
    if (!_messages.containsKey(sessionId)) {
      _messages[sessionId] = [];
    }
    
    final sentMessage = message.copyWith(
      id: message.id.isEmpty ? uuid.v4() : message.id,
      status: MessageStatus.SENT,
      syncStatus: MessageSyncStatus.SYNCED,
      timestamp: DateTime.now(),
    );
    
    // 添加到消息列表
    _messages[sessionId]!.insert(0, sentMessage);
    
    // 更新会话的最后一条消息
    final sessionIndex = _sessions.indexWhere((session) => session.id == sessionId);
    if (sessionIndex != -1) {
      _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
        lastMessage: sentMessage,
        updatedAt: DateTime.now(),
      );
      _sessionsController.add(_sessions);
    }
    
    // 发送到消息流
    _messagesController.add(sentMessage);
    
    // 模拟自动回复
    _simulateReply(sessionId, sentMessage);
    
    return Right(sentMessage);
  }
  
  /// 模拟自动回复
  void _simulateReply(String sessionId, Message sentMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      final session = _sessions.firstWhere(
        (session) => session.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );
      
      final replyMessage = Message(
        id: uuid.v4(),
        content: '这是对"${sentMessage.content}"的自动回复',
        senderId: session.targetUserId,
        senderType: MessageSenderType.USER,
        messageSource: MessageSourceType.USER,
        receiverId: 'self',
        receiverType: MessageReceiverType.USER,
        timestamp: DateTime.now(),
        status: MessageStatus.SENT,
        type: MessageType.TEXT,
        syncStatus: MessageSyncStatus.SYNCED,
        sessionId: sessionId,
      );
      
      // 添加到消息列表
      _messages[sessionId]!.insert(0, replyMessage);
      
      // 更新会话的最后一条消息和未读计数
      final sessionIndex = _sessions.indexWhere((session) => session.id == sessionId);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
          lastMessage: replyMessage,
          updatedAt: DateTime.now(),
          unreadCount: _sessions[sessionIndex].unreadCount + 1,
        );
        _sessionsController.add(_sessions);
      }
      
      // 发送到消息流
      _messagesController.add(replyMessage);
    });
  }
  
  @override
  Future<Either<Failure, void>> revokeMessage(String messageId) async {
    for (final sessionId in _messages.keys) {
      final messages = _messages[sessionId]!;
      final index = messages.indexWhere((message) => message.id == messageId);
      
      if (index != -1) {
        // 更新消息状态
        final revokedMessage = messages[index].copyWith(
          status: MessageStatus.REVOKED,
          content: '此消息已被撤回',
        );
        
        messages[index] = revokedMessage;
        
        // 如果是会话的最后一条消息，也更新会话
        final sessionIndex = _sessions.indexWhere((session) => 
          session.id == sessionId && 
          session.lastMessage?.id == messageId
        );
        
        if (sessionIndex != -1) {
          _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
            lastMessage: revokedMessage,
          );
          _sessionsController.add(_sessions);
        }
        
        // 发送状态更新
        _messageStatusController.add(MessageStatusUpdate(
          messageId: messageId,
          newStatus: MessageStatus.REVOKED,
          sessionId: sessionId,
          timestamp: DateTime.now(),
        ));
        
        return const Right(null);
      }
    }
    
    return Left(ChatFailure(message: 'Message not found', code: 'MESSAGE_NOT_FOUND'));
  }
  
  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    for (final sessionId in _messages.keys) {
      final messages = _messages[sessionId]!;
      final index = messages.indexWhere((message) => message.id == messageId);
      
      if (index != -1) {
        // 删除消息
        messages.removeAt(index);
        
        // 如果是会话的最后一条消息，也更新会话
        final sessionIndex = _sessions.indexWhere((session) => 
          session.id == sessionId && 
          session.lastMessage?.id == messageId
        );
        
        if (sessionIndex != -1) {
          final newLastMessage = messages.isNotEmpty ? messages.first : null;
          _sessions[sessionIndex] = _sessions[sessionIndex].copyWith(
            lastMessage: newLastMessage,
          );
          _sessionsController.add(_sessions);
        }
        
        return const Right(null);
      }
    }
    
    return Left(ChatFailure(message: 'Message not found', code: 'MESSAGE_NOT_FOUND'));
  }
  
  @override
  Stream<Message> observeMessages() {
    return _messagesController.stream;
  }
  
  @override
  Stream<MessageStatusUpdate> observeMessageStatusUpdates() {
    return _messageStatusController.stream;
  }
  
  @override
  Future<Either<Failure, T>> retryOperation<T>(Future<Either<Failure, T>> Function() operation, int maxRetries) async {
    return await operation();
  }
  
  @override
  Future<Either<Failure, void>> clearError(String messageId) async {
    return const Right(null);
  }
  
  /// 释放资源
  void dispose() {
    _messagesController.close();
    _messageStatusController.close();
    _sessionsController.close();
  }
} 