import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // If needed for scroll controller logic

import '../../../domain/entities/message.dart';
import './chat_message_item.dart'; // Needs to be created

/// 显示聊天消息列表的 Widget
class ChatMessageList extends StatefulWidget {
  final List<Message> messages;
  final int currentUserId; // To determine message alignment
  final Function(int messageId)? onRevoke; // Callback to request message revocation

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.onRevoke,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Optional: Listen to scroll events for pagination or other features
    // _scrollController.addListener(_onScroll);
  }

 @override
 void didUpdateWidget(ChatMessageList oldWidget) {
   super.didUpdateWidget(oldWidget);
   // If new messages are added at the top (index 0), try to keep the scroll position stable
   // or scroll to bottom if it was already near the bottom.
   // Simple approach: If a new message is added by the current user, scroll to bottom.
   // More robust logic might be needed based on user scroll position.
   if (widget.messages.length > oldWidget.messages.length) {
       final newMessage = widget.messages.first;
       if (newMessage.isSentByCurrentUser(widget.currentUserId) || (_scrollController.hasClients && _scrollController.offset < 100)) {
            // If sent by me OR user is near the top, scroll to bottom after layout
            WidgetsBinding.instance.addPostFrameCallback((_) {
               if (_scrollController.hasClients) {
                 _scrollToBottom();
               }
           });
       }
   }
 }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0, // Scroll to the top because the list is reversed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    // Implement scroll listener logic if needed (e.g., load more messages when reaching the top)
    // if (_scrollController.position.atEdge) {
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     // Reached the top of the reversed list (end of history)
    //     print("Reached end of message history");
    //     // context.read<ChatMessagesBloc>().add(LoadMoreMessages());
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Display messages from bottom to top
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final bool isSentByMe = message.isSentByCurrentUser(widget.currentUserId);

        // TODO: Add logic for time dividers if needed
        // bool showTimeDivider = _shouldShowTimeDivider(index);

        return Column(
          children: [
            // if (showTimeDivider) _buildTimeDivider(message.createTime),
            ChatMessageItem(
              message: message,
              isSentByMe: isSentByMe,
              onLongPress: () {
                // Show context menu (copy, revoke, etc.)
                _showMessageContextMenu(context, message, isSentByMe);
              },
              onRetry: () {
                 // TODO: Implement retry logic for failed messages
                 print("Retry sending message: ${message.localId ?? message.id}");
                 // Need access to the original SendChatMessage event data or re-create it.
                 // context.read<ChatMessagesBloc>().add(RetrySendMessage(message));
              },
              // onTap: () { /* Handle image preview etc. in ChatMessageItem */ },
            ),
          ],
        );
      },
    );
  }

  // Example context menu
  void _showMessageContextMenu(BuildContext context, Message message, bool isSentByMe) {
    final items = <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(value: 'copy', child: Text('复制')),
      // Add other options like 'Forward', 'Delete' etc.
    ];

    // Add revoke option only for messages sent by the current user recently
    // TODO: Add time limit for revocation (e.g., within 2 minutes)
    if (isSentByMe && !message.withdrawFlag /* && isRecent(message.createTime) */) {
      items.add(const PopupMenuItem<String>(value: 'revoke', child: Text('撤回')));
    }

    // Show the menu near the message bubble (this requires getting the position)
    // For simplicity, showing a generic menu for now.
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 200, 100, 200), // Placeholder position
      items: items,
    ).then((value) {
      if (value == 'copy') {
        // TODO: Implement copy logic (Clipboard.setData)
        print('Copy message: ${message.context}');
      } else if (value == 'revoke') {
        print('Request revoke message: ${message.id}');
        widget.onRevoke?.call(message.id);
      }
    });
  }

  // TODO: Implement logic to decide when to show time dividers
  // bool _shouldShowTimeDivider(int index) { ... }
  // Widget _buildTimeDivider(DateTime time) { ... }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 