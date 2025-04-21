import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart'; // Needed for currentUserId
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';

// Correct import for Interface using package path
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_remote_data_source.dart';
// import '../datasources/i_chat_local_data_source.dart'; // Import if using local cache
// import 'package:dskk_flutter_refactor/core/platform/network_info.dart'; // Import if checking network status


class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource remoteDataSource;
  final IUserRepository userRepository; // Inject UserRepository to get current user ID
  // final IChatLocalDataSource localDataSource; // Add if implementing caching
  // final NetworkInfo networkInfo; // Add if checking network status

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.userRepository,
    // required this.localDataSource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ChatRoom>>> getChatRooms() {
    // TODO: Implement getChatRooms
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int chatId) {
    // TODO: Implement getMessages
    throw UnimplementedError();
  }

   @override
  Future<Either<Failure, ChatRoom>> getRoomDetails(int chatId) {
    // TODO: Implement getRoomDetails
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
     // TODO: Check network connection using networkInfo if available

    try {
      // Get current user ID for entity conversion
      final userResult = await userRepository.getCurrentUser();
      return await userResult.fold(
         (failure) => Left(failure), // Propagate user fetch failure
         (user) async {
           try {
             final sentMessageDto = await remoteDataSource.sendMessage(message);
             
             // FIX: Determine sender participant ID before calling toEntity
             final int senderParticipantId = sentMessageDto.memberId ?? sentMessageDto.doctorId ?? 0;
             
             final sentMessageEntity = sentMessageDto.toEntity(
                currentUserId: user.id, // Pass commonUserId
                // FIX: Pass the determined sender participant ID
                senderId: senderParticipantId 
              );
             return Right(sentMessageEntity);
           } on ServerException catch (e) {
             // FIX: Use correct ServerFailure constructor
             return Left(ServerFailure(message: e.message, code: e.statusCode.toString())); // Pass statusCode as string code
           }
         }
       );
    } catch (e) {
       print("Unexpected error in sendMessage Repository: $e");
       // FIX: Use correct GeneralFailure constructor (no message)
       return Left(GeneralFailure());
    }
  }

  @override
  Future<Either<Failure, int>> createRoom(int participantId) {
    // TODO: Implement createRoom
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> revokeMessage(int messageId) {
     // TODO: Implement revokeMessage
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId) {
     // TODO: Implement deleteChatMessages
    throw UnimplementedError();
  }
} 