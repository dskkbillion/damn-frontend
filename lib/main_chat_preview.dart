import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'features/chat/injection/chat_module.dart';
import 'features/chat/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc/chat_event.dart';
import 'features/chat/presentation/bloc/message_bloc/message_bloc.dart';
import 'features/chat/presentation/pages/chat_detail_page.dart';
import 'features/chat/presentation/pages/chat_list_page.dart';

/// 全局依赖注入容器
final getIt = GetIt.instance;

/// 聊天模块预览入口
///
/// 用于隔离开发和测试聊天模块功能
void main() {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 注册依赖
  ChatModule.registerMockDependencies(getIt);
  
  // 运行应用
  runApp(const ChatPreviewApp());
}

/// 聊天模块预览应用
class ChatPreviewApp extends StatelessWidget {
  /// 创建聊天模块预览应用
  const ChatPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatBloc>(
          create: (_) => getIt<ChatBloc>()..add(const LoadChats()),
        ),
        BlocProvider<MessageBloc>(
          create: (_) => getIt<MessageBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: '聊天模块预览',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
  
  /// 应用路由配置
  GoRouter get _router => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ChatListPage(),
        routes: [
          GoRoute(
            path: 'chat/:sessionId',
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'] ?? '';
              return ChatDetailPage(sessionId: sessionId);
            },
          ),
        ],
      ),
    ],
  );
} 