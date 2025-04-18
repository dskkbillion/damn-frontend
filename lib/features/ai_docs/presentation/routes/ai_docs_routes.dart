import 'package:flutter/material.dart'; // Needed potentially for page transitions or builders
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For BlocProvider

// Import the DI container instance
import '../../../../app/di/injection_container.dart'; // Adjust path if needed

// Correctly import the Bloc and Page for this route
import '../bloc/ai_chat/ai_chat_bloc.dart'; // Restore import
import '../pages/chat_page.dart' hide getIt; // Restore import AND hide getIt from chat_page

/// Defines routes specifically for the AiDocs feature module.
class AiDocsRoutes {
  // Private constructor to prevent instantiation
  AiDocsRoutes._();

  /// Static getter for the list of routes defined in this module.
  static List<RouteBase> get routes => _routes;

  static const String chatPath = '/ai_chat';

  // Define the routes for this module
  static final List<RouteBase> _routes = [
    GoRoute(
      path: chatPath,
      name: 'aiChat',
      builder: (context, state) {
        // Restore BlocProvider with actual Page and Bloc
        // print('Navigating to AI Docs placeholder - Implement ChatPage and AiChatBloc');
        return BlocProvider(
          create: (_) => getIt<AiChatBloc>(), // Restore Bloc creation
          child: const ChatPage(), // Restore actual page
        );
        // return const _AiDocsPlaceholder(); // Remove placeholder
      },
      // TODO: Add sub-routes if needed, e.g., for specific conversation IDs:
      // routes: [
      //   GoRoute(
      //     path: ':conversationId', // e.g., /ai_chat/123
      //     name: 'aiConversation',
      //     builder: (context, state) {
      //       final conversationId = state.pathParameters['conversationId'];
      //       // Might need a different Bloc or pass ID to existing Bloc/Page
      //       return BlocProvider(
      //         create: (_) => getIt<AiChatBloc>()..add(LoadSpecificConversation(conversationId)), // Example
      //         child: ChatPage(conversationId: conversationId), // Assuming ChatPage can take ID
      //       );
      //     },
      //   ),
      // ]
    ),
    // TODO: Add other routes for the ai_docs module if needed
    // e.g., a route for conversation list page?
  ];
} 