import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/i_http_client.dart';
import '../../../core/network/mock_http_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../data/datasources/chat_local_datasource.dart';
import '../data/datasources/chat_websocket_service.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/get_chat_sessions_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/get_message_history_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/usecases/receive_message_usecase.dart';
import '../presentation/bloc/chat_sessions/chat_sessions_bloc.dart';
import '../presentation/bloc/chat_messages/chat_messages_bloc.dart';

/// 聊天模块依赖注入
///
/// 用于注册聊天模块的所有依赖项
@module
abstract class ChatModule {
  /// 注册真实依赖
  static void registerDependencies(GetIt getIt) {
    // 网络状态
    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(),
    );
    
    // 数据源
    getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(client: getIt<IHttpClient>()),
    );
    
    getIt.registerLazySingleton<ChatLocalDataSource>(
      () => ChatLocalDataSourceImpl(),
    );
    
    getIt.registerLazySingleton<ChatWebSocketServiceImpl>(
      () => ChatWebSocketServiceImpl(client: getIt<IHttpClient>()),
    );

    // 仓库
    getIt.registerLazySingleton<IChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: getIt<ChatRemoteDataSource>(),
        localDataSource: getIt<ChatLocalDataSource>(),
        webSocketService: getIt<ChatWebSocketServiceImpl>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );

    // 用例
    getIt.registerLazySingleton<GetChatSessionsUseCase>(
      () => GetChatSessionsUseCase(getIt<IChatRepository>()),
    );
    
    getIt.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(getIt<IChatRepository>()),
    );
    
    getIt.registerLazySingleton<GetMessageHistoryUseCase>(
      () => GetMessageHistoryUseCase(getIt<IChatRepository>()),
    );
    
    getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(getIt<IChatRepository>()),
    );
    
    getIt.registerLazySingleton<ReceiveMessageUseCase>(
      () => ReceiveMessageUseCase(getIt<IChatRepository>()),
    );

    // Bloc
    getIt.registerFactory<ChatSessionsBloc>(
      () => ChatSessionsBloc(getIt<GetChatSessionsUseCase>()),
    );
    
    getIt.registerFactory<ChatMessagesBloc>(
      () => ChatMessagesBloc(
        getMessagesUseCase: getIt<GetMessagesUseCase>(),
        sendMessageUseCase: getIt<SendMessageUseCase>(),
        getMessageHistoryUseCase: getIt<GetMessageHistoryUseCase>(),
        receiveMessageUseCase: getIt<ReceiveMessageUseCase>(),
      ),
    );
  }

  /// 注册Mock依赖，用于隔离开发和测试
  static void registerMockDependencies(GetIt getIt) {
    // 注册Mock的HTTP客户端
    getIt.registerLazySingleton<IHttpClient>(() => MockHttpClient());
    
    // 注册HTTP客户端，这将使用我们的MockHttpClient来处理所有HTTP请求
    getIt.registerLazySingleton<http.Client>(
      () => http.Client(),
    );
    
    // 注册Mock的网络信息
    getIt.registerLazySingleton<NetworkInfo>(() => MockNetworkInfo());
    
    // 然后注册其他依赖，复用真实依赖的注册逻辑
    registerDependencies(getIt);
  }
} 