import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_session.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../bloc/chat_bloc/chat_event.dart';
import '../bloc/chat_bloc/chat_state.dart';
import '../widgets/session_tile.dart';
import 'chat_detail_page.dart';

/// 会话列表页面
///
/// 显示所有聊天会话，包括操作菜单和各种状态
class ChatListPage extends StatefulWidget {
  /// 页面路由名
  static const routeName = '/chats';

  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    // 加载会话列表
    context.read<ChatBloc>().add(const LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 导航到搜索页面
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          // 处理会话操作结果
          if (state is ChatActionFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NewSessionCreated) {
            // 导航到新创建的会话详情页
            Navigator.of(context).pushNamed(
              ChatDetailPage.routeName,
              arguments: state.session.id,
            );
          } else if (state is SessionDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('会话已删除')),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatInitial || state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            return _buildChatList(context, state);
          } else if (state is ChatLoadFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(const LoadChats());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          // 默认空视图
          return const Center(child: Text('没有消息'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 创建新会话流程
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  /// 构建会话列表
  Widget _buildChatList(BuildContext context, ChatLoaded state) {
    final sessions = _getSortedSessions(state.sessions);
    
    if (sessions.isEmpty) {
      return const Center(child: Text('暂无消息'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(const RefreshChats());
        // 等待刷新完成
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return SessionTile(
            session: session,
            onTap: () => _navigateToChat(context, session),
            onLongPress: () => _showSessionOptions(context, session),
          );
        },
      ),
    );
  }

  /// 对会话进行排序（置顶优先，然后按最后消息时间）
  List<ChatSession> _getSortedSessions(List<ChatSession> sessions) {
    // 创建副本以避免修改原始列表
    final sortedSessions = List<ChatSession>.from(sessions);
    
    sortedSessions.sort((a, b) {
      // 先按置顶状态排序
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      
      // 然后按最后消息时间排序
      final aTime = a.lastMessage?.timestamp ?? a.updatedAt;
      final bTime = b.lastMessage?.timestamp ?? b.updatedAt;
      return bTime.compareTo(aTime); // 降序排列（最新的在前面）
    });
    
    return sortedSessions;
  }

  /// 导航到会话详情页
  void _navigateToChat(BuildContext context, ChatSession session) {
    if (session.unreadCount > 0) {
      // 标记为已读
      context.read<ChatBloc>().add(MarkSessionAsRead(session.id));
    }
    
    Navigator.of(context).pushNamed(
      ChatDetailPage.routeName,
      arguments: session.id,
    );
  }

  /// 显示会话操作选项
  void _showSessionOptions(BuildContext context, ChatSession session) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  session.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: session.pinned ? Theme.of(context).primaryColor : null,
                ),
                title: Text(session.pinned ? '取消置顶' : '置顶'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<ChatBloc>().add(UpdateSessionLocalState(
                    sessionId: session.id,
                    isPinned: !session.pinned,
                  ));
                },
              ),
              ListTile(
                leading: Icon(
                  session.muted ? Icons.volume_off : Icons.volume_up,
                  color: session.muted ? Theme.of(context).primaryColor : null,
                ),
                title: Text(session.muted ? '取消静音' : '静音'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<ChatBloc>().add(UpdateSessionLocalState(
                    sessionId: session.id,
                    isMuted: !session.muted,
                  ));
                },
              ),
              if (session.unreadCount > 0)
                ListTile(
                  leading: const Icon(Icons.mark_chat_read),
                  title: const Text('标记为已读'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<ChatBloc>().add(MarkSessionAsRead(session.id));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除会话', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteSession(context, session);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 确认删除会话
  void _confirmDeleteSession(BuildContext context, ChatSession session) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除此会话吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ChatBloc>().add(DeleteSession(session.id));
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
} 