import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_enums.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/failures/chat_failure.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_session_dto.dart';
import '../models/message_dto.dart';

/// 聊天仓库实现
///
/// 实现IChatRepository接口，协调远程和本地数据源
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource _remoteDataSource;
  final ChatLocalDataSource _localDataSource;
  final StreamController<List<ChatSession>> _sessionStreamController;
  final StreamController<Message> _messageStreamController;
  final StreamController<MessageStatusUpdate> _statusUpdateStreamController;
  
  /// 当前用户ID
  final String _currentUserId;
  
  /// 创建一个聊天仓库实现
  ///
  /// [remoteDataSource] 远程数据源
  /// [localDataSource] 本地数据源
  /// [currentUserId] 当前用户ID
  ChatRepositoryImpl({
    required IChatRemoteDataSource remoteDataSource,
    required ChatLocalDataSource localDataSource,
    required String currentUserId,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _currentUserId = currentUserId,
       _sessionStreamController = StreamController<List<ChatSession>>.broadcast(),
       _messageStreamController = StreamController<Message>.broadcast(),
       _statusUpdateStreamController = StreamController<MessageStatusUpdate>.broadcast() {
    // 初始加载会话列表
    _loadSessions();
  }
  
  /// 加载会话列表并推送到流
  Future<void> _loadSessions() async {
    try {
      // 先从本地加载
      final localSessions = await _localDataSource.getSessions();
      _sessionStreamController.add(localSessions.map((dto) => dto.toEntity()).toList());
      
      // 然后从远程加载
      final remoteSessions = await _remoteDataSource.getChatSessions();
      await _localDataSource.saveSessions(remoteSessions);
      
      // 推送更新后的会话
      _sessionStreamController.add(remoteSessions.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      // 如果远程加载失败，仍然使用本地数据
      print('加载会话失败: $e');
    }
  }
  
  @override
  Stream<List<ChatSession>> getChatSessions() {
    // 刷新会话列表
    _loadSessions();
    return _sessionStreamController.stream;
  }
  
  @override
  Future<Either<ChatFailure, ChatSession>> getSessionDetail(String sessionId) async {
    try {
      // 先尝试从本地获取
      final localSession = await _localDataSource.getSession(sessionId);
      
      try {
        // 然后从远程获取
        final remoteSession = await _remoteDataSource.getSessionDetail(sessionId);
        await _localDataSource.saveSession(remoteSession);
        return Right(remoteSession.toEntity());
      } catch (e) {
        // 如果远程获取失败但本地有数据，使用本地数据
        if (localSession != null) {
          return Right(localSession.toEntity());
        }
        
        return Left(NetworkFailure(message: '获取会话详情失败: $e'));
      }
    } catch (e) {
      return Left(UnexpectedFailure(message: '获取会话详情失败: $e'));
    }
  }
  
  @override
  Future<Either<ChatFailure, ChatSession>> createSession({
    required String targetUserId,
    Message? initialMessage,
  }) async {
    try {
      // 检查是否有网络连接
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure(message: '无网络连接，无法创建会话'));
      }
      
      // 从远程创建会话
      final sessionDto = await _remoteDataSource.createSession(targetUserId);
      await _localDataSource.saveSession(sessionDto);
      
      final session = sessionDto.toEntity();
      
      // 如果有初始消息，发送它
      if (initialMessage != null) {
        final messageDto = MessageDto.fromEntity(initialMessage);
        final sentMessageDto = await _remoteDataSource.sendMessage(messageDto);
        await _localDataSource.saveMessage(sentMessageDto);
        
        // 更新会话的最后一条消息
        final updatedSession = session.withMessage(sentMessageDto.toEntity());
        await _localDataSource.saveSession(ChatSessionDto.fromEntity(updatedSession));
        
        // 刷新会话列表
        _loadSessions();
        
        return Right(updatedSession);
      }
      
      // 刷新会话列表
      _loadSessions();
      
      return Right(session);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, void>> markSessionAsRead(String sessionId) async {
    try {
      // 先更新本地数据
      await _localDataSource.updateSessionReadStatus(sessionId);
      
      // 尝试更新远程数据
      try {
        await _remoteDataSource.markSessionAsRead(sessionId);
      } catch (e) {
        print('远程标记会话已读失败: $e');
        // 远程更新失败不阻止本地操作
      }
      
      // 刷新会话列表
      _loadSessions();
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, void>> updateSessionStatus(
    String sessionId,
    SessionStatus status,
  ) async {
    try {
      final statusStr = _mapSessionStatusToString(status);
      
      try {
        // 尝试更新远程数据
        await _remoteDataSource.updateSessionStatus(sessionId, statusStr);
      } catch (e) {
        return Left(NetworkFailure(message: '更新会话状态失败: $e'));
      }
      
      // 刷新会话列表
      _loadSessions();
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, void>> deleteSession(String sessionId) async {
    try {
      // 先删除本地数据
      await _localDataSource.deleteSession(sessionId);
      
      // 尝试删除远程数据
      try {
        await _remoteDataSource.deleteSession(sessionId);
      } catch (e) {
        print('远程删除会话失败: $e');
        // 远程删除失败不阻止本地操作
      }
      
      // 刷新会话列表
      _loadSessions();
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, List<Message>>> getMessages(
    String sessionId,
    String? beforeMessageId,
    int limit,
  ) async {
    try {
      // 先从本地获取
      final localMessages = await _localDataSource.getMessages(
        sessionId,
        limit,
        beforeMessageId,
      );
      
      // 如果本地有足够的消息，或者没有网络，直接返回本地数据
      if (localMessages.length >= limit || await _isOffline()) {
        return Right(localMessages.map((dto) => dto.toEntity()).toList());
      }
      
      // 尝试从远程获取
      try {
        final remoteMessages = await _remoteDataSource.getMessages(
          sessionId,
          beforeMessageId,
          limit,
        );
        
        // 保存到本地
        await _localDataSource.saveMessages(sessionId, remoteMessages);
        
        return Right(remoteMessages.map((dto) => dto.toEntity()).toList());
      } catch (e) {
        // 如果远程获取失败，返回本地数据
        return Right(localMessages.map((dto) => dto.toEntity()).toList());
      }
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, Message>> sendMessage(Message message) async {
    try {
      // 检查网络连接
      if (await _isOffline()) {
        // 保存为本地待发送消息
        final pendingMessage = message.copyWith(
          syncStatus: MessageSyncStatus.PENDING,
          status: MessageStatus.SENDING,
        );
        
        await _localDataSource.saveMessage(MessageDto.fromEntity(pendingMessage));
        
        // 更新会话的最后一条消息
        final session = await _getOrCreateLocalSession(pendingMessage);
        final updatedSession = session.withMessage(pendingMessage);
        await _localDataSource.saveSession(ChatSessionDto.fromEntity(updatedSession));
        
        // 刷新会话列表
        _loadSessions();
        
        return Left(NetworkFailure(message: '无网络连接，消息已保存为待发送'));
      }
      
      // 发送消息到远程
      final messageDto = MessageDto.fromEntity(message);
      
      try {
        final sentMessageDto = await _remoteDataSource.sendMessage(messageDto);
        await _localDataSource.saveMessage(sentMessageDto);
        
        final sentMessage = sentMessageDto.toEntity();
        
        // 更新会话的最后一条消息
        final session = await _getOrCreateLocalSession(sentMessage);
        final updatedSession = session.withMessage(sentMessage);
        await _localDataSource.saveSession(ChatSessionDto.fromEntity(updatedSession));
        
        // 刷新会话列表
        _loadSessions();
        
        return Right(sentMessage);
      } catch (e) {
        // 发送失败，保存为失败状态
        final failedMessage = message.copyWith(
          status: MessageStatus.FAILED,
          syncStatus: MessageSyncStatus.FAILED,
        );
        
        await _localDataSource.saveMessage(MessageDto.fromEntity(failedMessage));
        
        // 更新会话的最后一条消息
        final session = await _getOrCreateLocalSession(failedMessage);
        final updatedSession = session.withMessage(failedMessage);
        await _localDataSource.saveSession(ChatSessionDto.fromEntity(updatedSession));
        
        // 刷新会话列表
        _loadSessions();
        
        return Left(NetworkFailure(message: '发送消息失败: $e'));
      }
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, void>> revokeMessage(String messageId) async {
    try {
      // 先从本地获取消息
      final message = await _localDataSource.getMessage(messageId);
      if (message == null) {
        return Left(NotFoundFailure(message: '未找到消息: $messageId'));
      }
      
      // 检查是否是当前用户发送的消息
      if (message.senderId != _currentUserId) {
        return Left(PermissionFailure(message: '无法撤回其他用户的消息'));
      }
      
      // 更新本地消息状态
      await _localDataSource.updateMessageStatus(messageId, 'revoked');
      
      // 尝试撤回远程消息
      try {
        await _remoteDataSource.revokeMessage(messageId);
      } catch (e) {
        print('远程撤回消息失败: $e');
        // 远程操作失败不阻止本地操作
      }
      
      // 发出状态更新通知
      _statusUpdateStreamController.add(
        MessageStatusUpdate(messageId, MessageStatus.REVOKED),
      );
      
      // 刷新会话列表
      _loadSessions();
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, void>> deleteMessage(String messageId) async {
    try {
      // 先从本地获取消息
      final message = await _localDataSource.getMessage(messageId);
      if (message == null) {
        return Left(NotFoundFailure(message: '未找到消息: $messageId'));
      }
      
      // 更新本地消息状态
      await _localDataSource.markMessageAsDeleted(messageId);
      
      // 尝试删除远程消息
      try {
        await _remoteDataSource.deleteMessage(messageId);
      } catch (e) {
        print('远程删除消息失败: $e');
        // 远程操作失败不阻止本地操作
      }
      
      // 发出状态更新通知
      _statusUpdateStreamController.add(
        MessageStatusUpdate(messageId, MessageStatus.DELETED),
      );
      
      // 刷新会话列表
      _loadSessions();
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Stream<Message> observeMessages() {
    return _messageStreamController.stream;
  }
  
  @override
  Stream<MessageStatusUpdate> observeMessageStatusUpdates() {
    return _statusUpdateStreamController.stream;
  }
  
  @override
  Future<Either<ChatFailure, T>> retryOperation<T>(
    Future<Either<ChatFailure, T>> Function() operation,
    int maxRetries,
  ) async {
    int attempts = 0;
    late Either<ChatFailure, T> result;
    
    do {
      result = await operation();
      attempts++;
      
      // 如果成功或已达到最大重试次数，停止重试
      if (result.isRight() || attempts >= maxRetries) {
        break;
      }
      
      // 指数退避重试
      await Future.delayed(Duration(seconds: 1 << (attempts - 1)));
    } while (true);
    
    return result;
  }
  
  @override
  Future<Either<ChatFailure, void>> clearError(String messageId) async {
    try {
      final message = await _localDataSource.getMessage(messageId);
      if (message == null) {
        return Left(NotFoundFailure(message: '未找到消息: $messageId'));
      }
      
      await _localDataSource.updateMessageStatus(messageId, 'sending');
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, List<Message>>> batchLoadMessages(
    String sessionId,
    DateTime fromTimestamp,
    int limit,
  ) async {
    try {
      // 先从本地获取从该时间戳之后的消息
      final localMessages = await _localDataSource.getMessages(
        sessionId,
        limit,
        null, // 不使用beforeMessageId
      );
      
      // 如果没有网络，只返回本地数据
      if (await _isOffline()) {
        return Right(localMessages.map((dto) => dto.toEntity()).toList());
      }
      
      // 尝试从远程获取
      try {
        final remoteMessages = await _remoteDataSource.batchLoadMessages(
          sessionId,
          fromTimestamp.toIso8601String(),
          limit,
        );
        
        // 保存到本地
        await _localDataSource.saveMessages(sessionId, remoteMessages);
        
        return Right(remoteMessages.map((dto) => dto.toEntity()).toList());
      } catch (e) {
        // 如果远程获取失败，返回本地数据
        return Right(localMessages.map((dto) => dto.toEntity()).toList());
      }
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, List<Message>>> searchMessages(
    String query, {
    String? sessionId,
  }) async {
    try {
      // 先从本地搜索
      final localResults = await _localDataSource.searchMessages(
        query,
        sessionId: sessionId,
      );
      
      // 如果没有网络，只返回本地结果
      if (await _isOffline()) {
        return Right(localResults.map((dto) => dto.toEntity()).toList());
      }
      
      // 尝试从远程搜索
      try {
        final remoteResults = await _remoteDataSource.searchMessages(
          query,
          sessionId: sessionId,
        );
        
        // 保存到本地
        if (sessionId != null) {
          await _localDataSource.saveMessages(sessionId, remoteResults);
        } else {
          for (final message in remoteResults) {
            await _localDataSource.saveMessage(message);
          }
        }
        
        return Right(remoteResults.map((dto) => dto.toEntity()).toList());
      } catch (e) {
        // 如果远程搜索失败，返回本地结果
        return Right(localResults.map((dto) => dto.toEntity()).toList());
      }
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<ChatFailure, ChatSession>> updateLocalSessionState(
    String sessionId, {
    bool? isPinned,
    bool? isMuted,
  }) async {
    try {
      await _localDataSource.updateSessionLocalState(
        sessionId,
        isPinned: isPinned,
        isMuted: isMuted,
      );
      
      final session = await _localDataSource.getSession(sessionId);
      if (session == null) {
        return Left(NotFoundFailure(message: '未找到会话: $sessionId'));
      }
      
      // 刷新会话列表
      _loadSessions();
      
      return Right(session.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  /// 检查是否离线
  Future<bool> _isOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }
  
  /// 获取或创建本地会话
  Future<ChatSession> _getOrCreateLocalSession(Message message) async {
    final sessionId = message.sessionId;
    final existingSession = await _localDataSource.getSession(sessionId);
    
    if (existingSession != null) {
      return existingSession.toEntity();
    }
    
    // 如果会话不存在，创建一个新的本地会话
    final targetUserId = message.senderId == _currentUserId
        ? message.receiverId
        : message.senderId;
    
    final session = ChatSession.create(
      id: sessionId,
      title: 'Chat with $targetUserId', // 临时标题，实际应用中应该显示用户名
      userId: _currentUserId,
      targetUserId: targetUserId,
    );
    
    await _localDataSource.saveSession(ChatSessionDto.fromEntity(session));
    return session;
  }
  
  /// 将异常映射为故障
  ChatFailure _mapExceptionToFailure(Exception e) {
    if (e is TimeoutException) {
      return const NetworkFailure(message: '请求超时');
    }
    return UnexpectedFailure(message: e.toString(), error: e);
  }
  
  /// 会话状态转字符串
  String _mapSessionStatusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.ACTIVE:
        return 'active';
      case SessionStatus.ARCHIVED:
        return 'archived';
      case SessionStatus.BLOCKED:
        return 'blocked';
    }
  }
  
  /// 释放资源
  void dispose() {
    _sessionStreamController.close();
    _messageStreamController.close();
    _statusUpdateStreamController.close();
  }
} 