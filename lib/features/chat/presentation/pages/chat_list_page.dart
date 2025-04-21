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
    // TODO: Replace this placeholder with actual user ID from state/provider
    const int currentUserId = 1; 

    return Scaffold(
      // Set Scaffold background color
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text('聊天列表'),
        // Set AppBar background and text/icon color
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Sets default color for title and icons
        elevation: 0.5, // Add a subtle shadow
        shadowColor: Colors.grey[300],
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state.status == ChatListStatus.loading) {
            // Return loading indicator on the desired background
            return const Center(child: CircularProgressIndicator()); 
          } else if (state.status == ChatListStatus.success) {
            if (state.chatRooms.isEmpty) {
              // Return empty message on the desired background
              return const Center(child: Text('没有聊天记录')); 
            }
            // Use ListView.separated to add dividers
            return ListView.separated(
              itemCount: state.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = state.chatRooms[index];
                // Wrap ChatListItem with Material for InkWell splash on correct background
                return Material(
                  color: Colors.white, // List item background
                  child: ChatListItem(
                    key: ValueKey(chatRoom.id), 
                    chatRoom: chatRoom,
                    currentUserId: currentUserId, // Pass currentUserId
                    onTap: () {
                      // Use .then() to handle the result when ChatRoomPage pops
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<ChatMessagesBloc>(param1: chatRoom.id)
                                          ..add(LoadChatMessages(chatRoom.id)),
                            child: ChatRoomPage(chatId: chatRoom.id),
                          ),
                        ),
                      ).then((result) {
                        // If ChatRoomPage popped with true, refresh the list
                        if (result == true) {
                          print('[ChatListPage] Refreshing list after viewing chat ${chatRoom.id}');
                          // Add an event to ChatListBloc to trigger refresh
                          context.read<ChatListBloc>().add(RefreshChatList()); 
                        }
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 80, // Adjust indent to align after avatar+padding
                endIndent: 16,
                color: Colors.grey[100], // Lighter divider color
                thickness: 0.5, // Make divider thinner
              ),
            );
          } else if (state.status == ChatListStatus.failure) {
            // Return error message on the desired background
            return Center(
              child: Text('加载失败: ${state.errorMessage ?? "未知错误"}'), 
            );
          } else {
            // Return initial state message on the desired background
            return const Center(child: Text('正在加载...')); 
          }
        },
      ),
    );
  }
} 