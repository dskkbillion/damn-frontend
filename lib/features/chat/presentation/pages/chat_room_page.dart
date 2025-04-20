import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart'; // For MessageStatus

class ChatRoomPage extends StatefulWidget {
  final int chatId;

  const ChatRoomPage({super.key, required this.chatId});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Delay slightly to allow the list to build
      Future.delayed(const Duration(milliseconds: 100), () {
         if (_scrollController.hasClients) { // Check again as widget might dispose
             _scrollController.animateTo(
               _scrollController.position.minScrollExtent,
               duration: const Duration(milliseconds: 300),
               curve: Curves.easeOut,
             );
         }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
          builder: (context, state) {
            if (state is ChatMessagesLoaded) {
              return Text(state.opponent.nickName ?? 'Chat');
            } else if (state is ChatMessagesLoading && state is! ChatMessagesInitial) {
                 // Show opponent name even while loading messages if already fetched
                 final bloc = context.read<ChatMessagesBloc>();
                 if (bloc.state is ChatMessagesLoaded) {
                     return Text((bloc.state as ChatMessagesLoaded).opponent.nickName ?? 'Chat');
                 }
                  return const Text('Loading...');
            } else if (state is ChatMessagesInitial) {
                 return const Text('Loading...');
            } else {
              // Handle error or initial state where opponent might not be known yet
              return const Text('Chat');
            }
          },
        ),
        // TODO: Add actions like viewing opponent profile
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatMessagesBloc, ChatMessagesState>(
              listener: (context, state) {
                 if (state is ChatMessagesLoaded) {
                   // Scroll to bottom when messages are loaded or new message arrives
                   // Check if the new message was added at the beginning (index 0)
                   // This helps differentiate between initial load and new messages
                   // if (state.messages.isNotEmpty && state.messages.first.status != MessageStatus.failed ) { // Adjust condition as needed
                      _scrollToBottom();
                   // }
                 }
              },
              builder: (context, state) {
                if (state is ChatMessagesLoading && state is! ChatMessagesLoaded) {
                  // Show loading only if messages aren't loaded yet
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(child: Text('No messages yet. Start chatting!'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show latest messages at the bottom
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final bool isCurrentUser = message.senderId == state.currentUserId;
                      // TODO: Add message grouping by date if needed
                      return ChatMessageBubble(
                        key: ValueKey(message.id),
                        message: message,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  );
                } else if (state is ChatMessagesError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  // Initial state or unexpected state
                  return const Center(child: Text('Loading chat...'));
                }
              },
            ),
          ),
          MessageInputBar(chatId: widget.chatId),
        ],
      ),
    );
  }
} 