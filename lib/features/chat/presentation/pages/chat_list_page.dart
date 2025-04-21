import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Import GetIt

import '../bloc/chat_list/chat_list_bloc.dart';
import '../widgets/chat_list_item.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart'; // Import ChatMessagesBloc
import 'chat_room_page.dart'; // Import ChatRoomPage
// Import domain entities needed for fake ChatRoom
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';

final sl = GetIt.instance; // Get GetIt instance

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // Helper to build the static admin list item
  Widget _buildAdminListItem(BuildContext context, int currentUserId) {
    // Create a fake ChatRoom representing the admin chat
    // Use placeholder IDs and potentially a specific icon/avatar later
    final adminParticipant = Participant(
      id: 1, // Admin's internal ID (assuming 1 based on doctorId parameter)
      referId: 1, // Admin's referId (assuming 1, adjust if known)
      nickName: '系统管理员',
      type: 'ADMIN',
      avatar: null, // TODO: Add a specific admin icon/avatar URL later
    );
    // Create a fake participant for the current user for the ChatRoom structure
    final currentUserParticipant = Participant(
      id: -1, // Placeholder internal ID
      referId: currentUserId,
      nickName: 'Me',
      type: 'MEMBER',
    );

    final fakeAdminChatRoom = ChatRoom(
      id: -1, // Special ID for admin chat entry, not from API
      participant1: currentUserParticipant, // Assign based on who should be p1/p2
      participant2: adminParticipant,
      unreadCount: 0,
      lastMessage: null, // Or a placeholder message like "Tap to start chat"
    );

    return Material(
      color: Colors.white, 
      child: ChatListItem(
        key: const ValueKey('admin_chat_entry'), // Unique key
        chatRoom: fakeAdminChatRoom,
        currentUserId: currentUserId, // Pass the actual current user referId
        onTap: () {
          print('[ChatListPage] Admin chat item tapped.');
          // TODO: Show loading indicator?
          context.read<ChatListBloc>().add(StartAdminChatRequested());
        },
        // TODO: Add visual differentiation (e.g., different icon/background)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace this placeholder with actual user ID from state/provider
    const int currentUserId = 10307; // Temporary fix, use actual referId

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: const Text('聊天列表'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, 
        elevation: 0.5, 
        shadowColor: Colors.grey[300],
      ),
      // Add BlocListener to handle navigation
      body: BlocListener<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state.navigateToChatId != null) {
            final chatId = state.navigateToChatId!;
            print('[ChatListPage] BlocListener triggered navigation to chatId: $chatId');
            // Navigate to ChatRoomPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ChatMessagesBloc>(param1: chatId)
                                ..add(LoadChatMessages(chatId)),
                  child: ChatRoomPage(chatId: chatId),
                ),
              ),
            ).then((result) {
               // Reset navigation trigger in Bloc state after navigation
               context.read<ChatListBloc>().add(ClearNavigationTrigger()); // Need to add this event
               // Handle potential refresh logic if needed after returning
               if (result == true) {
                 print('[ChatListPage] Refreshing list after viewing chat $chatId');
                 context.read<ChatListBloc>().add(RefreshChatList()); 
               }
            });
          }
          // Handle potential error messages from StartAdminChatRequested
          if (state.status == ChatListStatus.failure && state.errorMessage != null && state.errorMessage!.contains("无法连接到系统管理员")) {
             // Show SnackBar or Dialog with the error
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.errorMessage!)),
             );
             // Optionally reset the error message in the state
             // context.read<ChatListBloc>().add(ClearErrorMessage()); // Need to add this event
          }
        },
        child: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state.status == ChatListStatus.loading && state.chatRooms.isEmpty) { // Show loading only initially
              return const Center(child: CircularProgressIndicator()); 
            } else if (state.status == ChatListStatus.success || (state.status == ChatListStatus.loading && state.chatRooms.isNotEmpty)) {
              // Always show the list if we have rooms, even while loading more/refreshing
              // final itemCount = state.chatRooms.length + 1; // Add 1 for admin entry
               return ListView.separated(
                 // Add 1 to item count for the static admin entry
                 itemCount: state.chatRooms.length + 1, 
                 itemBuilder: (context, index) {
                   // First item is the admin chat entry
                   if (index == 0) {
                     return _buildAdminListItem(context, currentUserId);
                   }
                   // Subsequent items are regular chat rooms
                   final chatRoom = state.chatRooms[index - 1]; // Adjust index
                   return Material(
                     color: Colors.white, 
                     child: ChatListItem(
                       key: ValueKey(chatRoom.id), 
                       chatRoom: chatRoom,
                       currentUserId: currentUserId, 
                       onTap: () {
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
                           if (result == true) {
                             print('[ChatListPage] Refreshing list after viewing chat ${chatRoom.id}');
                             context.read<ChatListBloc>().add(RefreshChatList()); 
                           }
                         });
                       },
                     ),
                   );
                 },
                 separatorBuilder: (context, index) {
                   // Optionally add a different separator after the admin item
                    if (index == 0) {
                       return const Divider(height: 8, thickness: 8, color: Color(0xFFEDEDED)); // Thicker separator
                    } 
                    // Regular separator
                    return Divider(
                      height: 1,
                      indent: 80, 
                      endIndent: 16,
                      color: Colors.grey[100], 
                      thickness: 0.5, 
                    );
                 },
               );
            } else if (state.status == ChatListStatus.failure) {
              return Center(
                 // Display error, but potentially still show the Admin entry above it?
                 // For now, just show the error.
                child: Text('加载失败: ${state.errorMessage ?? "未知错误"}'), 
              );
            } else { // Initial state
               return const Center(child: Text('正在加载...')); 
            }
          },
        ),
      ),
    );
  }
} 