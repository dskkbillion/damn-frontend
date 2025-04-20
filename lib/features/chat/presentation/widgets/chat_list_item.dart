import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cached_network_image/cached_network_image.dart'; // Import for avatar

import '../../domain/entities/chat_message.dart'; // Import ChatMessage for type check
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onTap; // Add onTap later for navigation
  final int currentUserId; // Added: Get currentUserId from caller

  const ChatListItem({
    super.key,
    required this.chatRoom,
    required this.currentUserId, // Make it required
    this.onTap,
  });

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // Adjust formatting based on frontend.md description
    if (difference.inDays == 0 && timestamp.day == now.day) {
      // Today: HH:mm
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1 || (difference.inDays == 0 && timestamp.day != now.day)) {
        // Yesterday
        return '昨天';
    } else if (difference.inDays < 7) {
       // Within a week: Weekday (e.g., 星期一)
      return DateFormat('E', 'zh_CN').format(timestamp); 
    } else {
       // Older: MM/dd
      return DateFormat('MM/dd').format(timestamp);
    }
  }

  // Helper function to get last message preview text
  String _getLastMessagePreview(ChatMessage? message) {
    if (message == null) return '';
    switch (message.type) {
      case 'text':
        return message.context;
      case 'image':
        return '[图片]';
      case 'audio':
        return '[语音]';
      case 'revoke': // Assuming 'revoke' is the type for withdrawn messages
        return '[消息已撤回]';
      // Add cases for other types like 'order', 'distribute' if needed
      default:
        return message.context.isNotEmpty ? message.context : '[未知消息类型]';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure opponent is valid before building
    final opponent = chatRoom.getOpponent(currentUserId);
    if (opponent == null) {
      // Should not happen if ChatRoom logic is correct, but add safety
      return const SizedBox.shrink(); 
    }

    final timestampText = _formatTimestamp(chatRoom.lastActivityTime);
    final lastMessageText = _getLastMessagePreview(chatRoom.lastMessage);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
          children: [
            // --- Avatar --- 
            CircleAvatar(
              radius: 28, // Slightly larger avatar
              backgroundImage: (opponent.avatar != null && opponent.avatar!.isNotEmpty)
                  ? CachedNetworkImageProvider(opponent.avatar!)
                  : null, 
              backgroundColor: Colors.grey[300], 
              child: (opponent.avatar == null || opponent.avatar!.isEmpty)
                  ? Text(
                      opponent.nickName?.isNotEmpty == true ? opponent.nickName![0] : '?',
                      style: const TextStyle(fontSize: 20, color: Colors.white), // Larger font
                    )
                  : null,
            ),
            const SizedBox(width: 12.0), // Space between avatar and text

            // --- Nickname and Last Message --- 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically within column
                children: [
                  Text(
                    opponent.nickName ?? '未知用户',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500), // Slightly larger nickname
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3.0), // Space between nickname and message
                  Text(
                    lastMessageText,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0), // Space between text and trailing info

            // --- Timestamp and Unread Count --- 
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                Text(
                  timestampText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 6.0), // More space for badge
                if (chatRoom.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle, 
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18, 
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else 
                  const SizedBox(height: 18), // Placeholder to maintain height alignment
              ],
            ),
          ],
        ),
      ),
    );
  }
} 