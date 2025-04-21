import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart'; // Needed for currentUserId
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';

// Data sources interfaces
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';
// Import DTOs if needed for stream mapping
import 'package:dskk_flutter_refactor/features/chat/data/models/chat_message_dto.dart';
// import '../datasources/i_chat_local_data_source.dart'; // Import if using local cache
import 'package:injectable/injectable.dart'; // Import injectable
// import 'package:dskk_flutter_refactor/core/platform/network_info.dart'; // Import if checking network status


@LazySingleton(as: IChatRepository) // Add annotation
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource remoteDataSource;
  final IChatWebSocketDataSource webSocketDataSource; // Add WebSocket DataSource
  final IUserRepository userRepository; // Inject UserRepository to get current user ID
  // final IChatLocalDataSource localDataSource; // Add if implementing caching
  // final NetworkInfo networkInfo; // Add if checking network status

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketDataSource, // Inject WS DataSource
    required this.userRepository,
    // required this.localDataSource,
    // required this.networkInfo,
  });

  // Helper to get current user ID
  Future<Either<Failure, int>> _getCurrentUserId() async {
    final userResult = await userRepository.getCurrentUser();
    return userResult.fold(
      (failure) => Left(failure),
      (user) => Right(user.id),
    );
  }

  // Helper to wrap remote calls and handle exceptions
  Future<Either<Failure, T>> _handleRemoteCall<T>(
      Future<T> Function() call) async {
    // TODO: Check network connection using networkInfo if available
    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode?.toString() ?? 'UNKNOWN'));
    } catch (e) {
      print("Unexpected error in Repository: $e");
      return Left(GeneralFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatRoom>>> getChatRooms() async {
     return _handleRemoteCall(() async {
       final userResult = await _getCurrentUserId();
       return await userResult.fold(
         (failure) => throw failure, // Re-throw Failure to be caught by _handleRemoteCall
         (userId) async {
           final chatRoomDtos = await remoteDataSource.getChatRooms();
           // Convert DTOs to Entities
           return chatRoomDtos.map((dto) => dto.toEntity(currentUserId: userId)).toList();
         },
       );
     });
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int chatId) async {
     return _handleRemoteCall(() async {
       final userResult = await _getCurrentUserId();
       return await userResult.fold(
         (failure) => throw failure, // Re-throw
         (userId) async {
           final messageDtos = await remoteDataSource.getMessages(chatId);
           // Convert DTOs to Entities, calculating senderId
           return messageDtos.map((dto) {
                final senderId = dto.memberId ?? dto.doctorId ?? 0;
                return dto.toEntity(currentUserId: userId, senderId: senderId);
            }).toList();
         },
       );
     });
  }

   @override
  Future<Either<Failure, ChatRoom>> getRoomDetails(int chatId) async {
     return _handleRemoteCall(() async {
       final userResult = await _getCurrentUserId();
       return await userResult.fold(
         (failure) => throw failure, // Re-throw
         (userId) async {
           final roomDto = await remoteDataSource.getRoomDetails(chatId);
           return roomDto.toEntity(currentUserId: userId);
         },
       );
     });
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
     // sendMessage in remoteDataSource expects ChatMessage entity
     return _handleRemoteCall(() async {
         final userResult = await _getCurrentUserId();
         return await userResult.fold(
           (failure) => throw failure, // Re-throw
           (userId) async {
              final sentMessageDto = await remoteDataSource.sendMessage(message);
              final senderId = sentMessageDto.memberId ?? sentMessageDto.doctorId ?? 0;
              return sentMessageDto.toEntity(currentUserId: userId, senderId: senderId);
           }
         );
     });
  }

  @override
  Future<Either<Failure, int>> createRoom(int participantId) async {
    return _handleRemoteCall(() => remoteDataSource.createRoom(participantId));
  }

  @override
  Future<Either<Failure, void>> revokeMessage(int messageId) async {
     return _handleRemoteCall(() => remoteDataSource.revokeMessage(messageId));
  }

  @override
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId) async {
     return _handleRemoteCall(() => remoteDataSource.deleteChatMessages(messageIds, chatId));
  }

  @override
  Stream<Either<Failure, ChatMessage>> get messageStream {
     // Map the DTO stream from WebSocket to an Entity stream
     // Also wrap it in Either to handle potential stream errors or parsing errors
    return webSocketDataSource.messageStream.asyncMap((messageDto) async {
       try {
         final userResult = await _getCurrentUserId();
         return await userResult.fold(
           (failure) => Left<Failure, ChatMessage>(failure),
           (userId) {
             final senderId = messageDto.memberId ?? messageDto.doctorId ?? 0;
             if (senderId == 0) {
                print("Error: Received WebSocket DTO with no sender ID: ${messageDto.toJson()}");
                return Left<Failure, ChatMessage>(GeneralFailure());
             }
             final entity = messageDto.toEntity(currentUserId: userId, senderId: senderId);
             return Right<Failure, ChatMessage>(entity);
           },
         );
       } catch (e) {
          print("Error processing WebSocket message in Repository: $e");
          return Left<Failure, ChatMessage>(GeneralFailure());
       }
     }).handleError((error) {
       print("WebSocket Stream Error in Repository: $error");
       // Handle stream-level errors (e.g., connection closed unexpectedly)
       // Returning a failure, but might need more specific error mapping
       return Left<Failure, ChatMessage>(NetworkFailure(message: "WebSocket connection error"));
     });
   }
} 