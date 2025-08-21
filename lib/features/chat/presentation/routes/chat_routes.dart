import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Assuming GetIt for DI

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
        // Ensure ChatListBloc and its dependencies (use cases) are registered in your DI (GetIt/sl)
        create: (_) => sl<ChatListBloc>()..add(LoadChatRoomList()), // Create Bloc and load initial data
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
              print("Error: Invalid or missing chatId: $chatIdString");
              return Scaffold(
                  appBar: AppBar(title: const Text("Error")),
                  body: Center(child: Text("Invalid Chat ID '$chatIdString'. Please go back.")));
            }

            // 直接创建ChatMessagesBloc而不是尝试从GetIt获取
            return BlocProvider(
              create: (_) => ChatMessagesBloc(
                chatId: chatId,
                getMessageList: sl<GetMessageList>(),
                sendMessage: sl<SendMessage>(),
                revokeMessage: sl<RevokeMessage>(),
                getChatRoomDetails: sl<GetChatRoomDetails>(),
                deleteChatMessage: sl<DeleteChatMessage>(),
                userRepository: sl<IUserRepository>(),
                webSocketDataSource: sl<IChatWebSocketDataSource>(),
              )..add(LoadChatMessages(chatId)),
              child: ChatRoomPage(chatId: chatId), // Pass chatId to the page widget
            );
          },
        ),
        // New refactored chat room route
        GoRoute(
          path: 'refactored/:chatId', // Relative path, becomes /chat/refactored/:chatId
          name: 'chatRoomRefactored', // Optional name for navigation
          builder: (context, state) {
            // Extract chatId from the path parameters
            final chatIdString = state.pathParameters['chatId'];
            final chatId = int.tryParse(chatIdString ?? '');

            // Validate chatId
            if (chatId == null || chatId == 0) {
              print("Error: Invalid or missing chatId: $chatIdString");
              return Scaffold(
                appBar: AppBar(title: const Text("Error")),
                body: Center(child: Text("Invalid Chat ID '$chatIdString'. Please go back.")),
              );
            }

            // Return the refactored chat room page
            // The page will handle its own Cubit initialization
            return ChatRoomPageRefactored(
              chatId: chatId,
              onMessagesLoaded: () {
                // This callback can be used to update unread count in parent
                print('[ChatRoutes] Messages loaded for chat $chatId');
              },
              onMessageRevoked: (chatId, newLastMessage) {
                // This callback can be used to update last message in chat list
                print('[ChatRoutes] Message revoked in chat $chatId');
              },
              onMessageSent: () {
                // 刷新聊天列表
                print('[ChatRoutes] Message sent in chat $chatId, attempting to refresh chat list...');
                
                // 方法1：尝试从 context 获取 ChatListBloc
                try {
                  final chatListBloc = context.read<ChatListBloc>();
                  print('[ChatRoutes] Found ChatListBloc from context, refreshing...');
                  chatListBloc.add(RefreshChatList());
                } catch (e) {
                  print('[ChatRoutes] ChatListBloc not found in context: $e');
                  
                  // 方法2：尝试从 GetIt 获取
                  try {
                    if (sl.isRegistered<ChatListBloc>()) {
                      final chatListBloc = sl<ChatListBloc>();
                      print('[ChatRoutes] Found ChatListBloc from GetIt, refreshing...');
                      chatListBloc.add(RefreshChatList());
                    } else {
                      print('[ChatRoutes] ChatListBloc not registered in GetIt');
                    }
                  } catch (e2) {
                    print('[ChatRoutes] Failed to get ChatListBloc from GetIt: $e2');
                  }
                }
              },
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