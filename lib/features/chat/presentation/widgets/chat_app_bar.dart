import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../bloc/chat_bloc/chat_state.dart';

/// 聊天页面的AppBar组件
///
/// 显示对话用户的信息及提供相关操作
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 会话ID
  final String sessionId;

  const ChatAppBar({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        // 尝试从已加载的会话中获取对应的会话信息
        User? targetUser;
        bool isOnline = false;
        String? typingStatus;

        if (state is ChatLoaded) {
          final session = state.sessions.firstWhere(
            (s) => s.id == sessionId,
            orElse: () => throw Exception('Session not found'),
          );
          targetUser = session.targetUser;
          isOnline = targetUser?.isOnline ?? false;
          typingStatus = session.typingStatus;
        }

        return AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              // 用户头像
              _buildAvatar(context, targetUser),
              const SizedBox(width: 8),
              
              // 用户名和状态
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      targetUser?.displayName ?? '加载中...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    _buildStatusText(isOnline, typingStatus),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // 语音通话按钮
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // TODO: 实现语音通话功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('语音通话功能即将上线')),
                );
              },
            ),
            // 视频通话按钮
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () {
                // TODO: 实现视频通话功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('视频通话功能即将上线')),
                );
              },
            ),
            // 更多选项按钮
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showMoreOptions(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 构建头像
  Widget _buildAvatar(BuildContext context, User? user) {
    final hasAvatar = user?.avatarUrl != null;
    final theme = Theme.of(context);
    
    return CircleAvatar(
      radius: 18,
      backgroundColor: hasAvatar ? null : theme.colorScheme.primary.withOpacity(0.2),
      backgroundImage: hasAvatar 
          ? NetworkImage(user!.avatarUrl!) 
          : null,
      child: hasAvatar 
          ? null 
          : Text(
              _getInitials(user?.displayName ?? '?'),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }

  /// 构建状态文本
  Widget _buildStatusText(bool isOnline, String? typingStatus) {
    // 优先显示"正在输入"状态
    if (typingStatus != null && typingStatus.isNotEmpty) {
      return Text(
        typingStatus,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.green,
        ),
      );
    }
    
    // 显示在线状态
    return Text(
      isOnline ? '在线' : '离线',
      style: TextStyle(
        fontSize: 12,
        color: isOnline ? Colors.green : Colors.grey,
      ),
    );
  }

  /// 显示更多选项菜单
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('搜索聊天记录'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: 实现搜索聊天记录功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('搜索聊天记录功能即将上线')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('查看共享媒体'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: 实现查看共享媒体功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('查看共享媒体功能即将上线')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('通知设置'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: 实现通知设置功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知设置功能即将上线')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('屏蔽用户', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmBlockUser(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 确认屏蔽用户
  void _confirmBlockUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('屏蔽用户'),
          content: const Text('确定要屏蔽此用户吗？屏蔽后将不再收到此用户的消息。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 实现屏蔽用户功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('屏蔽用户功能即将上线')),
                );
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// 获取用户名称的首字母
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name.characters.first;
  }
} 