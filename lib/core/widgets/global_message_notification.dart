import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';

/// 全局消息通知组件
/// 这个组件监听消息事件并在屏幕顶部显示通知
class GlobalMessageNotification extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 构造函数
  const GlobalMessageNotification({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<GlobalMessageNotification> createState() => _GlobalMessageNotificationState();
}

class _GlobalMessageNotificationState extends State<GlobalMessageNotification> {
  /// 消息通知的Overlay实体
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    
    // 监听消息事件
    EventBus().messageStream.listen((event) {
      _showNotification(event);
    });
  }
  
  /// 显示通知
  void _showNotification(ChatMessageEvent event) {
    // 检查 widget 是否还挂载
    if (!mounted) {
      print('[GlobalMessageNotification] Widget not mounted, skipping notification');
      return;
    }

    // 安全地获取当前路由
    String? currentChatId;
    try {
      // 使用 ModalRoute 获取当前路由名称（更安全）
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null && modalRoute.settings.name != null) {
        final routeName = modalRoute.settings.name!;
        // 检查是否在聊天室页面：/chat/:chatId
        final chatMatch = RegExp(r'^/chat/(\d+)$').firstMatch(routeName);
        if (chatMatch != null) {
          currentChatId = chatMatch.group(1);
        }
      }
    } catch (e) {
      print('[GlobalMessageNotification] Error getting current route: $e');
      // 无法获取当前路由，继续显示通知
    }

    // 如果当前正在该聊天室内，不显示通知
    if (currentChatId == event.chatId) {
      print('[GlobalMessageNotification] Skipping notification for current chat room: $currentChatId');
      return;
    }

    // 移除之前显示的通知
    _overlayEntry?.remove();
    _overlayEntry = null;

    // 创建新的通知
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // 点击通知跳转到对应的聊天页面
              _navigateToChatDetail(context, event);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // 头像
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 20,
                    backgroundImage: event.avatarUrl != null 
                        ? NetworkImage(event.avatarUrl!) 
                        : null,
                    child: event.avatarUrl == null
                        ? const Icon(Icons.message, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // 消息内容
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 关闭按钮
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    // 显示通知
    if (mounted) {
      Overlay.of(context)?.insert(_overlayEntry!);
      
      // 3秒后自动移除
      Future.delayed(const Duration(seconds: 3), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }
  
  /// 导航到聊天详情页
  void _navigateToChatDetail(BuildContext context, ChatMessageEvent event) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    try {
      // 使用 GoRouter 导航到聊天详情页
      final router = GoRouter.of(context);
      router.pushNamed(
        'chatRoom',
        pathParameters: {'chatId': event.chatId},
      );
      print('[GlobalMessageNotification] Navigating to chat room: ${event.chatId}');
    } catch (e) {
      print('[GlobalMessageNotification] Error navigating to chat: $e');
      // 备用方案：使用 Navigator
      try {
        Navigator.of(context).pushNamed(
          '/chat/${event.chatId}',
        );
      } catch (e2) {
        print('[GlobalMessageNotification] Fallback navigation also failed: $e2');
      }
    }
  }
  
  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 