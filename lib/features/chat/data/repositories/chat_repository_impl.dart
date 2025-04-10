import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_websocket_service.dart';
import '../models/models.dart';

/// 聊天仓库实现
class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;
  final ChatWebSocketServiceImpl webSocketService;
  final NetworkInfo networkInfo;
  final uuid = const Uuid();
  
  // 流控制器
  final _messagesController = StreamController<Message>.broadcast();
  final _messageStatusController = StreamController<MessageStatusUpdate>.broadcast();
  
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.webSocketService,
    required this.networkInfo,
  }) {
    // 初始化WebSocket消息监听
    _initWebSocketListeners();
  }
  
  /// 初始化WebSocket消息监听
  void _initWebSocketListeners() {
    // 监听WebSocket消息
    webSocketService.incomingMessages.listen((incomingMessage) {
      try {
        // 将DTO转换为领域实体
        final messageDto = MessageDto(
          id: incomingMessage.id,
          sessionId: incomingMessage.sessionId ?? '',
          content: incomingMessage.content,
          senderId: incomingMessage.senderId,
          receiverId: '', // 这需要从上下文中获取
          type: incomingMessage.type ?? 'text',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        
        // 缓存消息
        localDataSource.cacheMessage(messageDto);
        
        // 发送到消息流
        _messagesController.add(messageDto.toDomain());
      } catch (e) {
        print('Error processing WebSocket message: $e');
      }
    });
    
    // 监听连接状态变化
    webSocketService.connectionStatus.listen((status) {
      print('WebSocket connection status: $status');
    });
  }
  
  @override
  Stream<List<ChatSession>> getChatSessions() async* {
    try {
      // 首先获取本地会话
      yield await localDataSource.getSessions();
      
      // 如果有网络连接，从远程获取并更新本地
      if (await networkInfo.isConnected) {
        try {
          final remoteSessions = await remoteDataSource.getChatSessions();
          await localDataSource.saveSessions(
            remoteSessions.map((dto) => dto.toDomain()).toList()
          );
          yield await localDataSource.getSessions();
        } catch (e) {
          // 远程获取失败，仍然使用本地数据
          print('Failed to get remote sessions: $e');
        }
      }
    } catch (e) {
      print('Error in getChatSessions: $e');
      yield [];
    }
  }
  
  @override
  Future<Either<Failure, void>> markSessionAsRead(String sessionId) async {
    try {
      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 尝试在远程标记为已读
        await remoteDataSource.markSessionAsRead(sessionId);
      }
      
      // 无论远程是否成功，都在本地更新
      await localDataSource.updateSessionReadStatus(sessionId);
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateSessionStatus(String sessionId, SessionStatus status) async {
    // 目前API可能不支持此功能，但在本地实现
    try {
      // 获取会话
      final sessionDto = await localDataSource.getSession(sessionId);
      if (sessionDto == null) {
        return Left(ChatFailure(message: 'Session not found', code: 'SESSION_NOT_FOUND'));
      }
      
      // 更新会话状态
      // 注意：这里可能需要根据SessionStatus枚举调整
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 尝试在远程删除
        await remoteDataSource.deleteSession(sessionId);
      }
      
      // 清除本地会话消息
      await localDataSource.clearSessionMessages(sessionId);
      
      // 在本地删除会话
      // 注意：可能需要实现删除会话的方法
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, ChatSession>> getSessionDetail(String sessionId) async {
    try {
      // 首先检查本地
      final localSession = await localDataSource.getSession(sessionId);
      
      // 如果有网络连接，从远程获取并更新本地
      if (await networkInfo.isConnected) {
        try {
          final remoteSession = await remoteDataSource.getSessionDetail(sessionId);
          await localDataSource.saveSession(remoteSession);
          return Right(remoteSession.toDomain());
        } catch (e) {
          // 远程获取失败，如果本地有数据，则使用本地数据
          if (localSession != null) {
            return Right(localSession.toDomain());
          }
          return Left(ServerFailure(
            message: e is ServerException ? e.message : e.toString(),
            code: e is ServerException ? e.statusCode.toString() : 'UNKNOWN',
          ));
        }
      } else if (localSession != null) {
        // 无网络但本地有数据
        return Right(localSession.toDomain());
      } else {
        // 无网络且本地无数据
        return Left(NetworkFailure(message: 'No network connection and no local data'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, ChatSession>> createSession(String targetUserId, {Message? initialMessage}) async {
    try {
      // 检查网络连接
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No network connection'));
      }
      
      // 转换初始消息（如果有）
      MessageDto? initialMessageDto;
      if (initialMessage != null) {
        initialMessageDto = MessageDto.fromDomain(initialMessage);
      }
      
      // 在远程创建会话
      final remoteSession = await remoteDataSource.createSession(targetUserId, initialMessage: initialMessageDto);
      
      // 在本地保存会话
      await localDataSource.saveSession(remoteSession);
      
      return Right(remoteSession.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, List<Message>>> getMessages(String sessionId, String? beforeMessageId, int limit) async {
    try {
      // 首先获取本地消息
      final localMessages = await localDataSource.getMessages(sessionId, limit, beforeMessageId);
      
      // 如果有网络连接，从远程获取
      if (await networkInfo.isConnected) {
        try {
          final remoteMessages = await remoteDataSource.getMessages(
            sessionId,
            beforeMessageId: beforeMessageId,
            limit: limit,
          );
          
          // 缓存远程消息
          await localDataSource.cacheMessages(
            sessionId,
            remoteMessages,
          );
          
          // 返回远程消息
          return Right(remoteMessages.map((dto) => dto.toDomain()).toList());
        } catch (e) {
          // 远程获取失败，使用本地数据
          return Right(localMessages);
        }
      } else {
        // 无网络，使用本地数据
        return Right(localMessages);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      // 生成临时消息ID（如果没有）
      final messageId = message.id.isEmpty ? uuid.v4() : message.id;
      
      // 创建待发送的消息
      final messageToSend = message.copyWith(
        id: messageId,
        status: MessageStatus.SENDING,
        syncStatus: MessageSyncStatus.PENDING,
        timestamp: DateTime.now(),
      );
      
      // 先保存到本地
      await localDataSource.saveMessages(message.sessionId, [messageToSend]);
      
      // 转换为DTO
      final messageDto = MessageDto.fromDomain(messageToSend);
      
      // 检查网络连接
      if (await networkInfo.isConnected) {
        try {
          // 发送到服务器
          final sentMessageDto = await remoteDataSource.sendMessage(messageDto);
          
          // 更新本地消息状态
          final sentMessage = sentMessageDto.toDomain().copyWith(
            status: MessageStatus.SENT,
            syncStatus: MessageSyncStatus.SYNCED,
          );
          
          // 更新本地消息
          await localDataSource.saveMessages(message.sessionId, [sentMessage]);
          
          return Right(sentMessage);
        } catch (e) {
          // 发送失败，更新状态
          final failedMessage = messageToSend.copyWith(
            status: MessageStatus.FAILED,
            syncStatus: MessageSyncStatus.FAILED,
            error: ChatError(
              code: e is ServerException ? e.statusCode.toString() : 'UNKNOWN',
              message: e is ServerException ? e.message : e.toString(),
            ),
          );
          
          // 更新本地消息
          await localDataSource.saveMessages(message.sessionId, [failedMessage]);
          
          return Left(ServerFailure(
            message: e is ServerException ? e.message : e.toString(),
            code: e is ServerException ? e.statusCode.toString() : 'UNKNOWN',
          ));
        }
      } else {
        // 无网络，仅保存到本地
        final offlineMessage = messageToSend.copyWith(
          status: MessageStatus.FAILED,
          syncStatus: MessageSyncStatus.FAILED,
          error: const ChatError(
            code: 'OFFLINE',
            message: 'No network connection',
          ),
        );
        
        // 更新本地消息
        await localDataSource.saveMessages(message.sessionId, [offlineMessage]);
        
        return Left(NetworkFailure(message: 'No network connection'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, void>> revokeMessage(String messageId) async {
    try {
      // 检查网络连接
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No network connection'));
      }
      
      // 在远程撤回消息
      await remoteDataSource.revokeMessage(messageId);
      
      // 更新本地消息状态
      await localDataSource.updateMessageStatus(messageId, MessageStatus.REVOKED);
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 尝试在远程删除
        await remoteDataSource.deleteMessage(messageId);
      }
      
      // 更新本地消息状态
      // 注意：可能需要实现删除消息的方法
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode.toString()));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
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
    int attempts = 0;
    Either<Failure, T>? lastResult;
    
    while (attempts < maxRetries) {
      lastResult = await operation();
      
      // 如果成功或者不是网络错误，直接返回
      if (lastResult.isRight() || lastResult.fold(
        (failure) => failure is! NetworkFailure,
        (_) => false,
      )) {
        return lastResult;
      }
      
      // 增加尝试次数
      attempts++;
      
      // 指数退避策略
      await Future.delayed(Duration(seconds: 1 << attempts));
    }
    
    // 返回最后一次尝试的结果
    return lastResult!;
  }
  
  @override
  Future<Either<Failure, void>> clearError(String messageId) async {
    try {
      // 更新本地消息状态
      await localDataSource.updateMessageStatus(messageId, MessageStatus.FAILED);
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ChatFailure(message: e.toString(), code: 'UNKNOWN'));
    }
  }
  
  /// 释放资源
  void dispose() {
    _messagesController.close();
    _messageStatusController.close();
  }
} 