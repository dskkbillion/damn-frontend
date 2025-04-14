import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart'; // For checking network connectivity
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart'; // For combining streams

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/i_chat_local_cache.dart';
import '../../domain/repositories/i_chat_realtime_service.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasources/local/chat_local_cache_impl.dart'; // Assuming concrete type for now
import '../datasources/remote/i_chat_remote_data_source.dart';
import '../models/message_model.dart'; // Needed for fromEntity
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';

/// 聊天仓库实现
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource _remoteDataSource;
  final IChatLocalCache _localCache;
  final IChatRealtimeService _realtimeService; // May be needed for some logic
  final Connectivity _connectivity = Connectivity(); // Utility to check network status
  final NetworkInfo _networkInfo; // Check connectivity

  // Stream controller to manage observing chat sessions combined from cache and realtime
  final StreamController<Either<Failure, List<ChatSession>>> _sessionsStreamController = StreamController.broadcast();
  // Stream controller to combine local cache and real-time updates for sessions
  // Using BehaviorSubject to immediately provide the last known value (from cache)
  final BehaviorSubject<List<ChatSession>> _sessionsSubject = BehaviorSubject();
  // Map to hold message subjects for different chats
  final Map<int, BehaviorSubject<List<Message>>> _messageSubjects = {};
  StreamSubscription? _realtimeMessageSubscription;

  ChatRepositoryImpl(
    this._remoteDataSource,
    this._localCache,
    this._realtimeService,
    this._networkInfo,
  ) {
    // Initialize session observation
    _initSessionObservation();
  }

  /// Initialize observing sessions from cache and reacting to realtime updates.
  void _initSessionObservation() {
    // 1. Emit cached sessions initially
    _emitCachedSessions();

    // 2. Listen to incoming messages to update sessions
    _realtimeService.incomingMessages.listen((newMessage) async {
      // When a new message arrives, update the corresponding session in cache
      // and re-emit the full list from cache.
      // This is a simple strategy; more complex logic might be needed for ordering/unread counts.
      await _updateSessionFromNewMessage(newMessage);
      _emitCachedSessions(); // Re-emit updated list from cache
    }, onError: (error) {
      // Handle errors from the message stream if necessary
      _sessionsStreamController.add(Left(Failure("Error observing messages: $error")));
    });

     // TODO: Listen to other events that might affect sessions (e.g., read status changes)
  }

  Future<void> _emitCachedSessions() async {
    try {
      final cachedSessions = await _localCache.getChatSessions();
      _sessionsStreamController.add(Right(cachedSessions));
    } catch (e,s) {
       _sessionsStreamController.add(Left(CacheFailure("Failed to load cached sessions: $e", stackTrace: s)));
    }
  }

  Future<void> _updateSessionFromNewMessage(Message newMessage) async {
      try {
         final sessions = await _localCache.getChatSessions();
         final sessionIndex = sessions.indexWhere((s) => s.id == newMessage.chatId);
         if (sessionIndex != -1) {
           final updatedSession = sessions[sessionIndex].copyWith(
              chatMessageNewVo: newMessage, // Update last message
              context: newMessage.context, // Update context preview
              messageNum: sessions[sessionIndex].messageNum + 1 // Increment unread? Needs logic
           );
           // Update the specific session in cache (Hive might need a put method)
           // This assumes local cache can handle single session updates efficiently.
           // For simplicity now, we rely on re-emitting the whole list after cache update.
           await _localCache.saveChatSessions(sessions..[sessionIndex] = updatedSession); // Update list in place
         } else {
           // If session doesn't exist, fetch it or handle as needed
           print("Received message for non-cached session: ${newMessage.chatId}");
           // Potentially fetch all sessions again if a new session was created server-side
            await getChatSessions(); // Fetch and save all sessions
         }
      } catch (e, s) {
         print("Error updating session from new message: $e\n$s");
      }
  }

  @override
  Stream<Either<Failure, List<ChatSession>>> observeChatSessions() {
     // Return the controller's stream
     // Re-fetch from network periodically or on specific triggers if needed
     // to ensure cache doesn't get too stale.
     getChatSessions(); // Trigger initial network fetch when observation starts
     return _sessionsStreamController.stream;
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getChatSessions() async {
     final connectivityResult = await _connectivity.checkConnectivity();
     if (connectivityResult == ConnectivityResult.none) {
       // No network, try loading from cache only
       try {
         final cachedSessions = await _localCache.getChatSessions();
         return Right(cachedSessions);
       } catch (e, s) {
          return Left(CacheFailure("Failed to load sessions from cache: $e", stackTrace: s));
       }
     }

     // Network available, fetch from remote and update cache
     try {
       final remoteSessionsModel = await _remoteDataSource.getChatSessions();
       final remoteSessions = remoteSessionsModel.map((m) => m.toEntity()).toList();
       await _localCache.saveChatSessions(remoteSessions);
       // Emit updated list to observers
       _sessionsStreamController.add(Right(remoteSessions));
       return Right(remoteSessions);
     } on ServerException catch (e) {
       return Left(ServerFailure(e.message, error: e, code: e.code));
     } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, error: e));
     } catch (e, s) {
        print("Get Chat Sessions Error: $e\n$s");
        return Left(Failure('Failed to get chat sessions: ${e.toString()}', stackTrace: s));
     }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(int chatId) async {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No network, try loading from cache only
        try {
          final cachedMessages = await _localCache.getMessages(chatId);
          return Right(cachedMessages);
        } catch (e, s) {
          return Left(CacheFailure("Failed to load messages from cache for chat $chatId: $e", stackTrace: s));
        }
      }

      // Network available, fetch from remote and update cache
      try {
        final remoteMessagesModel = await _remoteDataSource.getMessages(chatId);
        final remoteMessages = remoteMessagesModel.map((m) => m.toEntity()).toList();
        // Cache saving strategy: Overwrite all messages for the chat
        await _localCache.saveMessages(chatId, remoteMessages);
        return Right(remoteMessages);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, error: e, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, error: e));
      } catch (e, s) {
        print("Get Messages Error for chat $chatId: $e\n$s");
        return Left(Failure('Failed to get messages for chat $chatId: ${e.toString()}', stackTrace: s));
      }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
     final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure("No internet connection to send message"));
      }

      try {
        // Convert Domain Entity to Data Model for sending
        // Note: We only send necessary fields (chatId, context, type)
         final messageToSend = MessageModel(
             id: -1, // Placeholder, not used by API
             chatId: message.chatId,
             context: message.context,
             typeString: message.typeString,
         );

        final sentMessageModel = await _remoteDataSource.sendMessage(
          chatId: messageToSend.chatId,
          context: messageToSend.context,
          typeString: messageToSend.typeString,
        );

        final sentMessageEntity = sentMessageModel.toEntity();

        // Update local cache with the message confirmed by the server
        await _localCache.addOrUpdateMessage(sentMessageEntity.copyWith(
            localId: message.localId, // Preserve localId if needed for UI updates
            sendStatus: message.sendStatus // Preserve original status? Or update to sent?
        ));

        // Update the session's last message in cache
        await _updateSessionFromNewMessage(sentMessageEntity);
        _emitCachedSessions(); // Emit updated session list

        return Right(sentMessageEntity);
      } on ServerException catch (e) {
         await _localCache.addOrUpdateMessage(message.copyWith(sendStatus: MessageSendStatus.failed));
         return Left(ServerFailure(e.message, error: e, code: e.code));
      } on NetworkException catch (e) {
         await _localCache.addOrUpdateMessage(message.copyWith(sendStatus: MessageSendStatus.failed));
         return Left(NetworkFailure(e.message, error: e));
      } catch (e, s) {
         print("Send Message Error: $e\n$s");
         await _localCache.addOrUpdateMessage(message.copyWith(sendStatus: MessageSendStatus.failed));
         return Left(Failure('Failed to send message: ${e.toString()}', stackTrace: s));
      }
  }

  @override
  Future<Either<Failure, void>> revokeMessage(int messageId) async {
       final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure("No internet connection to revoke message"));
      }
      try {
        await _remoteDataSource.revokeMessage(messageId);
        // Update local cache - mark message as revoked or delete?
        // Deleting is complex across boxes. Marking is easier.
        // Need to find the message, update its withdrawFlag, save it back.
        print("TODO: Update local cache for revoked message $messageId");
        // await _localCache.markMessageAsRevoked(messageId); // Needs implementation in local cache
        return Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, error: e, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, error: e));
      } catch (e, s) {
         print("Revoke Message Error: $e\n$s");
        return Left(Failure('Failed to revoke message: ${e.toString()}', stackTrace: s));
      }
  }

  @override
  Future<Either<Failure, void>> markSessionAsRead(int chatId) async {
    // API doesn't support this directly. We might just update the local cache state.
    try {
      final sessions = await _localCache.getChatSessions();
      final sessionIndex = sessions.indexWhere((s) => s.id == chatId);
      if (sessionIndex != -1) {
        if (sessions[sessionIndex].messageNum > 0) {
           final updatedSession = sessions[sessionIndex].copyWith(messageNum: 0);
           await _localCache.saveChatSessions(sessions..[sessionIndex] = updatedSession); // Update list in place
           _emitCachedSessions(); // Emit updated list
        }
      }
       return Right(null);
    } catch (e, s) {
      return Left(CacheFailure("Failed to mark session $chatId as read in cache: $e", stackTrace: s));
    }
  }

  @override
  Future<Either<Failure, int>> createChatSession(int targetUserId) async {
       final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure("No internet connection to create chat session"));
      }
      try {
        final chatId = await _remoteDataSource.createChatSession(targetUserId);
        // Optionally fetch sessions again to update the list immediately
        getChatSessions();
        return Right(chatId);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, error: e, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, error: e));
      } catch (e, s) {
         print("Create Chat Session Error: $e\n$s");
        return Left(Failure('Failed to create chat session: ${e.toString()}', stackTrace: s));
      }
  }

  @override
  Future<Either<Failure, String>> uploadFile(File file, {Function(double)? onProgress}) async {
       final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure("No internet connection to upload file"));
      }
      try {
        // Pass the progress callback to the data source
        final url = await _remoteDataSource.uploadFile(file, onProgress: onProgress);
        return Right(url);
       } on ServerException catch (e) {
        return Left(ServerFailure(e.message, error: e, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, error: e));
      } catch (e, s) {
         print("Upload File Error: $e\n$s");
        return Left(Failure('Failed to upload file: ${e.toString()}', stackTrace: s));
      }
  }

   // Dispose stream controllers when the repository is no longer needed
  void dispose() {
    _sessionsStreamController.close();
  }
}

// Helper required for network check
nothing_here_yet4() {} 