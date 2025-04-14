import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_status.dart';
import '../../../domain/entities/message_type.dart';

/// 单个聊天消息气泡 Widget
class ChatMessageItem extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final VoidCallback? onLongPress; // Callback for long press actions (e.g., context menu)
  final VoidCallback? onTap; // Callback for tap actions (e.g., image preview)
  final VoidCallback? onRetry; // Callback to retry sending a failed message

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.onLongPress,
    this.onTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isSentByMe ? Colors.blue[100] : Colors.grey[200];
    final textColor = isSentByMe ? Colors.black87 : Colors.black87;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap ?? () => _handleTap(context), // Use default tap handler if none provided
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end, // Align status icon with bottom
          children: [
            if (!isSentByMe) _buildAvatar(), // Show avatar for received messages
            Flexible(
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  if (!isSentByMe && message.senderName != null) // Show sender name for group chats
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 4.0),
                      child: Text(
                        message.senderName!, 
                        style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                     mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       if (isSentByMe)
                        _buildStatusIndicator(context),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: _buildMessageContent(context, textColor),
                        ),
                      ),
                      // if (!isSentByMe)
                      //   _buildStatusIndicator(context), // Status for received messages if needed
                    ],
                  ),
                  // TODO: Add timestamp below bubble if needed
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 4.0),
                  //   child: Text(
                  //     DateFormat('HH:mm').format(message.createTime ?? DateTime.now()), 
                  //     style: TextStyle(fontSize: 10.0, color: Colors.grey)
                  //   ),
                  // ),
                ],
              ),
            ),
            if (isSentByMe) _buildAvatar(), // Show avatar for sent messages
          ],
        ),
      ),
    );
  }

  // Builds the message content based on message type
  Widget _buildMessageContent(BuildContext context, Color textColor) {
     if (message.withdrawFlag) {
       return Text(
         isSentByMe ? '你撤回了一条消息' : '对方撤回了一条消息', 
         style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
       );
     }
    
     switch (message.msgType) {
      case MessageType.text:
        return Text(
          message.context ?? '',
          style: TextStyle(fontSize: 16.0, color: textColor),
        );
      case MessageType.image:
        // TODO: Implement image display (using message.extra or a dedicated field)
        return Text(
          '[图片] 占位符', 
           style: TextStyle(fontSize: 16.0, color: textColor, fontStyle: FontStyle.italic),
        );
      case MessageType.file:
        // TODO: Implement file display
         return Text(
           '[文件] ${message.context ?? '未知文件'}', 
           style: TextStyle(fontSize: 16.0, color: textColor, fontStyle: FontStyle.italic),
         );
      case MessageType.voice:
       // TODO: Implement voice message playback UI
        return Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             Icon(isSentByMe ? Icons.multitrack_audio : Icons.multitrack_audio, color: textColor, size: 18),
             const SizedBox(width: 8),
             Text(
               '[语音] ${message.extra?['duration'] ?? '--'}"', // Assuming duration is in extra
               style: TextStyle(fontSize: 16.0, color: textColor),
             ),
           ],
         );
       case MessageType.system:
         // System messages might not use a bubble, handle separately in the list if needed
         return Text(
           message.context ?? '系统消息', 
           style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
         );
       default:
         return Text(
           '[不支持的消息类型]',
           style: TextStyle(fontSize: 14.0, color: Colors.red[400]),
         );
     }
  }

  // Builds the avatar circle
  Widget _buildAvatar() {
    // TODO: Replace with actual user avatar URL from message.senderAvatar or user profile
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 20.0,
        // backgroundImage: NetworkImage(message.senderAvatar ?? 'DEFAULT_AVATAR_URL'),
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 24, color: Colors.white), // Placeholder
      ),
    );
  }

  // Builds the status indicator (sending, sent, failed, read)
  Widget _buildStatusIndicator(BuildContext context) {
    Widget indicator;
    switch (message.status) {
      case MessageStatus.sending:
        indicator = const SizedBox(
          width: 16.0, 
          height: 16.0, 
          child: CircularProgressIndicator(strokeWidth: 2.0)
        );
        break;
      case MessageStatus.sent:
        // Could show a single checkmark or nothing for just sent
        indicator = const SizedBox.shrink(); // Or Icon(Icons.check, size: 16.0, color: Colors.grey)
        break;
      case MessageStatus.delivered:
         // TODO: Differentiate between delivered and read if needed (e.g., double check)
        indicator = Icon(Icons.check_circle_outline, size: 16.0, color: Colors.grey);
        break;
      case MessageStatus.read:
        indicator = Icon(Icons.check_circle, size: 16.0, color: Colors.blue); // Example: Blue check for read
        break;
      case MessageStatus.failed:
        indicator = InkWell(
          onTap: onRetry, // Allow tapping the icon to retry
          child: Icon(Icons.error, size: 18.0, color: Colors.red[400]),
        );
        break;
       default:
         indicator = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Add some padding
      child: indicator,
    );
  }

  // Default tap handler (e.g., for opening images/files)
  void _handleTap(BuildContext context) {
     if (message.withdrawFlag) return; // Don't handle taps on revoked messages

     switch (message.msgType) {
       case MessageType.image:
         print("Tapped image message: ${message.id}");
         // TODO: Navigate to image preview screen
         break;
       case MessageType.file:
         print("Tapped file message: ${message.id}");
         // TODO: Handle file opening/download
         break;
       case MessageType.voice:
          print("Tapped voice message: ${message.id}");
         // TODO: Implement voice message playback
         break;
       default:
         // No default action for text or other types
         break;
     }
  }
} 