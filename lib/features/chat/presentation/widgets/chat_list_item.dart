import 'dart:convert'; // For JSON parsing

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing locale data
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';

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
    // 获取国际化资源
    final S s = S.of(context);
    
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
      return s.chat_yesterday;
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
    // 获取国际化资源
    final S s = S.of(context);
    
    if (message == null) return '';
    
    switch (message.type) {
      case 'text':
        // Limit preview length for text messages
        const maxLength = 30; 
        String contextPreview = message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
        return contextPreview;
      case 'image':
        return s.chat_image_message;
      case 'audio':
        return s.chat_audio_message;
      case 'file':
        // 解析文件信息以显示文件名
        try {
          // 尝试解析JSON格式的文件信息
          if (message.context.startsWith('{')) {
            final Map<String, dynamic> fileInfo = jsonDecode(message.context);
            final fileName = fileInfo['name'] ?? '文件';
            return '[文件] $fileName';
          }
        } catch (e) {
          // 解析失败，返回默认文件消息
        }
        return '[文件]';
      // 移除 'revoke' 类型处理，因为撤回消息已在BLoC层过滤
      // TODO: Add cases for other custom types ('order', 'distribute')
      default:
        // Show context for unknown types if not empty, otherwise indicate unknown
        const maxLength = 30;
        String contextPreview = message.context.length > maxLength 
            ? '${message.context.substring(0, maxLength)}...' 
            : message.context;
        return contextPreview.isNotEmpty ? contextPreview : s.chat_unknown_message;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final S s = S.of(context);
    
    // 获取对方信息（可能是买家或卖家）
    final opponent = widget.chatRoom.getOpponent(widget.currentUserId);

    // 如果对方信息为空，显示错误
    if (opponent == null) {
      return ListTile(
        leading: CircleAvatar(child: Icon(Icons.error)),
        title: Text(s.chat_invalid_session),
        subtitle: Text('对方信息不存在'),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opponent.nickName ?? '未知用户',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16), // Adjust font size
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 新增：如果有关联商品，显示商品信息
          if (widget.chatRoom.hasProduct) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 商品小图
                  if (widget.chatRoom.productImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: widget.chatRoom.productImage!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Container(
                            width: 20,
                            height: 20,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 12),
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(width: 6),
                  
                  // 商品名称
                  Flexible(
                    child: Text(
                      widget.chatRoom.productName ?? '商品',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // 商品价格
                  if (widget.chatRoom.productPrice != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      PriceFormatter.format(widget.chatRoom.productPrice!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
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