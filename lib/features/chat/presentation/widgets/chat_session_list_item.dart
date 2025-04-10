import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

/// 聊天会话列表项组件
class ChatSessionListItem extends StatelessWidget {
  /// 会话对象
  final ChatSession session;
  
  /// 点击回调
  final VoidCallback onTap;
  
  /// 长按回调
  final VoidCallback onLongPress;

  const ChatSessionListItem({
    Key? key,
    required this.session,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: session.pinned ? Colors.grey.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            // 头像
            _buildAvatar(),
            
            const SizedBox(width: 12),
            
            // 会话信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      // 会话标题
                      Expanded(
                        child: Text(
                          session.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 时间
                      Text(
                        _formatTime(session.updatedAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 最后消息和未读数
                  Row(
                    children: [
                      // 静音图标
                      if (session.muted)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      
                      // 最后消息
                      Expanded(
                        child: Text(
                          _getLastMessageText(),
                          style: TextStyle(
                            color: session.unreadCount > 0 ? Colors.black : Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 未读数
                      if (session.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatUnreadCount(session.unreadCount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        // 头像主体
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              session.title.isNotEmpty ? session.title[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        
        // 置顶标记
        if (session.pinned)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.push_pin,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }

  String _getLastMessageText() {
    if (session.lastMessage == null) {
      return '';
    }
    
    switch (session.lastMessage!.type) {
      case MessageType.TEXT:
        return session.lastMessage!.content;
      case MessageType.IMAGE:
        return '[图片]';
      case MessageType.AUDIO:
        return '[语音]';
      case MessageType.SYSTEM:
        return '[系统消息]';
      case MessageType.ORDER_NOTIFICATION:
        return '[订单通知]';
      default:
        return '';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      // 今天
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // 昨天
      return '昨天';
    } else if (now.difference(time).inDays < 7) {
      // 一周内
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[time.weekday - 1];
    } else {
      // 更早
      return '${time.month}/${time.day}';
    }
  }

  String _formatUnreadCount(int count) {
    if (count > 99) {
      return '99+';
    } else {
      return count.toString();
    }
  }
} 