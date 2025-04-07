import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/chat_session.dart';
import '../../domain/entities/message.dart';

/// 聊天会话列表项
///
/// 显示会话的基本信息，包括头像、名称、最后消息、时间、未读数量等
class SessionTile extends StatelessWidget {
  /// 会话数据
  final ChatSession session;
  
  /// 点击事件回调
  final VoidCallback onTap;
  
  /// 长按事件回调
  final VoidCallback? onLongPress;

  const SessionTile({
    Key? key,
    required this.session,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: session.pinned ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : null,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 头像
            _buildAvatar(context),
            const SizedBox(width: 12),
            
            // 会话信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名和时间
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.targetUser?.displayName ?? '未知用户',
                          style: TextStyle(
                            fontWeight: session.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(session.lastMessage?.timestamp ?? session.updatedAt),
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // 最后消息内容和未读数
                  Row(
                    children: [
                      // 显示消息状态图标（如发送中、已送达等）
                      if (session.lastMessage != null && 
                          session.lastMessage!.senderId == session.currentUserId)
                        _buildMessageStatusIcon(context, session.lastMessage!),
                                              
                      Expanded(
                        child: Text(
                          _getLastMessageText(session.lastMessage),
                          style: TextStyle(
                            color: session.unreadCount > 0 
                                ? theme.textTheme.bodyMedium?.color 
                                : theme.textTheme.bodySmall?.color,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 未读消息数量
                      if (session.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Text(
                            session.unreadCount > 99 ? '99+' : session.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                      // 静音图标
                      if (session.muted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
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

  /// 构建头像组件
  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = session.targetUser?.avatarUrl != null;
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: hasAvatar ? null : theme.colorScheme.primary.withOpacity(0.2),
          backgroundImage: hasAvatar 
              ? NetworkImage(session.targetUser!.avatarUrl!) 
              : null,
          child: hasAvatar 
              ? null 
              : Text(
                  _getInitials(session.targetUser?.displayName ?? '?'),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        
        // 在线状态指示器
        if (session.targetUser?.isOnline == true)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建消息状态图标
  Widget _buildMessageStatusIcon(BuildContext context, Message message) {
    switch (message.status) {
      case MessageStatus.sending:
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        );
      case MessageStatus.sent:
        return const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(Icons.check, size: 14, color: Colors.grey),
        );
      case MessageStatus.delivered:
        return const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(Icons.done_all, size: 14, color: Colors.grey),
        );
      case MessageStatus.read:
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(Icons.done_all, size: 14, color: Theme.of(context).colorScheme.primary),
        );
      case MessageStatus.failed:
        return const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(Icons.error_outline, size: 14, color: Colors.red),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 格式化最后消息时间
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      // 今天的消息只显示时间
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDay == yesterday) {
      // 昨天的消息显示"昨天"
      return '昨天';
    } else if (now.difference(dateTime).inDays < 7) {
      // 一周内的消息显示星期几
      return DateFormat('EEEE', 'zh_CN').format(dateTime);
    } else {
      // 更早的消息显示日期
      return DateFormat('yyyy/MM/dd').format(dateTime);
    }
  }

  /// 获取最后一条消息的显示文本
  String _getLastMessageText(Message? lastMessage) {
    if (lastMessage == null) {
      return '暂无消息';
    }

    // 根据消息类型返回不同的文本
    switch (lastMessage.type) {
      case MessageType.text:
        return lastMessage.content;
      case MessageType.image:
        return '[图片]';
      case MessageType.voice:
        return '[语音]';
      case MessageType.video:
        return '[视频]';
      case MessageType.file:
        return '[文件]';
      case MessageType.location:
        return '[位置]';
      case MessageType.system:
        return lastMessage.content;
      default:
        return '未知消息类型';
    }
  }

  /// 获取用户名称的首字母
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    // 尝试获取第一个字符
    return name.characters.first;
  }
} 