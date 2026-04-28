import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
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
  Future<Either<Failure, List<ChatRoom>>> getChatRooms() async {
    // TODO: Check network connection using networkInfo if available
    // if (await networkInfo.isConnected) {
      try {
        final userResult = await userRepository.getCurrentUser();
        return await userResult.fold(
          (failure) => Left(failure), // Propagate user fetch failure
          (user) async {
            try {
              final chatRoomDtos = await remoteDataSource.getChatRooms();
              // Map DTOs to Entities
              final chatRooms = chatRoomDtos.map<ChatRoom>((dto) => dto.toEntity(currentUserId: user.id)).toList();
              return Right(chatRooms);
            } on ServerException catch (e) {
              return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
            }
          },
        );
      } catch (e) {
        // Catch unexpected errors during user fetch or API call
        AppLogger.d("Unexpected error in getChatRooms Repository: $e");
        return const Left(GeneralFailure(message: '读取聊天室列表失败'));
      }
    // } else {
    //   // Handle no network connection case if needed
    //   return Left(NetworkFailure()); 
    // }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int chatId, {int pageNum = 1, int pageSize = 20}) async {
    // TODO: Implement getMessages similar to getChatRooms
    // Need to fetch current user ID to pass to toEntity
    try {
       final userResult = await userRepository.getCurrentUser();
       return await userResult.fold(
         (failure) => Left(failure),
         (user) async {
           try {
             final messageDtos = await remoteDataSource.getMessages(chatId, pageNum: pageNum, pageSize: pageSize);

             final messages = messageDtos.map((dto) {
               // 后端契约：memberId = 发送者的 CommonUser.id，doctorId = 接收者的 CommonUser.id
               // 两个字段每条消息都有值，无需 fallback
               if (dto.memberId == null) {
                 throw ServerException(message: "消息 ${dto.id} 缺少 memberId，违反后端契约");
               }
               final senderId = dto.memberId!;
               return dto.toEntity(currentUserId: user.id, senderId: senderId);
             }).toList();
             return Right(messages);
           } on ServerException catch (e) {
             return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
           }
         },
       );
    } catch (e) {
       AppLogger.d("Unexpected error in getMessages Repository: $e");
       return const Left(GeneralFailure(message: '读取聊天消息失败'));
    }
  }

   @override
  Future<Either<Failure, ChatRoom>> getRoomDetails(int chatId) async {
     // TODO: Implement getRoomDetails similar to getChatRooms
    try {
       final userResult = await userRepository.getCurrentUser();
       return await userResult.fold(
         (failure) => Left(failure),
         (user) async {
           try {
             final roomDto = await remoteDataSource.getRoomDetails(chatId);
             return Right(roomDto.toEntity(currentUserId: user.id));
           } on ServerException catch (e) {
             return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
           }
         },
       );
    } catch (e) {
       AppLogger.d("Unexpected error in getRoomDetails Repository: $e");
       return const Left(GeneralFailure(message: '读取聊天室详情失败'));
    }
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
             
             // 获取聊天室详情以确定正确的senderId
             final roomDto = await remoteDataSource.getRoomDetails(message.chatId);
             final room = roomDto.toEntity(currentUserId: user.id);
             
            // 重要修正：在ChatRoomDto.toEntity中，participant1总是当前用户，participant2总是对方
            // 所以发送消息时，senderId应该总是使用participant1.id（当前用户）
            int senderParticipantId = room.participant1.id; // participant1总是当前用户

            AppLogger.d("[Repository] 发送的消息: 当前用户发送，senderId=$senderParticipantId");
            AppLogger.d("[Repository] 调试信息: participant1.id=${room.participant1.id} (当前用户), participant2.id=${room.participant2.id} (对方)");
            AppLogger.d("[Repository] 调试信息: user.id=${user.id}, user.type=${user.type}");
            AppLogger.d("[Repository] 调试信息: memberId=${sentMessageDto.memberId}, doctorId=${sentMessageDto.doctorId}");
 
             
             final sentMessageEntity = sentMessageDto.toEntity(
                currentUserId: user.id, // Pass commonUserId
                senderId: senderParticipantId 
              );
             return Right(sentMessageEntity);
           } on ServerException catch (e) {
             // FIX: Use correct ServerFailure constructor
             return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode.toString())); // Pass statusCode as string code
           }
         }
       );
    } catch (e) {
       AppLogger.d("Unexpected error in sendMessage Repository: $e");
       // FIX: Use correct GeneralFailure constructor (no message)
       return const Left(GeneralFailure(message: '发送消息失败'));
    }
  }

  @override
  Future<Either<Failure, int>> createRoom(
    int participantId, {
    int? productId, // 新增可选的商品ID参数
  }) async {
     AppLogger.d("[Repository] Creating room with participantId: $participantId, productId: $productId");
     // TODO: Check network connection if needed
     try {
       final chatId = await remoteDataSource.createRoom(
         participantId,
         productId: productId, // 传递productId给数据源
       );
       return Right(chatId);
     } on ServerException catch (e) {
       return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
     } catch (e) {
       AppLogger.d("[Repository] Unexpected error creating room: $e");
       return const Left(GeneralFailure(message: '创建聊天室失败'));
     }
  }

  @override
  Future<Either<Failure, void>> revokeMessage(int messageId) async {
    try {
      await remoteDataSource.revokeMessage(messageId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '撤回消息失败', code: e.statusCode?.toString()));
    } catch (e) {
      AppLogger.d("Unexpected error in revokeMessage Repository: $e");
      return Left(GeneralFailure(message: '撤回消息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId) {
     // TODO: Implement deleteChatMessages
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteChatRooms(List<int> chatIds) async {
    try {
      await remoteDataSource.deleteChatRooms(chatIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '删除聊天室失败', code: e.statusCode?.toString()));
    } catch (e) {
      AppLogger.d("Unexpected error in deleteChatRooms Repository: $e");
      return Left(GeneralFailure(message: '删除聊天室失败: ${e.toString()}'));
    }
  }
} 