import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart'; // Import NetworkInfo
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';
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

@module
abstract class ChatInjectableModule {

  // --- Provide Mock IUserRepository for Chat Preview/Branch --- 
  @lazySingleton
  @Named('mockUserRepository')  // 使用Named注解来标识这是一个特定的mock实现
  IUserRepository get mockUserRepository => MockUserRepository();
  
  // 添加默认的IUserRepository注册，确保没有其他模块注册时可以使用mock版本
  @lazySingleton
  IUserRepository provideUserRepository() {
    // 直接返回MockUserRepository实例，避免循环依赖
    print("注意: 使用聊天模块的Mock用户仓库 (避免循环依赖)");
    return MockUserRepository();
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
  
  // Register ChatMessagesBloc as a factory that takes parameters
  // This needs to be handled where it's used (e.g., in the route builder) or via GetIt.registerFactoryParam
  // We register its non-parameter dependencies here indirectly by registering the use cases etc.
} 