import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import DI container
import '../../../../app/di/injection_container.dart';

// Import page and bloc
import '../pages/chat_page.dart' hide getIt;
import '../bloc/ai_chat/ai_chat_bloc.dart';

/// Defines routes specifically for the AiDocs feature module.
class AiDocsRoutes {
  AiDocsRoutes._();

  static List<RouteBase> get routes => _routes;

  static const String chatPath = '/ai_chat';

  static final List<RouteBase> _routes = [
    GoRoute(
      path: chatPath,
      name: 'aiChat',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<AiChatBloc>(),
          child: const ChatPage(),
        );
      },
      // Add sub-routes if needed
    ),
    // Add other AiDocs routes here if necessary
  ];
} 