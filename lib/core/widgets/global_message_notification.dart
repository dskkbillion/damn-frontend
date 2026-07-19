import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/events/event_bus.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // 导入 rootNavigatorKey

/// 全局消息通知组件
/// 这个组件监听消息事件并在屏幕顶部显示通知
class GlobalMessageNotification extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 构造函数
  const GlobalMessageNotification({
    super.key,
    required this.child,
  });

  @override
  State<GlobalMessageNotification> createState() =>
      _GlobalMessageNotificationState();
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
      AppLogger.d(
          '[GlobalMessageNotification] Widget not mounted, skipping notification');
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
      AppLogger.d(
          '[GlobalMessageNotification] Error getting current route: $e');
      // 无法获取当前路由，继续显示通知
    }

    // 如果当前正在该聊天室内，不显示通知
    if (currentChatId == event.chatId) {
      AppLogger.d(
          '[GlobalMessageNotification] Skipping notification for current chat room: $currentChatId');
      return;
    }

    // 安全地移除之前显示的通知
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        AppLogger.d(
            '[GlobalMessageNotification] Error removing previous overlay: $e');
      }
      _overlayEntry = null;
    }

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
    if (!mounted) {
      AppLogger.d(
          '[GlobalMessageNotification] Widget not mounted when trying to show notification');
      _overlayEntry = null;
      return;
    }

    try {
      // 使用全局 navigator key 直接访问 Overlay，避免 context 问题
      final overlay = rootNavigatorKey.currentState?.overlay;
      if (overlay == null) {
        AppLogger.d(
            '[GlobalMessageNotification] No Overlay found from navigator key');
        _overlayEntry = null;
        return;
      }

      overlay.insert(_overlayEntry!);
      AppLogger.d(
          '[GlobalMessageNotification] ✅ Notification displayed; content omitted');

      // 3秒后自动移除
      Future.delayed(const Duration(seconds: 3), () {
        if (_overlayEntry != null && mounted) {
          try {
            _overlayEntry!.remove();
          } catch (e) {
            AppLogger.d(
                '[GlobalMessageNotification] Error auto-removing overlay: ${e.runtimeType}');
          }
          _overlayEntry = null;
        }
      });
    } catch (e) {
      AppLogger.d(
          '[GlobalMessageNotification] Error showing notification: ${e.runtimeType}');
      _overlayEntry = null;
    }
  }

  /// 导航到聊天详情页
  void _navigateToChatDetail(BuildContext context, ChatMessageEvent event) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    try {
      // 使用 go 替代 push/pushNamed，避免 SmartPage key 冲突断言崩溃
      context.go('/chat/refactored/${event.chatId}');
      AppLogger.d(
          '[GlobalMessageNotification] Navigating to chat room (refactored): ${event.chatId}');
    } catch (e) {
      AppLogger.d('[GlobalMessageNotification] Error navigating to chat: $e');
    }
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        AppLogger.d(
            '[GlobalMessageNotification] Error removing overlay in dispose: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
