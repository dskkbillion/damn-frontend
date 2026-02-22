import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Assuming GetIt for DI

// Import smart router utils for buildSmartPage
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

// Import Chat module pages and Blocs
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_list_page.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_room_page_refactored.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_list.dart'; // For ChatListBloc event
// Import necessary use cases or dependencies for ChatMessagesBloc
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_message_list.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/send_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/revoke_message.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/get_chat_room_details.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/usecases/delete_chat_message.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_web_socket_data_source.dart';

final sl = GetIt.instance; // Assuming GetIt instance is globally accessible or passed

class ChatRoutes {
  // Private constructor to prevent instantiation
  ChatRoutes._();

  // Base path for chat module routes (optional, can be useful)
  // static const String baseChatPath = '/chat';

  // Expose the routes list via a static getter
  static List<RouteBase> get routes => _routes;

  // Define the actual routes for the chat module
  static final List<RouteBase> _routes = [
    GoRoute(
      path: '/chat', // Path for the chat list page
      name: 'chatList', // Optional name for navigation
      builder: (context, state) => BlocProvider(
        // Create a new instance instead of using singleton to avoid "Cannot add new events after calling close" error
        create: (_) => ChatListBloc(
          getChatRoomList: sl(),
          createChatRoom: sl(),
          deleteChatRoom: sl(),
        )..add(LoadChatRoomList()), // Create Bloc and load initial data
        child: const ChatListPage(),
      ),
      // Define nested routes starting from /chat
      routes: [
        GoRoute(
          path: ':chatId', // Relative path, becomes /chat/:chatId
          name: 'chatRoom', // Optional name
          builder: (context, state) {
            // Extract chatId from the path parameters
            final chatIdString = state.pathParameters['chatId'];
            final chatId = int.tryParse(chatIdString ?? '');

            // Validate chatId - Robust error handling is crucial here
            if (chatId == null || chatId == 0) {
              // Option 1: Show an error page
              // return ErrorPageWidget(message: "Invalid Chat ID: $chatIdString");

              // Option 2: Redirect back to chat list (or home)
              // WidgetsBinding.instance.addPostFrameCallback((_) {
              //   context.goNamed('chatList'); // Or context.go('/');
              // });
              // return const Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading while redirecting

              // Option 3: Show a simple error directly (less user-friendly for invalid IDs)
              AppLogger.d("Error: Invalid or missing chatId: $chatIdString");
              return Scaffold(
                  appBar: AppBar(title: const Text("Error")),
                  body: Center(child: Text("Invalid Chat ID '$chatIdString'. Please go back.")));
            }

            // 直接创建ChatMessagesBloc并设置新消息回调
            return BlocProvider(
              create: (_) {
                final chatMessagesBloc = ChatMessagesBloc(
                  chatId: chatId,
                  getMessageList: sl<GetMessageList>(),
                  sendMessage: sl<SendMessage>(),
                  revokeMessage: sl<RevokeMessage>(),
                  getChatRoomDetails: sl<GetChatRoomDetails>(),
                  deleteChatMessage: sl<DeleteChatMessage>(),
                  userRepository: sl<IUserRepository>(),
                  webSocketDataSource: sl<IChatWebSocketDataSource>(),
                );

                // 设置WebSocket消息回调以更新本地聊天列表
                chatMessagesBloc.onNewMessageReceived = (newMessage) {
                  AppLogger.d('[ChatRoutes] New WebSocket message received, updating local chat list');
                  try {
                    // 尝试从 GetIt 获取 ChatListBloc
                    if (sl.isRegistered<ChatListBloc>()) {
                      final chatListBloc = sl<ChatListBloc>();
                      chatListBloc.add(UpdateChatRoomLastMessage(
                        chatId: chatId,
                        lastMessage: newMessage,
                      ));
                      AppLogger.d('[ChatRoutes] Updated chat list with new WebSocket message');
                    }
                  } catch (e) {
                    AppLogger.d('[ChatRoutes] Error updating chat list with WebSocket message: $e');
                  }
                };

                chatMessagesBloc.add(LoadChatMessages(chatId));
                return chatMessagesBloc;
              },
              child: ChatRoomPage(chatId: chatId), // Pass chatId to the page widget
            );
          },
        ),
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