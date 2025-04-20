import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing locale data

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';

class ChatListItem extends StatefulWidget { // Change to StatefulWidget for initState
  final ChatRoom chatRoom;
  final VoidCallback? onTap;
  final int currentUserId;

  const ChatListItem({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    this.onTap,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  @override
  void initState() {
    super.initState();
    // Initialize locale data for Chinese date formats if not already done globally
    initializeDateFormatting('zh_CN', null); 
  }

  // Updated timestamp formatting based on frontend.md
  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // Today: HH:mm
      return DateFormat('HH:mm', 'zh_CN').format(timestamp);
    } else if (difference == 1) {
      // Yesterday
      return '昨天';
    } else if (difference < 7) {
       // Within a week: Weekday (e.g., 星期一)
       // Ensure zh_CN is initialized for this
       return DateFormat('E', 'zh_CN').format(timestamp); 
    } else {
       // Older: yyyy/MM/dd or MM/dd based on preference
      return DateFormat('MM/dd', 'zh_CN').format(timestamp);
    }
  }

  String _getLastMessagePreview(ChatMessage? message) {
    if (message == null) return '';
    // Limit preview length for text messages
    const maxLength = 30; 
    String contextPreview = message.context.length > maxLength 
        ? '${message.context.substring(0, maxLength)}...' 
        : message.context;

    switch (message.type) {
      case 'text':
        return contextPreview;
      case 'image':
        return '[图片]';
      case 'audio':
        return '[语音]';
      case 'revoke': // Use the actual type string if different
        return '[消息已撤回]';
      // TODO: Add cases for other custom types ('order', 'distribute')
      default:
        // Show context for unknown types if not empty, otherwise indicate unknown
        return contextPreview.isNotEmpty ? contextPreview : '[未知消息]';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get opponent participant
    // Note: Ensure getOpponent logic correctly handles potential nulls or missing participants
    final Participant? opponent = widget.chatRoom.getOpponent(widget.currentUserId);

    // If opponent is null, display an error or placeholder item
    if (opponent == null) {
      // Consider logging this situation
      return const ListTile(
        leading: CircleAvatar(child: Icon(Icons.error)),
        title: Text('无效的会话'),
        subtitle: Text('无法找到对方信息'),
      );
    }

    final timestampText = _formatTimestamp(widget.chatRoom.lastActivityTime);
    final lastMessageText = _getLastMessagePreview(widget.chatRoom.lastMessage);

    return ListTile(
      leading: CircleAvatar(
        radius: 25, // Standard ListTile leading size adjust if needed
        backgroundImage: (opponent.avatar != null && opponent.avatar!.isNotEmpty)
            ? CachedNetworkImageProvider(opponent.avatar!)
            : null, // Use provider for CircleAvatar
        backgroundColor: Colors.grey[200], // Placeholder background
        child: (opponent.avatar == null || opponent.avatar!.isEmpty)
            ? Text(
                opponent.nickName?.isNotEmpty == true
                    ? opponent.nickName![0].toUpperCase() // Show first initial
                    : '?',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              )
            : null,
      ),
      title: Text(
        opponent.nickName ?? '未知用户',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16), // Adjust font size
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        lastMessageText,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.end, // Align text and badge to the right
        children: [
          Text(
            timestampText,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 5.0), // Space for badge
          if (widget.chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), // Adjusted padding
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10), // Make it slightly pill-shaped
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                // Handle 99+ case
                widget.chatRoom.unreadCount > 99 ? '99+' : widget.chatRoom.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            )
          else
             // Ensure consistent height when no badge is present
            const SizedBox(height: 18), 
        ],
      ),
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjust padding
    );
  }
} 