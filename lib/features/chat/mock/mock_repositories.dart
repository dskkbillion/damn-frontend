import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';

import '../domain/entities/chat_enums.dart';
import '../domain/entities/chat_session.dart';
import '../domain/entities/message.dart';
import '../domain/entities/user.dart';
import '../domain/failures/chat_failure.dart';
import '../domain/repositories/i_chat_repository.dart';
import '../domain/services/i_chat_realtime_service.dart';
import 'mock_data.dart';

/// 聊天仓库的Mock实现
///
/// 提供隔离开发和测试环境下的模拟数据
class MockChatRepository implements IChatRepository {
  final _mockData = MockChatData();
  final _sessionController = StreamController<List<ChatSession>>.broadcast();

  MockChatRepository() {
    // 初始化会话数据
    _sessionController.add(_mockData.sessions);
  }

  @override
  Future<Either<ChatFailure, ChatSession>> createSession({
    required String targetUserId,
    String? initialMessage,
  }) async {
    try {
      // 检查是否已存在会话
      final existingSession = _mockData.sessions.firstWhere(
        (session) => session.targetUserId == targetUserId,
        orElse: () => null as ChatSession,
      );

      if (existingSession != null) {
        return Right(existingSession);
      }

      // 创建新会话
      final targetUser = _mockData.users.firstWhere(
        (user) => user.id == targetUserId,
        orElse: () => User(
          id: targetUserId,
          displayName: '用户$targetUserId',
          isOnline: false,
        ),
      );

      final newSession = ChatSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        title: targetUser.displayName,
        currentUserId: 'current_user',
        targetUserId: targetUserId,
        targetUser: targetUser,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unreadCount: 0,
        pinned: false,
        muted: false,
        lastMessage: initialMessage != null
            ? Message(
                id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
                senderId: 'current_user',
                content: initialMessage,
                timestamp: DateTime.now(),
                status: MessageStatus.sent,
                type: MessageType.text,
                currentUserId: 'current_user',
              )
            : null,
      );

      _mockData.sessions.add(newSession);
      _sessionController.add(_mockData.sessions);

      // 如果有初始消息，添加到消息列表
      if (initialMessage != null) {
        final message = Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          sessionId: newSession.id,
          senderId: 'current_user',
          content: initialMessage,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          type: MessageType.text,
          currentUserId: 'current_user',
        );
        
        _mockData.messages[newSession.id] = [message];
      }

      return Right(newSession);
    } catch (e) {
      return Left(ChatFailure(message: '创建会话失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> deleteSession(String sessionId) async {
    try {
      _mockData.sessions.removeWhere((session) => session.id == sessionId);
      _mockData.messages.remove(sessionId);
      _sessionController.add(_mockData.sessions);
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(message: '删除会话失败: $e'));
    }
  }

  @override
  Stream<List<ChatSession>> getChatSessions() {
    return _sessionController.stream;
  }

  @override
  Future<Either<ChatFailure, List<Message>>> getMessages({
    required String sessionId,
    String? beforeMessageId,
    int limit = 20,
  }) async {
    try {
      final messages = _mockData.messages[sessionId] ?? [];
      if (messages.isEmpty) {
        return const Right([]);
      }

      if (beforeMessageId == null) {
        return Right(messages.take(limit).toList());
      }

      final index = messages.indexWhere((message) => message.id == beforeMessageId);
      if (index == -1 || index + 1 >= messages.length) {
        return const Right([]);
      }

      return Right(messages.sublist(index + 1, min(index + 1 + limit, messages.length)));
    } catch (e) {
      return Left(ChatFailure(message: '获取消息失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> markSessionAsRead(String sessionId) async {
    try {
      final sessionIndex = _mockData.sessions.indexWhere((session) => session.id == sessionId);
      if (sessionIndex != -1) {
        final updatedSession = _mockData.sessions[sessionIndex].copyWith(unreadCount: 0);
        _mockData.sessions[sessionIndex] = updatedSession;
        _sessionController.add(_mockData.sessions);
      }
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(message: '标记已读失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, Message>> sendMessage(Message message) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟

    try {
      // 随机生成测试发送消息失败的情况
      if (Random().nextInt(10) == 0) {
        return Left(ChatFailure(message: '发送消息失败: 网络错误'));
      }

      final newMessage = message.copyWith(
        id: 'server_${message.id}',
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      // 添加到对应会话的消息列表
      if (_mockData.messages.containsKey(message.sessionId)) {
        _mockData.messages[message.sessionId]!.insert(0, newMessage);
      } else {
        _mockData.messages[message.sessionId] = [newMessage];
      }

      // 更新会话的最后一条消息
      final sessionIndex = _mockData.sessions.indexWhere((session) => session.id == message.sessionId);
      if (sessionIndex != -1) {
        final updatedSession = _mockData.sessions[sessionIndex].copyWith(
          lastMessage: newMessage,
          updatedAt: DateTime.now(),
        );
        _mockData.sessions[sessionIndex] = updatedSession;
        _sessionController.add(_mockData.sessions);
      }

      // 延迟模拟对方已读
      Future.delayed(const Duration(seconds: 2), () {
        final msgIndex = _mockData.messages[message.sessionId]!.indexWhere((m) => m.id == newMessage.id);
        if (msgIndex != -1) {
          _mockData.messages[message.sessionId]![msgIndex] = _mockData.messages[message.sessionId]![msgIndex].copyWith(
            status: MessageStatus.read,
          );
        }
      });

      return Right(newMessage);
    } catch (e) {
      return Left(ChatFailure(message: '发送消息失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> updateSessionLocalState({
    required String sessionId,
    bool? isPinned,
    bool? isMuted,
  }) async {
    try {
      final sessionIndex = _mockData.sessions.indexWhere((session) => session.id == sessionId);
      if (sessionIndex != -1) {
        final updatedSession = _mockData.sessions[sessionIndex].copyWith(
          pinned: isPinned ?? _mockData.sessions[sessionIndex].pinned,
          muted: isMuted ?? _mockData.sessions[sessionIndex].muted,
        );
        _mockData.sessions[sessionIndex] = updatedSession;
        _sessionController.add(_mockData.sessions);
      }
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(message: '更新会话状态失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) async {
    try {
      final sessionIndex = _mockData.sessions.indexWhere((session) => session.id == sessionId);
      if (sessionIndex != -1) {
        // 实际实现中会根据状态执行不同操作
        _sessionController.add(_mockData.sessions);
      }
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure(message: '更新会话状态失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, List<Message>>> batchLoadMessages({
    required String sessionId, 
    DateTime? lastSyncTime, 
    int limit = 100,
  }) async {
    try {
      final messages = _mockData.messages[sessionId] ?? [];
      if (messages.isEmpty) {
        return const Right([]);
      }

      if (lastSyncTime == null) {
        return Right(messages.take(limit).toList());
      }

      final filteredMessages = messages
          .where((message) => message.timestamp.isAfter(lastSyncTime))
          .take(limit)
          .toList();
      
      return Right(filteredMessages);
    } catch (e) {
      return Left(ChatFailure(message: '批量加载消息失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, User>> getUserById(String userId) async {
    try {
      final user = _mockData.users.firstWhere(
        (user) => user.id == userId,
        orElse: () => User(
          id: userId,
          displayName: '用户$userId',
          isOnline: false,
        ),
      );
      return Right(user);
    } catch (e) {
      return Left(ChatFailure(message: '获取用户信息失败: $e'));
    }
  }

  /// 添加一条模拟的接收消息
  Future<void> simulateIncomingMessage(String sessionId, String content) async {
    // 找到会话
    final sessionIndex = _mockData.sessions.indexWhere((session) => session.id == sessionId);
    if (sessionIndex == -1) return;
    
    final session = _mockData.sessions[sessionIndex];
    
    // 创建新消息
    final newMessage = Message(
      id: 'incoming_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      senderId: session.targetUserId,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.received,
      type: MessageType.text,
      currentUserId: 'current_user',
    );
    
    // 添加到消息列表
    if (_mockData.messages.containsKey(sessionId)) {
      _mockData.messages[sessionId]!.insert(0, newMessage);
    } else {
      _mockData.messages[sessionId] = [newMessage];
    }
    
    // 更新会话
    final updatedSession = session.copyWith(
      lastMessage: newMessage,
      updatedAt: DateTime.now(),
      unreadCount: session.unreadCount + 1,
    );
    
    _mockData.sessions[sessionIndex] = updatedSession;
    _sessionController.add(_mockData.sessions);
  }
}

/// 聊天实时服务的Mock实现
class MockChatRealtimeService implements IChatRealtimeService {
  final _messageController = StreamController<Message>.broadcast();
  final _messageStatusController = StreamController<MessageStatusUpdate>.broadcast();
  final MockChatRepository _repository;

  MockChatRealtimeService(this._repository) {
    // 每隔一段时间模拟接收一条随机消息
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateRandomMessage();
    });
  }

  @override
  Stream<Message> get messageStream => _messageController.stream;

  @override
  Stream<MessageStatusUpdate> get messageStatusStream => _messageStatusController.stream;

  /// 模拟接收随机消息
  void _simulateRandomMessage() {
    if (_repository._mockData.sessions.isEmpty) return;
    
    // 随机选择一个会话
    final random = Random();
    final session = _repository._mockData.sessions[random.nextInt(_repository._mockData.sessions.length)];
    
    // 随机消息内容
    final messages = [
      '你好！',
      '最近在忙什么呢？',
      '周末有空一起出去玩吗？',
      '我刚看了一部很不错的电影，推荐给你',
      '项目进展如何了？',
      '需要我帮忙吗？',
      '明天下午有个会议，记得准备一下',
      '今天天气真好啊！',
      '午饭吃了什么？',
      '新商品上架了，记得去看看',
    ];
    
    final content = messages[random.nextInt(messages.length)];
    
    // 创建并发送消息
    _repository.simulateIncomingMessage(session.id, content).then((_) {
      final newMessages = _repository._mockData.messages[session.id];
      if (newMessages != null && newMessages.isNotEmpty) {
        _messageController.add(newMessages.first);
      }
    });
  }

  /// 模拟发送消息状态更新
  void simulateMessageStatusUpdate(String messageId, MessageStatus status) {
    _messageStatusController.add(MessageStatusUpdate(
      messageId: messageId,
      status: status,
    ));
  }
}

/// 消息状态更新数据类
class MessageStatusUpdate {
  final String messageId;
  final MessageStatus status;

  MessageStatusUpdate({
    required this.messageId,
    required this.status,
  });
} 