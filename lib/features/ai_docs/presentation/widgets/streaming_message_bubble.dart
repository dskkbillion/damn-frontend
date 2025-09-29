import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';

/// 简化的流式消息气泡组件
/// 用于显示AI流式响应的消息气泡，简单的逐字符显示
class StreamingMessageBubble extends StatelessWidget {
  final String streamingText;
  final String? fullText;
  final bool isStreaming;
  final MessageSender sender;
  final DateTime timestamp;

  const StreamingMessageBubble({
    Key? key,
    required this.streamingText,
    this.fullText,
    required this.isStreaming,
    required this.sender,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUser = sender == MessageSender.user;
    
    // 确定气泡颜色
    Color bubbleColor;
    if (isUser) {
      bubbleColor = Colors.blue[100]!;
    } else {
      bubbleColor = Colors.grey[100]!;
    }

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示流式文本 - 使用 SelectableText 支持文本选择和复制
            SelectableText(
              streamingText.isEmpty ? '...' : streamingText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            
            // 显示闪烁光标（仅在流式传输时）
            if (isStreaming)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: _BlinkingCursor(),
              ),
            
            // 🕐 移除时间戳显示 - 现在使用时间分隔符来显示时间
            // 时间戳 - 与ChatMessageWidget保持一致的格式
            // Padding(
            //   padding: const EdgeInsets.only(top: 4.0),
            //   child: Text(
            //     _formatTimestamp(timestamp),
            //     style: TextStyle(
            //       color: textColor.withOpacity(0.7),
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// 闪烁光标组件
class _BlinkingCursor extends StatefulWidget {
  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: 2,
            height: 16,
            color: Colors.black54,
          ),
        );
      },
    );
  }
} 