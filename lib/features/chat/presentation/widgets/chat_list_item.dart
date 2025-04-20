import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/participant.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoom chatRoom;
  final VoidCallback? onTap; // Add onTap later for navigation
  // TODO: Get currentUserId properly, maybe from Bloc context
  final int currentUserId = 1; // Placeholder: Assuming current user ID is 1

  const ChatListItem({
    super.key,
    required this.chatRoom,
    this.onTap, 
  });

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays == 0 && timestamp.day == now.day) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat('E', 'zh_CN').format(timestamp); // Locale for Chinese weekday
    } else {
      return DateFormat('MM/dd').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opponent = chatRoom.getOpponent(currentUserId);
    final timestampText = _formatTimestamp(chatRoom.lastActivityTime);
    final lastMessageText = chatRoom.lastMessage?.context ?? ''; // Handle null message

    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: (opponent.avatar != null && opponent.avatar!.isNotEmpty)
            ? NetworkImage(opponent.avatar!) 
            : null, // No need for AssetImage fallback if avatar is just null
        backgroundColor: Colors.grey[300], // Placeholder color
        child: (opponent.avatar == null || opponent.avatar!.isEmpty)
            ? Text(
                opponent.nickName?.isNotEmpty == true ? opponent.nickName![0] : '?',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              )
            : null,
      ),
      title: Text(
        opponent.nickName ?? '未知用户',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timestampText,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          if (chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chatRoom.unreadCount > 99 ? '99+' : chatRoom.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
      onTap: onTap, 
    );
  }
} 