import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_box.dart';
import '../widgets/loading_indicator.dart';

/// 聊天详情页面
class ChatDetailPage extends StatefulWidget {
  /// 页面路由名称
  static const String routeName = '/chat/detail';

  /// 会话对象
  final ChatSession session;

  const ChatDetailPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // 标记会话为已读
    context.read<ChatMessagesBloc>().add(MarkSessionAsReadEvent(sessionId: widget.session.id));
    
    // 加载消息历史
    context.read<ChatMessagesBloc>().add(LoadMessagesEvent(sessionId: widget.session.id));
    
    // 监听滚动事件，实现上拉加载更多
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      // 获取当前已加载消息的最早一条作为分页标记
      final state = context.read<ChatMessagesBloc>().state;
      if (state is MessagesLoaded && state.messages.isNotEmpty) {
        // 按时间排序找到最早的消息
        final messages = List<Message>.from(state.messages);
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final oldestMessage = messages.first;
        
        context.read<ChatMessagesBloc>().add(
          LoadMoreMessagesEvent(
            sessionId: widget.session.id,
            beforeMessageId: oldestMessage.id,
          ),
        );
      }
      
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      context.read<ChatMessagesBloc>().add(
        SendMessageEvent(
          sessionId: widget.session.id,
          content: content,
          type: MessageType.TEXT,
        ),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 显示更多选项菜单
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading && !state.isLoadingMore) {
                  return const LoadingIndicator();
                } else if (state is MessagesLoaded) {
                  return ChatMessageList(
                    messages: state.messages,
                    scrollController: _scrollController,
                    isLoadingMore: state is MessagesLoading && state.isLoadingMore,
                    onMessageLongPress: _showMessageOptions,
                  );
                } else if (state is MessagesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('加载失败: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatMessagesBloc>().add(
                              LoadMessagesEvent(
                                sessionId: widget.session.id,
                              ),
                            );
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
          ),
          
          // 输入框
          ChatInputBox(
            controller: _messageController,
            onSendPressed: _sendMessage,
            onImagePressed: _pickImage,
            onVoicePressed: _recordVoice,
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final bool canRevoke = message.senderId == 'currentUserId' && // 当前用户发送的
            DateTime.now().difference(message.timestamp).inMinutes < 2; // 2分钟内可撤回
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('复制'),
                onTap: () {
                  Navigator.pop(context);
                  // 复制消息
                },
              ),
              if (canRevoke)
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('撤回'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<ChatMessagesBloc>().add(
                      RevokeMessageEvent(messageId: message.id),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatMessagesBloc>().add(
                    DeleteMessageEvent(messageId: message.id),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage() {
    // 选择图片并发送
  }

  void _recordVoice() {
    // 录制语音并发送
  }
} 