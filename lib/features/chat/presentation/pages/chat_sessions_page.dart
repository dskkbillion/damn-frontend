import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:get_it/get_it.dart'; // Import GetIt for DI

import '../../../domain/entities/chat_session.dart';
// Remove placeholder imports if no longer needed directly
// import '../../../domain/entities/message.dart';
// import '../../../domain/entities/message_type.dart';
// import '../../../domain/entities/user.dart';
import '../bloc/sessions/chat_sessions_bloc.dart'; // Import Bloc
import '../widgets/chat_session_list_item.dart';
import './chat_detail_page.dart';

class ChatSessionsPage extends StatelessWidget { // Changed to StatelessWidget
  const ChatSessionsPage({super.key});

 // Removed _ChatSessionsPageState and placeholder data

  void _navigateToChatDetail(BuildContext context, ChatSession session) {
     print("Navigating to chat with ${session.partnerNickname} (Chat ID: ${session.id})");
     // Mark session as read when navigating to it
     context.read<ChatSessionsBloc>().add(MarkSessionAsRead(session.id));

     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (_) => ChatDetailPage(
           chatId: session.id,
           chatPartnerName: session.partnerNickname,
           // TODO: Pass the target User entity if available/needed by ChatDetailPage
         ),
       ),
     );
   }


  @override
  Widget build(BuildContext context) {
     // Provide the Bloc using BlocProvider. 
     // This assumes ChatSessionsBloc is registered with GetIt.
     // Alternatively, provide it higher up in the widget tree.
    return BlocProvider(
       create: (context) => GetIt.instance<ChatSessionsBloc>()..add(const LoadChatSessions()),
       child: Scaffold(
         appBar: AppBar(
           title: const Text('消息'),
           actions: [
             IconButton(
               icon: const Icon(Icons.search),
               onPressed: () {
                 print("Search pressed");
                 // TODO: Implement search functionality
               },
               tooltip: '搜索',
             ),
             IconButton(
               icon: const Icon(Icons.add_circle_outline),
               onPressed: () {
                 print("Add action pressed");
                 // TODO: Implement add chat/contact functionality
               },
               tooltip: '添加',
             ),
           ],
         ),
         body: BlocBuilder<ChatSessionsBloc, ChatSessionsState>(
            builder: (context, state) {
              // Handle Loading state (especially initial load)
              if (state is ChatSessionsLoading && state.sessions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              // Handle Error state (especially initial load error)
              if (state is ChatSessionsError && state.sessions.isEmpty) {
                return Center(
                   child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text('加载会话失败: ${state.failure.message}'),
                         const SizedBox(height: 16),
                         ElevatedButton(
                            onPressed: () => context.read<ChatSessionsBloc>().add(const LoadChatSessions(forceRefresh: true)), 
                            child: const Text('重试')
                         )
                      ],
                   )
                );
              }
              // Handle Loaded state or Loading/Error with existing data
              if (state.sessions.isEmpty && state is! ChatSessionsLoading) {
                 return const Center(child: Text('没有会话')); // Show empty message if loaded and empty
              }

              // Display the list (works for Loaded, or Loading/Error with data)
              return RefreshIndicator(
                onRefresh: () async {
                  print("Refreshing chat sessions via pull-to-refresh...");
                  context.read<ChatSessionsBloc>().add(const LoadChatSessions(forceRefresh: true));
                  // Bloc state will manage the loading indicator internally
                },
                child: ListView.builder(
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    return ChatSessionListItem(
                      session: session,
                      onTap: () => _navigateToChatDetail(context, session),
                    );
                  },
                ),
              );
            },
         ),
       ),
    );
  }
}

// Removed _createPlaceholderSessions helper function 