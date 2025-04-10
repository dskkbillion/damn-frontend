import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_sessions/chat_sessions_bloc.dart';
import '../widgets/chat_session_list_item.dart';
import '../widgets/empty_sessions_placeholder.dart';
import '../widgets/loading_indicator.dart';
import 'chat_detail_page.dart';

/// 聊天会话列表页面
class ChatSessionsPage extends StatefulWidget {
  /// 页面路由名称
  static const String routeName = '/chat/sessions';

  const ChatSessionsPage({Key? key}) : super(key: key);

  @override
  State<ChatSessionsPage> createState() => _ChatSessionsPageState();
}

class _ChatSessionsPageState extends State<ChatSessionsPage> {
  @override
  void initState() {
    super.initState();
    // 加载会话列表
    context.read<ChatSessionsBloc>().add(ChatSessionsLoadEvent());
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
              // 跳转到搜索页面
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatSessionsBloc, ChatSessionsState>(
        builder: (context, state) {
          if (state is ChatSessionsLoading) {
            return const LoadingIndicator();
          } else if (state is ChatSessionsLoaded) {
            return state.sessions.isEmpty
                ? const EmptySessionsPlaceholder()
                : ListView.separated(
                    itemCount: state.sessions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      return ChatSessionListItem(
                        session: session,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ChatDetailPage.routeName,
                            arguments: session,
                          );
                        },
                        onLongPress: () {
                          _showSessionOptionsDialog(context, session);
                        },
                      );
                    },
                  );
          } else if (state is ChatSessionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatSessionsBloc>().add(ChatSessionsLoadEvent());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 创建新会话
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSessionOptionsDialog(BuildContext context, dynamic session) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除会话'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatSessionsBloc>().add(ChatSessionDeleteEvent(sessionId: session.id));
                },
              ),
              ListTile(
                leading: Icon(session.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                title: Text(session.pinned ? '取消置顶' : '置顶会话'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatSessionsBloc>().add(
                    ChatSessionUpdateSettingsEvent(
                      sessionId: session.id,
                      isPinned: !session.pinned,
                      isMuted: session.muted,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(session.muted ? Icons.volume_off : Icons.volume_up),
                title: Text(session.muted ? '取消静音' : '静音通知'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatSessionsBloc>().add(
                    ChatSessionUpdateSettingsEvent(
                      sessionId: session.id,
                      isPinned: session.pinned,
                      isMuted: !session.muted,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 