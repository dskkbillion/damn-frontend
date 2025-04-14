import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart'; // Import the utility function
import '../../../domain/entities/chat_session.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_type.dart'; // For preview text

/// 单个聊天会话列表项 Widget
class ChatSessionListItem extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;

  const ChatSessionListItem({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = session.lastMessage;
    String previewText = session.context ?? ''; // Default to context if available

    // Generate a more descriptive preview for non-text messages if needed
    if (lastMessage != null && lastMessage.msgType != MessageType.text && previewText.isEmpty) {
        switch (lastMessage.msgType) {
            case MessageType.image:
               previewText = '[图片]';
               break;
             case MessageType.voice:
               previewText = '[语音]';
               break;
            case MessageType.file:
                previewText = '[文件]';
                break;
            case MessageType.system:
                previewText = '[系统消息]'; // Or use lastMessage.context
                break;
            default:
                previewText = '[未知消息]';
        }
    }
     // Handle revoked message preview
    if (lastMessage?.withdrawFlag == true) {
       // Decide if you want to show who revoked it or a generic message
       previewText = '消息已撤回'; // Simple generic preview
    }


    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              session.partnerNickname, // Use the helper getter from ChatSession
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatRelativeTime(session.lastMessageTimestamp, context), // Use the utility function
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      subtitle: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Expanded(
             child: Text(
               previewText,
               style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  // Bold if unread? Requires state management
                  // fontWeight: session.messageNum > 0 ? FontWeight.bold : FontWeight.normal,
               ),
               overflow: TextOverflow.ellipsis,
             ),
           ),
           if (session.messageNum > 0)
              _buildUnreadBadge(context, session.messageNum),
         ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // dense: true, // Consider if needed
    );
  }

  Widget _buildAvatar() {
    // TODO: Replace with actual user avatar URL from session.partnerAvatar
    return CircleAvatar(
      radius: 24.0,
      backgroundImage: session.partnerAvatar != null && session.partnerAvatar!.isNotEmpty
          ? NetworkImage(session.partnerAvatar!) // Load actual avatar
          : null,
      backgroundColor: Colors.grey[300],
      child: session.partnerAvatar == null || session.partnerAvatar!.isEmpty
          ? const Icon(Icons.person, size: 28, color: Colors.white) // Placeholder icon
          : null,
    );
  }

  Widget _buildUnreadBadge(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red, // Standard color for unread badges
        borderRadius: BorderRadius.circular(10.0),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(), // Cap at 99+
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 