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
             
             // 首先获取聊天室详情以获取参与者信息
             final roomDto = await remoteDataSource.getRoomDetails(chatId);
             final room = roomDto.toEntity(currentUserId: user.id);
             
             final messages = messageDtos.map((dto) {
               // 根据React Native的逻辑：判断当前用户的referId是否等于member.referId
               // 如果相等，说明当前用户是买家（member），消息是买家发送的
               // 如果不相等，说明当前用户是卖家（doctor），消息是卖家发送的
               
               // 重要：后端的member字段对应participant1，doctor字段对应participant2
               // memberId和doctorId是参与者的内部ID，不是referId
               
               int senderId;
               
               // 判断发送者的逻辑：
               // 1. 如果memberId有值而doctorId为空，说明是买家（participant1）发送的
               // 2. 如果doctorId有值而memberId为空，说明是卖家（participant2）发送的
               // 3. 如果两者都有值（这种情况不应该出现），需要额外判断
               
               if (dto.memberId != null && dto.doctorId == null) {
                 // 买家发送的消息，使用participant1的内部ID作为senderId
                 senderId = room.participant1.id;
                 print("[Repository] 消息${dto.id}: memberId=${dto.memberId}, 买家(participant1)发送, senderId=${senderId}");
               } else if (dto.doctorId != null && dto.memberId == null) {
                 // 卖家发送的消息，使用participant2的内部ID作为senderId
                 senderId = room.participant2.id;
                 print("[Repository] 消息${dto.id}: doctorId=${dto.doctorId}, 卖家(participant2)发送, senderId=${senderId}");
               } else if (dto.memberId != null && dto.doctorId != null) {
                 // 两者都有值的情况（理论上不应该出现）
                 // 根据当前用户类型判断：如果当前用户是买家，那么有memberId的消息是当前用户发送的
                 if (user.type == 'MEMBER') {
                   senderId = room.participant1.id; // 买家是participant1
                   print("[Repository] 消息${dto.id}: 两者都有值，当前用户是买家，使用participant1.id作为senderId=${senderId}");
                 } else {
                   senderId = room.participant2.id; // 卖家是participant2
                   print("[Repository] 消息${dto.id}: 两者都有值，当前用户是卖家，使用participant2.id作为senderId=${senderId}");
                 }
               } else {
                 // 两者都为空（不应该出现）
                 senderId = 0;
                 print("[Repository] 警告：消息${dto.id}: memberId和doctorId都为空");
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
             
             // 获取聊天室详情以确定正确的senderId
             final roomDto = await remoteDataSource.getRoomDetails(message.chatId);
             final room = roomDto.toEntity(currentUserId: user.id);
             
             // 根据消息中的memberId和doctorId判断senderId（使用participant的内部ID）
             int senderParticipantId;
             if (sentMessageDto.memberId != null && sentMessageDto.doctorId == null) {
               senderParticipantId = room.participant1.id; // 买家是participant1
               print("[Repository] 发送的消息: memberId=${sentMessageDto.memberId}，买家发送，senderId=${senderParticipantId}");
             } else if (sentMessageDto.doctorId != null && sentMessageDto.memberId == null) {
               senderParticipantId = room.participant2.id; // 卖家是participant2
               print("[Repository] 发送的消息: doctorId=${sentMessageDto.doctorId}，卖家发送，senderId=${senderParticipantId}");
             } else if (sentMessageDto.memberId != null && sentMessageDto.doctorId != null) {
               // 两者都有值，根据当前用户类型判断
               if (user.type == 'MEMBER') {
                 senderParticipantId = room.participant1.id; // 买家是participant1
                 print("[Repository] 发送的消息: 两者都有值，当前用户是买家，使用participant1.id作为senderId=${senderParticipantId}");
               } else {
                 senderParticipantId = room.participant2.id; // 卖家是participant2
                 print("[Repository] 发送的消息: 两者都有值，当前用户是卖家，使用participant2.id作为senderId=${senderParticipantId}");
               }
             } else {
               // 理论上不应该出现两者都为空的情况，使用当前用户对应的participant ID
               if (user.type == 'MEMBER') {
                 senderParticipantId = room.participant1.id;
               } else {
                 senderParticipantId = room.participant2.id;
               }
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