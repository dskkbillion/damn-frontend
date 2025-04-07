import 'package:get_it/get_it.dart';

import '../domain/repositories/i_chat_repository.dart';
import '../domain/services/i_chat_realtime_service.dart';
import '../domain/usecases/create_session.dart';
import '../domain/usecases/delete_message.dart';
import '../domain/usecases/get_chat_sessions.dart';
import '../domain/usecases/get_messages.dart';
import '../domain/usecases/manage_session.dart';
import '../domain/usecases/receive_message.dart';
import '../domain/usecases/revoke_message.dart';
import '../domain/usecases/send_message.dart';
import '../domain/usecases/sync_messages.dart';
import '../mock/mock_repositories.dart';
import '../mock/mock_services.dart';
import '../presentation/bloc/chat_bloc/chat_bloc.dart';
import '../presentation/bloc/message_bloc/message_bloc.dart';

/// 聊天模块依赖注入配置
///
/// 负责注册聊天模块的依赖
class ChatModule {
  /// 注册Mock依赖
  ///
  /// 用于隔离开发和测试
  static void registerMockDependencies(GetIt getIt) {
    // 注册Mock仓库
    getIt.registerLazySingleton<IChatRepository>(
      () => MockChatRepository(),
    );
    
    // 注册Mock实时服务
    getIt.registerLazySingleton<IChatRealtimeService>(
      () => MockChatRealtimeService(),
    );
    
    // 注册用例
    _registerUseCases(getIt);
    
    // 注册Bloc
    _registerBlocs(getIt);
  }
  
  /// 注册依赖
  ///
  /// 用于生产环境
  static void registerDependencies(GetIt getIt) {
    // 目前使用Mock实现，后续替换为真实实现
    registerMockDependencies(getIt);
    
    // TODO: 在生产环境中注册真实实现
    // getIt.registerLazySingleton<IChatRepository>(
    //   () => ChatRepository(),
    // );
    // 
    // getIt.registerLazySingleton<IChatRealtimeService>(
    //   () => ChatRealtimeService(),
    // );
  }
  
  /// 注册用例
  ///
  /// 注册聊天模块的所有用例
  static void _registerUseCases(GetIt getIt) {
    // 获取会话用例
    getIt.registerLazySingleton<GetChatSessionsUseCase>(
      () => GetChatSessionsUseCase(getIt<IChatRepository>()),
    );
    
    // 发送消息用例
    getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(getIt<IChatRepository>()),
    );
    
    // 接收消息用例
    getIt.registerLazySingleton<ReceiveMessageUseCase>(
      () => ReceiveMessageUseCase(getIt<IChatRealtimeService>()),
    );
    
    // 创建会话用例
    getIt.registerLazySingleton<CreateSessionUseCase>(
      () => CreateSessionUseCase(getIt<IChatRepository>()),
    );
    
    // 管理会话用例
    getIt.registerLazySingleton<ManageSessionUseCase>(
      () => ManageSessionUseCase(getIt<IChatRepository>()),
    );
    
    // 同步消息用例
    getIt.registerLazySingleton<SyncMessagesUseCase>(
      () => SyncMessagesUseCase(getIt<IChatRepository>()),
    );
    
    // 获取消息用例
    getIt.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(getIt<IChatRepository>()),
    );
    
    // 删除消息用例
    getIt.registerLazySingleton<DeleteMessageUseCase>(
      () => DeleteMessageUseCase(getIt<IChatRepository>()),
    );
    
    // 撤回消息用例
    getIt.registerLazySingleton<RevokeMessageUseCase>(
      () => RevokeMessageUseCase(getIt<IChatRepository>()),
    );
  }
  
  /// 注册Bloc
  ///
  /// 注册聊天模块的所有Bloc
  static void _registerBlocs(GetIt getIt) {
    // 聊天Bloc
    getIt.registerFactory<ChatBloc>(
      () => ChatBloc(
        getChatSessionsUseCase: getIt<GetChatSessionsUseCase>(),
        createSessionUseCase: getIt<CreateSessionUseCase>(),
        manageSessionUseCase: getIt<ManageSessionUseCase>(),
      ),
    );
    
    // 消息Bloc
    getIt.registerFactory<MessageBloc>(
      () => MessageBloc(
        getMessagesUseCase: getIt<GetMessagesUseCase>(),
        sendMessageUseCase: getIt<SendMessageUseCase>(),
        receiveMessageUseCase: getIt<ReceiveMessageUseCase>(),
        syncMessagesUseCase: getIt<SyncMessagesUseCase>(),
        deleteMessageUseCase: getIt<DeleteMessageUseCase>(),
        revokeMessageUseCase: getIt<RevokeMessageUseCase>(),
        chatRealtimeService: getIt<IChatRealtimeService>(),
      ),
    );
  }
} 