import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/message.dart';

/// 消息气泡组件
///
/// 根据消息类型和发送者显示不同样式的气泡
class MessageBubble extends StatelessWidget {
  /// 消息数据
  final Message message;
  
  /// 是否是一组消息中的最后一条
  final bool isLastInGroup;
  
  /// 是否是一组消息中的第一条
  final bool isFirstInGroup;
  
  /// 重发消息回调
  final VoidCallback? onResend;
  
  /// 删除消息回调
  final VoidCallback? onDeleteMessage;
  
  /// 撤回消息回调
  final VoidCallback? onRevokeMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    this.isLastInGroup = true,
    this.isFirstInGroup = true,
    this.onResend,
    this.onDeleteMessage,
    this.onRevokeMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 系统消息特殊处理
    if (message.type == MessageType.system) {
      return _buildSystemMessage(context);
    }
    
    // 判断是否是自己发送的消息
    final isSentByMe = message.senderId == message.currentUserId;
    
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 16 : 2,
        bottom: isLastInGroup ? 16 : 2,
      ),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 对方头像（仅在消息组最后一条显示）
          if (!isSentByMe && isLastInGroup) 
            _buildAvatar(context)
          else if (!isSentByMe && !isLastInGroup)
            const SizedBox(width: 36), // 占位，保持消息对齐
            
          // 左侧空间
          const SizedBox(width: 8),
          
          // 消息内容
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 发送者名称（仅在消息组第一条显示）
                if (!isSentByMe && isFirstInGroup)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.senderName ?? '未知用户',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                // 消息气泡
                GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(context, isSentByMe),
                      borderRadius: _getBubbleBorderRadius(isSentByMe),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // 消息内容
                        _buildMessageContent(context, isSentByMe),
                        
                        // 时间和状态
                        if (isLastInGroup)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 时间戳
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSentByMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                
                                // 消息状态（仅自己发送的消息显示）
                                if (isSentByMe)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: _buildStatusIcon(context),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // 失败重发按钮
                if (message.status == MessageStatus.failed && onResend != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '发送失败',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                        TextButton(
                          onPressed: onResend,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('重试', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // 右侧空间
          const SizedBox(width: 8),
          
          // 自己的头像（仅在消息组最后一条显示）
          if (isSentByMe && isLastInGroup) 
            _buildAvatar(context)
          else if (isSentByMe && !isLastInGroup)
            const SizedBox(width: 36), // 占位，保持消息对齐
        ],
      ),
    );
  }

  /// 构建系统消息
  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar(BuildContext context) {
    // TODO: 使用实际用户头像
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      backgroundImage: message.senderAvatar != null
          ? NetworkImage(message.senderAvatar!)
          : null,
      child: message.senderAvatar == null
          ? Text(
              _getInitials(message.senderName ?? '?'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          : null,
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(BuildContext context, bool isSentByMe) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black,
          ),
        );
        
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.content,
            width: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 150,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 40),
                    SizedBox(height: 8),
                    Text('加载失败'),
                  ],
                ),
              );
            },
          ),
        );
        
      case MessageType.voice:
        // 语音消息
        return Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.mic,
                color: isSentByMe ? Colors.white : Theme.of(context).colorScheme.primary,
              ),
              const Spacer(),
              Text(
                '${message.duration ?? 0}″',
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        );
        
      case MessageType.file:
        // 文件消息
        return Container(
          width: 220,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSentByMe 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.8) 
                : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                color: isSentByMe ? Colors.white : Theme.of(context).colorScheme.primary,
                size: 36,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileName ?? 'Unknown file',
                      style: TextStyle(
                        color: isSentByMe ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.fileSize ?? 'Unknown size',
                      style: TextStyle(
                        color: isSentByMe ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        
      case MessageType.location:
        // 位置消息
        return Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('assets/images/map_placeholder.png'),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '位置信息',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        
      default:
        return Text(
          '不支持的消息类型',
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  /// 构建消息状态图标
  Widget _buildStatusIcon(BuildContext context) {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.white70);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 12, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 获取气泡背景颜色
  Color _getBubbleColor(BuildContext context, bool isSentByMe) {
    if (isSentByMe) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[200]!;
    }
  }

  /// 获取气泡边框圆角
  BorderRadius _getBubbleBorderRadius(bool isSentByMe) {
    const double radius = 16;
    
    if (isSentByMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    }
  }

  /// 显示消息选项菜单
  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('复制'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: 实现复制功能
                },
              ),
              if (message.senderId == message.currentUserId &&
                  message.status != MessageStatus.sending &&
                  message.status != MessageStatus.failed &&
                  onRevokeMessage != null)
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('撤回'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onRevokeMessage?.call();
                  },
                ),
              if (onDeleteMessage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDeleteMessage?.call();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  /// 获取名称首字母
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.characters.first;
  }
} 