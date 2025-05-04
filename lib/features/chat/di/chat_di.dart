import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart'; // Import NetworkInfo
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/user.dart';
// 导入我们新创建的MockUserRepository
import 'package:dskk_flutter_refactor/features/chat/data/repositories/mocks/mock_user_repository.dart';

// Interfaces
import '../domain/repositories/i_chat_repository.dart';
import '../domain/repositories/i_file_repository.dart';
import '../data/datasources/i_chat_remote_data_source.dart';
import '../data/datasources/i_file_remote_data_source.dart';
import '../data/datasources/i_chat_web_socket_data_source.dart';

// Implementations
import '../data/repositories/chat_repository_impl.dart';
import '../data/repositories/file_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.impl.dart';
import '../data/datasources/file_remote_data_source.impl.dart';
import '../data/datasources/chat_web_socket_data_source.impl.dart';

// Use Cases
import '../domain/usecases/get_chat_room_list.dart';
import '../domain/usecases/get_message_list.dart';
import '../domain/usecases/send_message.dart';
import '../domain/usecases/revoke_message.dart';
import '../domain/usecases/get_chat_room_details.dart';
import '../domain/usecases/delete_chat_message.dart';
import '../domain/usecases/create_chat_room.dart';

// Blocs
import '../presentation/bloc/chat_list/chat_list_bloc.dart';
import '../presentation/bloc/chat_messages/chat_messages_bloc.dart';

/// 为聊天模块提供的临时用户信息仓库实现
/// 从SecureStorage中读取真实的用户信息，而不是使用模拟数据
class ChatUserRepositoryImpl implements IUserRepository {
  final FlutterSecureStorage _secureStorage;
  
  ChatUserRepositoryImpl(this._secureStorage);
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // 从SecureStorage读取用户ID和CommonUserId
      final userId = await _secureStorage.read(key: 'user_id');
      final commonUserId = await _secureStorage.read(key: 'common_user_id') ?? '1';
      
      // 调试：检查auth_token是否存在
      final authToken = await _secureStorage.read(key: 'auth_token');
      print('[ChatUserRepository] userId: $userId, commonUserId: $commonUserId');
      print('[ChatUserRepository] authToken存在: ${authToken != null}');
      
      if (userId == null) {
        return Left(AuthFailure(message: '未找到用户ID'));
      }
      
      // 修改：使用commonUserId作为User对象的id字段，而不是userId
      // commonUserId对应聊天室中参与者的referId，这是关键的匹配字段
      final user = User(
        id: int.tryParse(commonUserId) ?? 0, // 修改：使用commonUserId
        commonUserId: commonUserId,
        nickName: '用户${userId.substring(userId.length - 4)}',
        type: 'MEMBER',
      );
      
      print('[ChatUserRepository] 创建用户: id=${user.id}, commonUserId=${user.commonUserId}'); // 添加日志确认
      return Right(user);
    } catch (e) {
      print('[ChatUserRepository] 错误: $e'); // 添加更详细的错误日志
      return Left(GeneralFailure(message: '获取用户信息失败: $e'));
    }
  }
}

@module
abstract class ChatInjectableModule {

  // --- 提供命名的Mock实现用于测试 --- 
  @lazySingleton
  @Named('mockUserRepository')  // 使用Named注解来标识这是一个特定的mock实现
  IUserRepository get mockUserRepository => MockUserRepository();
  
  // 提供真实的IUserRepository实现
  @lazySingleton
  IUserRepository provideChatUserRepository() {
    print("注册聊天模块专用的用户仓库 (从SecureStorage读取真实数据)");
    return ChatUserRepositoryImpl(const FlutterSecureStorage());
  }

  // --- DataSources ---
  @lazySingleton
  IChatRemoteDataSource chatRemoteDataSource(Dio dio) =>
      ChatRemoteDataSourceImpl(dio: dio);

  @lazySingleton
  IFileRemoteDataSource fileRemoteDataSource(Dio dio) =>
      FileRemoteDataSourceImpl(dio: dio);

  @lazySingleton
  IChatWebSocketDataSource chatWebSocketDataSource() =>
      ChatWebSocketDataSourceImpl();

  // --- Repositories ---
  @lazySingleton
  IChatRepository chatRepository(
    IChatRemoteDataSource remoteDataSource,
    IUserRepository userRepository, // 直接使用注入的IUserRepository
  ) => ChatRepositoryImpl(
        remoteDataSource: remoteDataSource,
        userRepository: userRepository, // 使用注入的userRepository
      );

  @lazySingleton
  IFileRepository fileRepository(IFileRemoteDataSource remoteDataSource) =>
      FileRepositoryImpl(remoteDataSource: remoteDataSource);

  // --- Use Cases ---
  @lazySingleton
  GetChatRoomList getChatRoomList(IChatRepository repository) =>
      GetChatRoomListImpl(repository);

  @lazySingleton
  GetMessageList getMessageList(IChatRepository repository) =>
      GetMessageListImpl(repository);

  @lazySingleton
  SendMessage sendMessage(IChatRepository chatRepository, IFileRepository fileRepository) =>
      SendMessageImpl(chatRepository, fileRepository);

  @lazySingleton
  RevokeMessage revokeMessage(IChatRepository repository) =>
      RevokeMessageImpl(repository);
  
  @lazySingleton
  GetChatRoomDetails getChatRoomDetails(IChatRepository repository) =>
      GetChatRoomDetailsImpl(repository);

  @lazySingleton
  DeleteChatMessage deleteChatMessage(IChatRepository repository) =>
      DeleteChatMessageImpl(repository);

  @lazySingleton
  CreateChatRoom createChatRoom(IChatRepository repository) =>
      CreateChatRoomImpl(repository);

  // --- Blocs ---
  @injectable
  ChatListBloc chatListBloc(
    GetChatRoomList getChatRoomList,
    CreateChatRoom createChatRoom,
  ) => ChatListBloc(
        getChatRoomList: getChatRoomList,
        createChatRoom: createChatRoom,
      );
  
  // 注册ChatMessagesBloc
  // 我们无法直接在这里使用registerFactoryParam，因为InjectableModule是抽象类
  // 我们需要在初始化依赖时手动注册，添加下面这个方法作为注释提醒
  // 
  // 实际注册需要手动在main.dart或injection_container.dart中添加：
  //
  // getIt.registerFactoryParam<ChatMessagesBloc, int, void>(
  //   (chatId, _) => ChatMessagesBloc(
  //     chatId: chatId,
  //     getMessageList: getIt<GetMessageList>(),
  //     sendMessage: getIt<SendMessage>(),
  //     revokeMessage: getIt<RevokeMessage>(),
  //     getChatRoomDetails: getIt<GetChatRoomDetails>(),
  //     deleteChatMessage: getIt<DeleteChatMessage>(),
  //     userRepository: getIt<IUserRepository>(),
  //     webSocketDataSource: getIt<IChatWebSocketDataSource>(),
  //   ),
  // );
} 

// ChatMessagesBloc 需要手动注册，因为 ChatMessagesBloc 需要额外的 chatId 参数
void registerChatMessagesBloc(GetIt getIt) {
  getIt.registerFactoryParam<ChatMessagesBloc, int, void>(
    (chatId, _) => ChatMessagesBloc(
      chatId: chatId,
      getMessageList: getIt<GetMessageList>(),
      sendMessage: getIt<SendMessage>(),
      revokeMessage: getIt<RevokeMessage>(),
      getChatRoomDetails: getIt<GetChatRoomDetails>(),
      deleteChatMessage: getIt<DeleteChatMessage>(),
      userRepository: getIt<IUserRepository>(),
      webSocketDataSource: getIt<IChatWebSocketDataSource>(),
    ),
  );
} 