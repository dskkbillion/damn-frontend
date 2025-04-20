import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

import '../bloc/chat_list/chat_list_bloc.dart';
import '../widgets/chat_list_item.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import 'chat_room_page.dart'; // Import ChatRoomPage
// import '../../../core/navigation/navigation_service.dart'; // Import later for navigation
// import '../../../../main_chat_preview.dart'; // Import sl later for navigation

final sl = GetIt.instance; // Get GetIt instance

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天列表'),
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state.status == ChatListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ChatListStatus.success) {
            if (state.chatRooms.isEmpty) {
              return const Center(child: Text('没有聊天记录'));
            }
            return ListView.builder(
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = state.chatRooms[index];
                // final opponent = chatRoom.getOpponent(1); // Logic moved inside ChatListItem

                return ChatListItem( // Pass the whole chatRoom object
                  key: ValueKey(chatRoom.id), // Add key for performance
                  chatRoom: chatRoom,
                  // avatarUrl: opponent.avatar,
                  // name: opponent.nickName ?? 'Unknown',
                  // lastMessage: chatRoom.lastMessage?.context ?? '',
                  // lastMessageTime: chatRoom.lastActivityTime,
                  // unreadCount: chatRoom.unreadCount,
                  onTap: () {
                    // Navigate to ChatRoomPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          // FIX: Call GetIt with correct parameter (param1 is now chatId)
                          create: (_) => sl<ChatMessagesBloc>(param1: chatRoom.id)
                                        ..add(LoadChatMessages(chatRoom.id)),
                          child: ChatRoomPage(chatId: chatRoom.id),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state.status == ChatListStatus.failure) {
            return Center(
              child: Text('加载失败: ${state.errorMessage ?? "未知错误"}'),
            );
          } else {
            // Initial state
            return const Center(child: Text('正在加载...'));
          }
        },
      ),
    );
  }
} 