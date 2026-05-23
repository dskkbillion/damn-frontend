import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Assuming GetIt for DI

// Import smart router utils for buildSmartPage
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

// Import Chat module pages and Blocs
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_list_page.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page_refactored.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';

final sl = GetIt.instance; // Assuming GetIt instance is globally accessible or passed

class ChatRoutes {
  // Private constructor to prevent instantiation
  ChatRoutes._();

  // Expose the routes list via a static getter
  static List<RouteBase> get routes => _routes;

  /// 聊天室子路由（可复用于买家/卖家 Shell）
  /// [namePrefix] 用于区分路由名称，避免 GoRouter name 冲突
  static List<RouteBase> chatRoomSubRoutes({String namePrefix = ''}) => [
    GoRoute(
      path: ':chatId',
      name: '${namePrefix}chatRoom',
      pageBuilder: (context, state) {
        final chatIdString = state.pathParameters['chatId'];
        final chatId = int.tryParse(chatIdString ?? '');

        if (chatId == null || chatId == 0) {
          AppLogger.d("Error: Invalid or missing chatId: $chatIdString");
          return state.buildSmartPage(
            Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: Center(child: Text("Invalid Chat ID '$chatIdString'. Please go back.")),
            ),
            name: 'chatRoomError',
          );
        }

        // 老版 ChatRoomPage 不支持轻咨询/payment_prompt 发送按钮,
        // 这里直接用 refactored 版,买家/卖家从列表点入对话也能看到按钮。
        // (refactored 自己从 getIt 取 Cubits,不需要外层 BlocProvider 注入 ChatMessagesBloc)
        return state.buildSmartPage(
          ChatRoomPageRefactored(
            chatId: chatId,
            onMessagesLoaded: () {
              AppLogger.d('[ChatRoutes] Messages loaded for chat $chatId');
            },
            onMessageRevoked: (chatId, newLastMessage) {
              AppLogger.d('[ChatRoutes] Message revoked in chat $chatId');
            },
            onMessageSent: () {
              AppLogger.d('[ChatRoutes] Message sent in chat $chatId');
            },
          ),
          name: 'chatRoom',
        );
      },
    ),
  ];

  // Define the actual routes for the chat module
  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/chat', // Path for the chat list page
      name: 'chatList', // Optional name for navigation
      pageBuilder: (context, state) {
        // 使用 GetIt singleton，避免每次创建新实例导致旧实例 close 后仍收到事件
        final chatListBloc = sl<ChatListBloc>();
        chatListBloc.add(LoadChatRoomList());
        return NoTransitionPage(
          key: state.pageKey,
          child: BlocProvider.value(
            value: chatListBloc,
            child: const ChatListPage(),
          ),
        );
      },
      // Define nested routes starting from /chat
      routes: [
        // 复用共享的聊天室子路由
        ...chatRoomSubRoutes(),
        // New refactored chat room route
        GoRoute(
          path: 'refactored/:chatId', // Relative path, becomes /chat/refactored/:chatId
          name: 'chatRoomRefactored', // Optional name for navigation
          pageBuilder: (context, state) {
            // Extract chatId from the path parameters
            final chatIdString = state.pathParameters['chatId'];
            final chatId = int.tryParse(chatIdString ?? '');

            // Validate chatId
            if (chatId == null || chatId == 0) {
              AppLogger.d("Error: Invalid or missing chatId: $chatIdString");
              return state.buildSmartPage(
                Scaffold(
                  appBar: AppBar(title: const Text("Error")),
                  body: Center(child: Text("Invalid Chat ID '$chatIdString'. Please go back.")),
                ),
                name: 'chatRoomError',
              );
            }

            // Return the refactored chat room page
            return state.buildSmartPage(
              ChatRoomPageRefactored(
                chatId: chatId,
                onMessagesLoaded: () {
                  AppLogger.d('[ChatRoutes] Messages loaded for chat $chatId');
                },
                onMessageRevoked: (chatId, newLastMessage) {
                  AppLogger.d('[ChatRoutes] Message revoked in chat $chatId');
                },
                onMessageSent: () {
                  AppLogger.d('[ChatRoutes] Message sent in chat $chatId');
                },
              ),
              name: 'chatRoomRefactored',
            );
          },
        ),
        // Add other chat-related nested routes here if needed
        // e.g., path: 'search', builder: ...
      ],
    ),
    // If you had other top-level chat routes, define them here
    // e.g., GoRoute(path: '/chat-settings', builder: ...),
  ];
} 