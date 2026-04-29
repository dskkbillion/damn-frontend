import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing locale data
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/constants/message_type.dart';

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
    final s = AppLocalizations.of(context);
    
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
    final s = AppLocalizations.of(context);
    
    if (message == null) return '';
    // Limit preview length for text messages
    const maxLength = 30; 
    String contextPreview = message.context.length > maxLength 
        ? '${message.context.substring(0, maxLength)}...' 
        : message.context;

    switch (message.type) {
      case ChatMessageType.text:
        return contextPreview;
      case ChatMessageType.image:
        return s.chat_image_message;
      case ChatMessageType.audio:
        return s.chat_audio_message;
      // 移除 'revoke' 类型处理，因为撤回消息已在BLoC层过滤
      // TODO: Add cases for other custom types ('order', 'distribute')
      default:
        // Show context for unknown types if not empty, otherwise indicate unknown
        return contextPreview.isNotEmpty ? contextPreview : s.chat_unknown_message;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = AppLocalizations.of(context);
    
    // 获取对方信息（可能是买家或卖家）
    final opponent = widget.chatRoom.getOpponent(widget.currentUserId);

    final timestampText = _formatTimestamp(widget.chatRoom.lastActivityTime);
    final lastMessageText = _getLastMessagePreview(widget.chatRoom.lastMessage);

    return ListTile(
      leading: CircleAvatar(
        radius: 25, // Standard ListTile leading size adjust if needed
        backgroundImage: (opponent.avatar != null && opponent.avatar!.isNotEmpty)
            ? CachedNetworkImageProvider(opponent.avatar!)
            : null, // Use provider for CircleAvatar
        backgroundColor: AppColors.backgroundSecondary, // Placeholder background
        child: (opponent.avatar == null || opponent.avatar!.isEmpty)
            ? Text(
                opponent.nickName?.isNotEmpty == true
                    ? opponent.nickName![0].toUpperCase() // Show first initial
                    : '?',
                style: const TextStyle(fontSize: 20, color: AppColors.onPrimary),
              )
            : null,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opponent.nickName ?? s.chat_unknown_user,
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
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                            color: AppColors.borderInput,
                            child: const Icon(Icons.image, size: 12),
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(width: 6),
                  
                  // 商品名称
                  Flexible(
                    child: Text(
                      widget.chatRoom.productName ?? s.chat_product_default,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // 商品价格
                  if (widget.chatRoom.productPrice != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '¥${widget.chatRoom.productPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
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
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.end, // Align text and badge to the right
        children: [
          Text(
            timestampText,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 5.0), // Space for badge
          if (widget.chatRoom.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), // Adjusted padding
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10), // Make it slightly pill-shaped
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                // Handle 99+ case
                widget.chatRoom.unreadCount > 99 ? '99+' : widget.chatRoom.unreadCount.toString(),
                style: const TextStyle(color: AppColors.onPrimary, fontSize: 10),
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