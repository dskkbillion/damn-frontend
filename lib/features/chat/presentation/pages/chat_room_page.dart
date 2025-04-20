import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

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

  // Helper to check if timestamp separator is needed
  bool _shouldShowTimestampSeparator(ChatMessage current, ChatMessage? previous) {
    if (previous == null) {
      return true; // Always show for the very first message (oldest)
    }
    // Show if difference is more than 5 minutes
    final difference = previous.createTime.difference(current.createTime).abs(); 
    return difference.inMinutes >= 5;
  }

  // Helper to build the timestamp separator widget
  Widget _buildTimestampSeparator(DateTime timestamp, bool isFirstMessage) {
    String formattedTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (isFirstMessage || messageDate.isBefore(today)) {
       // Show full date for the first message or if it's not today
       // Use Chinese locale for month/day format
       formattedTime = DateFormat('MM 月 dd 日 HH:mm', 'zh_CN').format(timestamp); 
    } else {
       // Show only time if it's today
       formattedTime = DateFormat('HH:mm').format(timestamp);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          formattedTime,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.0,
          ),
        ),
      ),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Adjust padding
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      // Add null checks for safety
                      if (state.opponent == null || state.currentUserParticipantId == 0) {
                        // Handle state inconsistency - maybe show an error or loading indicator?
                        // Returning an empty container for now to avoid crashing.
                        print('Error: Inconsistent state in ChatRoomPage itemBuilder - opponent or currentUserParticipantId is invalid.');
                        return Container(); 
                      }

                      final currentMessage = state.messages[index];
                      final previousMessage = (index + 1 < state.messages.length)
                          ? state.messages[index + 1]
                          : null;

                      final bool isFirstInList = previousMessage == null;

                      // Check if createTime is null before using timestamp logic
                      if (currentMessage.createTime == null) {
                        // Handle messages with null createTime (e.g., log error, show placeholder)
                        print('Error: Message ID ${currentMessage.id} has null createTime.');
                        // Return only the bubble without timestamp processing
                        return ChatMessageBubble(
                           key: ValueKey(currentMessage.id), 
                           message: currentMessage,
                           currentUserParticipantId: state.currentUserParticipantId,
                           opponent: state.opponent,
                        );
                      }

                      // Proceed with timestamp logic only if createTime is not null
                      final bool showTimestamp = _shouldShowTimestampSeparator(currentMessage, previousMessage);

                      return Column(
                        children: [
                          if (showTimestamp) 
                             _buildTimestampSeparator(currentMessage.createTime!, isFirstInList), // Use ! as we checked null
                          
                          ChatMessageBubble(
                            key: ValueKey(currentMessage.id), 
                            message: currentMessage,
                            currentUserParticipantId: state.currentUserParticipantId,
                            opponent: state.opponent, // Now checked for null above
                          ),
                        ],
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