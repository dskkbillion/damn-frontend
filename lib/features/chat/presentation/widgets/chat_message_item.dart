import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// 聊天消息项组件
class ChatMessageItem extends StatelessWidget {
  /// 消息对象
  final Message message;
  
  /// 是否显示时间标签
  final bool showTimeLabel;
  
  /// 是否显示发送者头像
  final bool showSenderAvatar;
  
  /// 搜索高亮文本
  final String? searchHighlight;

  const ChatMessageItem({
    Key? key,
    required this.message,
    this.showTimeLabel = false,
    this.showSenderAvatar = true,
    this.searchHighlight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = message.senderType == MessageSenderType.USER && 
                              message.senderId == 'currentUserId'; // 实际应根据当前登录用户ID判断
    
    return Column(
      children: [
        // 时间标签
        if (showTimeLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        
        // 消息内容
        Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 对方消息的头像
            if (!isCurrentUser && showSenderAvatar)
              _buildAvatar(),
            
            const SizedBox(width: 8),
            
            // 消息气泡
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 系统消息显示类型标签
                    if (message.senderType == MessageSenderType.SYSTEM)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '系统消息',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    // 消息内容 - 根据类型显示不同内容
                    _buildMessageContent(context),
                    
                    // 状态指示
                    if (isCurrentUser)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _buildStatusIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 自己消息的头像
            if (isCurrentUser && showSenderAvatar)
              _buildAvatar(),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        message.senderId.isNotEmpty ? message.senderId[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.TEXT:
        return searchHighlight != null && searchHighlight!.isNotEmpty
            ? _buildHighlightedText(context)
            : Text(message.content);
            
      case MessageType.IMAGE:
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: 200,
          ),
          child: GestureDetector(
            onTap: () {
              // 显示图片预览
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.content,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        
      case MessageType.AUDIO:
        return Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_arrow, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '1:23', // 应该从音频文件中获取时长
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
        
      case MessageType.SYSTEM:
      case MessageType.ORDER_NOTIFICATION:
        return Text(
          message.content,
          style: const TextStyle(color: Colors.black54),
        );
        
      default:
        return Text(message.content);
    }
  }

  Widget _buildHighlightedText(BuildContext context) {
    final String content = message.content;
    final String query = searchHighlight!.toLowerCase();
    final String contentLower = content.toLowerCase();
    
    if (!contentLower.contains(query)) {
      return Text(content);
    }
    
    final List<InlineSpan> spans = [];
    int start = 0;
    
    while (true) {
      final int index = contentLower.indexOf(query, start);
      if (index == -1) {
        // 添加最后一段非高亮文本
        if (start < content.length) {
          spans.add(TextSpan(text: content.substring(start)));
        }
        break;
      }
      
      // 添加高亮前的文本
      if (index > start) {
        spans.add(TextSpan(text: content.substring(start, index)));
      }
      
      // 添加高亮文本
      spans.add(
        TextSpan(
          text: content.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      
      start = index + query.length;
    }
    
    return RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: spans));
  }

  Widget _buildStatusIndicator() {
    switch (message.status) {
      case MessageStatus.SENDING:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        );
        
      case MessageStatus.SENT:
        return const Icon(Icons.check, size: 12, color: Colors.grey);
        
      case MessageStatus.DELIVERED:
        return const Icon(Icons.done_all, size: 12, color: Colors.grey);
        
      case MessageStatus.READ:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
        
      case MessageStatus.FAILED:
        return const Icon(Icons.error_outline, size: 12, color: Colors.red);
        
      case MessageStatus.REVOKED:
        return const Text(
          '已撤回',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        );
        
      default:
        return const SizedBox();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    final timeString = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    
    if (messageDate == today) {
      return timeString;
    } else if (messageDate == yesterday) {
      return '昨天 $timeString';
    } else if (now.difference(timestamp).inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      final weekday = weekdays[timestamp.weekday - 1];
      return '$weekday $timeString';
    } else {
      return '${timestamp.month}月${timestamp.day}日 $timeString';
    }
  }
} 