import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';

import '../domain/entities/chat_enums.dart';
import '../domain/entities/chat_session.dart';
import '../domain/entities/message.dart';
import '../domain/entities/user.dart';
import '../domain/failures/chat_failure.dart';
import '../domain/repositories/i_chat_repository.dart';
import 'mock_data.dart';

/// 聊天仓库的Mock实现
///
/// 提供隔离开发和测试环境下的模拟数据
class MockChatRepository implements IChatRepository {
  final _mockData = MockChatData();
  final _sessionController = StreamController<List<ChatSession>>.broadcast();
  final _messageController = StreamController<Message>.broadcast();
  final _statusUpdateController = StreamController<MessageStatusUpdate>.broadcast();

  MockChatRepository() {
    // 初始化会话数据
    _sessionController.add(_mockData.sessions);
  }

  @override
  Future<Either<ChatFailure, ChatSession>> createSession({
    required String targetUserId,
    Message? initialMessage,
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
        lastMessage: initialMessage,
      );

      _mockData.sessions.add(newSession);
      _sessionController.add(_mockData.sessions);

      // 如果有初始消息，添加到消息列表
      if (initialMessage != null) {
        // 确保消息有正确的会话ID
        final messageWithSessionId = initialMessage.sessionId.isEmpty
            ? initialMessage.copyWith(sessionId: newSession.id)
            : initialMessage;
        
        _mockData.messages[newSession.id] = [messageWithSessionId];
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
  Future<Either<ChatFailure, List<Message>>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  ) async {
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
  Future<Either<ChatFailure, void>> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  ) async {
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
  Future<Either<ChatFailure, List<Message>>> batchLoadMessages(
    String sessionId,
    DateTime fromTimestamp,
    int limit,
  ) async {
    try {
      final messages = _mockData.messages[sessionId] ?? [];
      if (messages.isEmpty) {
        return const Right([]);
      }

      final filteredMessages = messages
          .where((message) => message.timestamp.isAfter(fromTimestamp))
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

  @override
  Future<Either<ChatFailure, void>> revokeMessage(String messageId) async {
    try {
      // 在所有会话的消息中查找此消息
      for (final sessionId in _mockData.messages.keys) {
        final messages = _mockData.messages[sessionId]!;
        final index = messages.indexWhere((m) => m.id == messageId);
        
        if (index != -1) {
          // 标记消息为已撤回
          final message = messages[index];
          final updatedMessage = message.copyWith(
            content: '此消息已被撤回',
            type: MessageType.revoked,
          );
          
          messages[index] = updatedMessage;
          
          // 如果是会话的最后一条消息，更新会话
          final sessionIndex = _mockData.sessions.indexWhere((s) => s.id == sessionId);
          if (sessionIndex != -1) {
            final session = _mockData.sessions[sessionIndex];
            if (session.lastMessage?.id == messageId) {
              final updatedSession = session.copyWith(lastMessage: updatedMessage);
              _mockData.sessions[sessionIndex] = updatedSession;
              _sessionController.add(_mockData.sessions);
            }
          }
          
          return const Right(null);
        }
      }
      
      return Left(ChatFailure(message: '消息不存在'));
    } catch (e) {
      return Left(ChatFailure(message: '撤回消息失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, void>> deleteMessage(String messageId) async {
    try {
      // 在所有会话的消息中查找此消息
      for (final sessionId in _mockData.messages.keys) {
        final messages = _mockData.messages[sessionId]!;
        final index = messages.indexWhere((m) => m.id == messageId);
        
        if (index != -1) {
          // 删除消息
          messages.removeAt(index);
          
          // 如果是会话的最后一条消息，更新会话
          final sessionIndex = _mockData.sessions.indexWhere((s) => s.id == sessionId);
          if (sessionIndex != -1) {
            final session = _mockData.sessions[sessionIndex];
            if (session.lastMessage?.id == messageId) {
              final updatedSession = session.copyWith(
                lastMessage: messages.isNotEmpty ? messages.first : null,
              );
              _mockData.sessions[sessionIndex] = updatedSession;
              _sessionController.add(_mockData.sessions);
            }
          }
          
          return const Right(null);
        }
      }
      
      return Left(ChatFailure(message: '消息不存在'));
    } catch (e) {
      return Left(ChatFailure(message: '删除消息失败: $e'));
    }
  }

  @override
  Stream<Message> observeMessages() {
    return _messageController.stream;
  }

  @override
  Stream<MessageStatusUpdate> observeMessageStatusUpdates() {
    return _statusUpdateController.stream;
  }

  @override
  Future<Either<ChatFailure, T>> retryOperation<T>(
    Future<Either<ChatFailure, T>> Function() operation,
    int maxRetries,
  ) async {
    int attempts = 0;
    ChatFailure? lastFailure;
    
    while (attempts < maxRetries) {
      final result = await operation();
      
      if (result.isRight()) {
        return result;
      } else {
        lastFailure = result.fold((l) => l, (r) => null);
        attempts++;
        await Future.delayed(Duration(milliseconds: 500 * attempts)); // 指数退避
      }
    }
    
    return Left(lastFailure ?? ChatFailure(message: '操作失败'));
  }

  @override
  Future<Either<ChatFailure, void>> clearError(String messageId) async {
    try {
      // 在所有会话的消息中查找此消息
      for (final sessionId in _mockData.messages.keys) {
        final messages = _mockData.messages[sessionId]!;
        final index = messages.indexWhere((m) => m.id == messageId);
        
        if (index != -1 && messages[index].status == MessageStatus.failed) {
          // 重置消息状态
          messages[index] = messages[index].copyWith(status: MessageStatus.pending);
          return const Right(null);
        }
      }
      
      return Left(ChatFailure(message: '消息不存在或状态正常'));
    } catch (e) {
      return Left(ChatFailure(message: '清除错误失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, ChatSession>> getSessionDetail(String sessionId) async {
    try {
      final session = _mockData.sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('会话不存在'),
      );
      return Right(session);
    } catch (e) {
      return Left(ChatFailure(message: '获取会话详情失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, List<Message>>> searchMessages(
    String query, {
    String? sessionId,
  }) async {
    try {
      final results = <Message>[];
      
      if (sessionId != null) {
        // 在特定会话中搜索
        final messages = _mockData.messages[sessionId] ?? [];
        results.addAll(messages.where(
          (m) => m.content.toLowerCase().contains(query.toLowerCase())
        ));
      } else {
        // 在所有会话中搜索
        for (final messages in _mockData.messages.values) {
          results.addAll(messages.where(
            (m) => m.content.toLowerCase().contains(query.toLowerCase())
          ));
        }
      }
      
      return Right(results);
    } catch (e) {
      return Left(ChatFailure(message: '搜索消息失败: $e'));
    }
  }

  @override
  Future<Either<ChatFailure, ChatSession>> updateLocalSessionState(
    String sessionId, {
    bool? isPinned,
    bool? isMuted,
  }) async {
    try {
      final sessionIndex = _mockData.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        return Left(ChatFailure(message: '会话不存在'));
      }
      
      final session = _mockData.sessions[sessionIndex];
      final updatedSession = session.copyWith(
        pinned: isPinned ?? session.pinned,
        muted: isMuted ?? session.muted,
      );
      
      _mockData.sessions[sessionIndex] = updatedSession;
      _sessionController.add(_mockData.sessions);
      
      return Right(updatedSession);
    } catch (e) {
      return Left(ChatFailure(message: '更新会话本地状态失败: $e'));
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
    
    // 发送消息到流
    _messageController.add(newMessage);
  }
} 