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

// Cubits
import '../presentation/cubit/chat/chat_cubit.dart';
import '../presentation/cubit/message_list/message_list_cubit.dart';
import '../presentation/cubit/websocket/websocket_cubit.dart';
import '../presentation/cubit/message_queue/message_queue_cubit.dart';

// Local data sources - Note: We have two different interfaces with the same name
import '../data/datasources/i_chat_local_data_source.dart' as shared_prefs;
import '../data/datasources/chat_local_data_source_impl.dart';
import '../data/data_sources/local/chat_local_data_source.dart' as database;
import '../presentation/services/chat_preload_service.dart';

// Adapters
import '../presentation/adapters/chat_message_adapter.dart';

// SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

// Database
import 'package:dskk_flutter_refactor/core/database/app_database.dart';

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
      
      // 读取用户类型（从AppMode或者存储中获取）
      final appMode = await _secureStorage.read(key: 'app_mode');
      String userType = 'MEMBER'; // 默认值
      
      // 根据appMode判断用户类型
      // 如果是seller模式，用户类型应该是DOCTOR
      // 如果是buyer模式，用户类型应该是MEMBER
      if (appMode == 'seller') {
        userType = 'DOCTOR';
      } else if (appMode == 'buyer') {
        userType = 'MEMBER';
      }
      
      // 调试：检查auth_token是否存在
      final authToken = await _secureStorage.read(key: 'auth_token');
      print('[ChatUserRepository] userId: $userId, commonUserId: $commonUserId');
      print('[ChatUserRepository] appMode: $appMode, userType: $userType');
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
        type: userType, // 使用动态获取的用户类型
      );
      
      print('[ChatUserRepository] 创建用户: id=${user.id}, commonUserId=${user.commonUserId}, type=${user.type}'); // 添加日志确认
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

/// 聊天模块的依赖注入类
class ChatDI {
  /// 初始化聊天模块的所有依赖
  static Future<void> init(GetIt getIt) async {
    print('[ChatDI] Initializing Chat module dependencies');

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences-based local data source (for payment prompt status)
    if (!getIt.isRegistered<shared_prefs.IChatLocalDataSource>()) {
      getIt.registerLazySingleton<shared_prefs.IChatLocalDataSource>(
        () => ChatLocalDataSourceImpl(prefs: prefs),
      );
      print('[ChatDI] Registered SharedPreferences-based IChatLocalDataSource');
    }
    
    // Database-based local data source (for message queue)
    if (!getIt.isRegistered<database.IChatLocalDataSource>()) {
      getIt.registerLazySingleton<database.IChatLocalDataSource>(
        () => database.ChatLocalDataSourceImpl(getIt<AppDatabase>()),
      );
      print('[ChatDI] Registered Database-based IChatLocalDataSource');
    }

    // 数据源
    if (!getIt.isRegistered<IChatRemoteDataSource>()) {
      getIt.registerLazySingleton<IChatRemoteDataSource>(
        () => ChatRemoteDataSourceImpl(dio: getIt<Dio>()),
      );
      print('[ChatDI] Registered IChatRemoteDataSource');
    }
    
    if (!getIt.isRegistered<IFileRemoteDataSource>()) {
      getIt.registerLazySingleton<IFileRemoteDataSource>(
        () => FileRemoteDataSourceImpl(dio: getIt<Dio>()),
      );
      print('[ChatDI] Registered IFileRemoteDataSource');
    }
    
    if (!getIt.isRegistered<IChatWebSocketDataSource>()) {
      getIt.registerLazySingleton<IChatWebSocketDataSource>(
        () => ChatWebSocketDataSourceImpl(),
      );
      print('[ChatDI] Registered IChatWebSocketDataSource');
    }

    // 仓库
    if (!getIt.isRegistered<IChatRepository>()) {
      getIt.registerLazySingleton<IChatRepository>(
        () => ChatRepositoryImpl(
          remoteDataSource: getIt<IChatRemoteDataSource>(),
          userRepository: getIt<IUserRepository>(),
        ),
      );
      print('[ChatDI] Registered IChatRepository');
    }
    
    if (!getIt.isRegistered<IFileRepository>()) {
      getIt.registerLazySingleton<IFileRepository>(
        () => FileRepositoryImpl(
          remoteDataSource: getIt<IFileRemoteDataSource>(),
        ),
      );
      print('[ChatDI] Registered IFileRepository');
    }

    // 用例
    if (!getIt.isRegistered<GetChatRoomList>()) {
      getIt.registerLazySingleton<GetChatRoomList>(
        () => GetChatRoomListImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered GetChatRoomList');
    }

    if (!getIt.isRegistered<CreateChatRoom>()) {
      getIt.registerLazySingleton<CreateChatRoom>(
        () => CreateChatRoomImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered CreateChatRoom');
    }

    if (!getIt.isRegistered<GetMessageList>()) {
      getIt.registerLazySingleton<GetMessageList>(
        () => GetMessageListImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered GetMessageList');
    }

    if (!getIt.isRegistered<SendMessage>()) {
      getIt.registerLazySingleton<SendMessage>(
        () => SendMessageImpl(getIt<IChatRepository>(), getIt<IFileRepository>()),
      );
      print('[ChatDI] Registered SendMessage');
    }

    if (!getIt.isRegistered<RevokeMessage>()) {
      getIt.registerLazySingleton<RevokeMessage>(
        () => RevokeMessageImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered RevokeMessage');
    }

    if (!getIt.isRegistered<DeleteChatMessage>()) {
      getIt.registerLazySingleton<DeleteChatMessage>(
        () => DeleteChatMessageImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered DeleteChatMessage');
    }

    if (!getIt.isRegistered<GetChatRoomDetails>()) {
      getIt.registerLazySingleton<GetChatRoomDetails>(
        () => GetChatRoomDetailsImpl(getIt<IChatRepository>()),
      );
      print('[ChatDI] Registered GetChatRoomDetails');
    }

    // Bloc
    // 使用 LazySingleton 让 ChatListBloc 成为单例，这样所有地方共享同一个实例
    if (!getIt.isRegistered<ChatListBloc>()) {
      getIt.registerLazySingleton<ChatListBloc>(() => ChatListBloc(
            getChatRoomList: getIt<GetChatRoomList>(),
            createChatRoom: getIt<CreateChatRoom>(),
          ));
      print('[ChatDI] Registered ChatListBloc as singleton');
    } else {
      print('[ChatDI] ChatListBloc already registered, skipping');
    }

    // 注册工厂方法，需要传入chatId参数
    if (!getIt.isRegistered<ChatMessagesBloc>()) {
      getIt.registerFactoryParam<ChatMessagesBloc, int, void>(
        (chatId, _) => ChatMessagesBloc(
          chatId: chatId,
          getMessageList: getIt<GetMessageList>(),
          sendMessage: getIt<SendMessage>(),
          revokeMessage: getIt<RevokeMessage>(),
          deleteChatMessage: getIt<DeleteChatMessage>(),
          getChatRoomDetails: getIt<GetChatRoomDetails>(),
          userRepository: getIt<IUserRepository>(),
          webSocketDataSource: getIt<IChatWebSocketDataSource>(),
        ),
      );
      print('[ChatDI] Registered ChatMessagesBloc factory with parameters');
    } else {
      print('[ChatDI] ChatMessagesBloc factory already registered, skipping');
    }

    // Register new Cubits for refactored architecture
    
    // ChatCubit
    if (!getIt.isRegistered<ChatCubit>()) {
      getIt.registerFactory<ChatCubit>(
        () => ChatCubit(
          getChatRoomDetails: getIt<GetChatRoomDetails>(),
          createChatRoom: getIt<CreateChatRoom>(),
          webSocketDataSource: getIt<IChatWebSocketDataSource>(),
        ),
      );
      print('[ChatDI] Registered ChatCubit');
    }
    
    // Register ChatPreloadService if not already registered
    if (!getIt.isRegistered<ChatPreloadService>()) {
      getIt.registerLazySingleton<ChatPreloadService>(
        () => ChatPreloadService(),
      );
      print('[ChatDI] Registered ChatPreloadService');
    }
    
    // MessageListCubit with new dependencies
    if (!getIt.isRegistered<MessageListCubit>()) {
      getIt.registerFactory<MessageListCubit>(
        () => MessageListCubit(
          getMessageList: getIt<GetMessageList>(),
          sendMessage: getIt<SendMessage>(),
          revokeMessage: getIt<RevokeMessage>(),
          deleteChatMessage: getIt<DeleteChatMessage>(),
          preloadService: getIt<ChatPreloadService>(),
          localDataSource: getIt<shared_prefs.IChatLocalDataSource>(),
          getChatRoomDetails: getIt<GetChatRoomDetails>(),
        ),
      );
      print('[ChatDI] Registered MessageListCubit with enhanced dependencies');
    }
    
    // WebSocketCubit
    if (!getIt.isRegistered<WebSocketCubit>()) {
      getIt.registerLazySingleton<WebSocketCubit>(
        () => WebSocketCubit(
          webSocketDataSource: getIt<IChatWebSocketDataSource>(),
        ),
      );
      print('[ChatDI] Registered WebSocketCubit');
    }
    
    // MessageQueueCubit
    if (!getIt.isRegistered<MessageQueueCubit>()) {
      getIt.registerFactory<MessageQueueCubit>(
        () => MessageQueueCubit(
          localDataSource: getIt<database.IChatLocalDataSource>(),
          sendMessage: getIt<SendMessage>(),
        ),
      );
      print('[ChatDI] Registered MessageQueueCubit');
    }

    print('[ChatDI] Chat module dependencies initialized');
  }
} 