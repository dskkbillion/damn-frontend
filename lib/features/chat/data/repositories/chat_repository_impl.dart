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
        print("Unexpected error in getChatRooms Repository: $e");
        return Left(GeneralFailure(message: '读取聊天室列表失败'));
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
               // 根据消息中的memberId和doctorId判断senderId
               // 如果只有memberId有值，说明是买家发送的
               // 如果只有doctorId有值，说明是卖家发送的
               // 如果两者都有值，可能需要其他逻辑判断
               int senderId;
               if (dto.memberId != null && dto.doctorId == null) {
                 senderId = dto.memberId!;
                 print("[Repository] 消息${dto.id}: 只有memberId(${dto.memberId})，判断为买家发送");
               } else if (dto.doctorId != null && dto.memberId == null) {
                 senderId = dto.doctorId!;
                 print("[Repository] 消息${dto.id}: 只有doctorId(${dto.doctorId})，判断为卖家发送");
               } else if (dto.memberId != null && dto.doctorId != null) {
                 // 两者都有值，需要根据其他逻辑判断
                 // 暂时使用优先memberId的逻辑，但这可能不正确
                 senderId = dto.memberId!;
                 print("[Repository] 消息${dto.id}: memberId(${dto.memberId})和doctorId(${dto.doctorId})都有值，暂时使用memberId作为senderId");
               } else {
                 senderId = 0;
                 print("[Repository] 消息${dto.id}: memberId和doctorId都为空，设置senderId为0");
               }
               
               return dto.toEntity(currentUserId: user.id, senderId: senderId);
             }).toList();
             return Right(messages);
           } on ServerException catch (e) {
             return Left(ServerFailure(message: e.message ?? 'Server error', code: e.statusCode?.toString()));
           }
         },
       );
    } catch (e) {
       print("Unexpected error in getMessages Repository: $e");
       return Left(GeneralFailure(message: '读取聊天消息失败'));
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
       print("Unexpected error in getRoomDetails Repository: $e");
       return Left(GeneralFailure(message: '读取聊天室详情失败'));
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
             
             // 根据消息中的memberId和doctorId判断senderId
             int senderParticipantId;
             if (sentMessageDto.memberId != null && sentMessageDto.doctorId == null) {
               senderParticipantId = sentMessageDto.memberId!;
               print("[Repository] 发送的消息: 只有memberId(${sentMessageDto.memberId})，判断为买家发送");
             } else if (sentMessageDto.doctorId != null && sentMessageDto.memberId == null) {
               senderParticipantId = sentMessageDto.doctorId!;
               print("[Repository] 发送的消息: 只有doctorId(${sentMessageDto.doctorId})，判断为卖家发送");
             } else if (sentMessageDto.memberId != null && sentMessageDto.doctorId != null) {
               // 两者都有值，需要根据其他逻辑判断
               senderParticipantId = sentMessageDto.memberId!;
               print("[Repository] 发送的消息: memberId(${sentMessageDto.memberId})和doctorId(${sentMessageDto.doctorId})都有值，暂时使用memberId作为senderId");
             } else {
               senderParticipantId = 0;
               print("[Repository] 发送的消息: memberId和doctorId都为空，设置senderId为0");
             }
             
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
       print("Unexpected error in sendMessage Repository: $e");
       // FIX: Use correct GeneralFailure constructor (no message)
       return Left(GeneralFailure(message: '发送消息失败'));
    }
  }

  @override
  Future<Either<Failure, int>> createRoom(
    int participantId, {
    int? productId, // 新增可选的商品ID参数
  }) async {
     print("[Repository] Creating room with participantId: $participantId, productId: $productId");
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
       print("[Repository] Unexpected error creating room: $e");
       return Left(GeneralFailure(message: '创建聊天室失败'));
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
      print("Unexpected error in revokeMessage Repository: $e");
      return Left(GeneralFailure(message: '撤回消息失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChatMessages(List<int> messageIds, int chatId) {
     // TODO: Implement deleteChatMessages
    throw UnimplementedError();
  }
} 