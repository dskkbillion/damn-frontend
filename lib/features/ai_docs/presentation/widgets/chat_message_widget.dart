import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

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
    final aiBubbleColor = AppColors.backgroundSecondary; // AI uses backgroundSecondary
    final userTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final aiTextColor = AppColors.textPrimary; // 与固定浅灰色背景匹配的文本颜色

    final color = isUser ? userBubbleColor : aiBubbleColor;
    final textColor = isUser ? userTextColor : aiTextColor;

    // Define bubble shape based on sender
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(AppDimensions.radiusLg),
      topRight: const Radius.circular(AppDimensions.radiusLg),
      bottomLeft: Radius.circular(isUser ? AppDimensions.radiusLg : 0),
      bottomRight: Radius.circular(isUser ? 0 : AppDimensions.radiusLg),
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          // Limit the maximum width of the bubble
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs, horizontal: AppDimensions.spacingSm),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent column from taking full width
          children: [
            SelectableText(
              message.content,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            // 🕐 移除时间戳显示 - 现在使用时间分隔符来显示时间
          ],
        ),
      ),
    );
  }
}
