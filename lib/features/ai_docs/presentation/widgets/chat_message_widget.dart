import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../domain/entities/ai_chat_message_entity.dart';

/// A widget that displays a single chat message bubble.
class ChatMessageWidget extends StatelessWidget {
  final AiChatMessageEntity message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    
    // Define colors based on the new scheme
    final userBubbleColor = Theme.of(context).colorScheme.surfaceVariant; // User uses AI's old color
    // AI使用固定的浅灰色，与StreamingMessageBubble保持一致
    final aiBubbleColor = Colors.grey[100]!; // AI uses fixed light grey
    final userTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final aiTextColor = Colors.black87; // 与固定浅灰色背景匹配的文本颜色

    final color = isUser ? userBubbleColor : aiBubbleColor;
    final textColor = isUser ? userTextColor : aiTextColor;

    // Define bubble shape based on sender
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16.0),
      topRight: const Radius.circular(16.0),
      bottomLeft: Radius.circular(isUser ? 16.0 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16.0),
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          // Limit the maximum width of the bubble
          maxWidth: MediaQuery.of(context).size.width * 0.75, 
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent column from taking full width
          children: [
            // TODO: Display sender name/icon if needed (e.g., for group chats or distinct AI)
            // TODO: Handle file attachments display (e.g., show image thumbnail or file icon)
            SelectableText(
              message.content,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            // 🕐 移除时间戳显示 - 现在使用时间分隔符来显示时间
            // Optionally display timestamp
            // if (message.timestamp != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 4.0),
            //     child: Text(
            //       DateFormat('HH:mm').format(message.timestamp!), // Example format
            //       style: TextStyle(
            //         // AI消息时间戳使用固定颜色，与StreamingMessageBubble保持一致
            //         color: isUser ? textColor.withOpacity(0.7) : Colors.grey[600],
            //         fontSize: 12,
            //       ),
            //     ),
            //   ),
              // TODO: Add feedback buttons (like/dislike) for AI messages?
          ],
        ),
      ),
    );
  }
}
