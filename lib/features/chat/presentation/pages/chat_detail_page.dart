import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message.dart';
import '../bloc/message_bloc/message_bloc.dart';
import '../bloc/message_bloc/message_event.dart';
import '../bloc/message_bloc/message_state.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

/// 聊天详情页面
///
/// 显示单个聊天会话的消息历史及提供消息发送功能
class ChatDetailPage extends StatefulWidget {
  /// 页面路由名
  static const routeName = '/chat-detail';

  /// 会话ID
  final String sessionId;

  const ChatDetailPage({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  /// 是否正在加载更多消息
  bool _isLoadingMore = false;
  
  /// 是否还有更多消息可加载
  bool _hasMoreMessages = true;
  
  @override
  void initState() {
    super.initState();
    
    // 初始加载消息
    context.read<MessageBloc>().add(LoadMessages(
      sessionId: widget.sessionId,
      limit: 20,
      initial: true,
    ));
    
    // 添加滚动监听，实现下拉加载更多
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  /// 滚动监听，处理下拉加载更多历史消息
  void _scrollListener() {
    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent + 50 &&
        !_isLoadingMore &&
        _hasMoreMessages) {
      _loadMoreMessages();
    }
  }
  
  /// 加载更多历史消息
  void _loadMoreMessages() {
    final state = context.read<MessageBloc>().state;
    if (state is MessagesLoaded) {
      if (state.messages.isEmpty || !state.hasMore) {
        setState(() {
          _hasMoreMessages = false;
        });
        return;
      }
      
      setState(() {
        _isLoadingMore = true;
      });
      
      // 获取最早的消息ID作为加载更多的标记
      final String? beforeMessageId = state.messages.isNotEmpty 
          ? state.messages.last.id 
          : null;
      
      if (beforeMessageId != null) {
        context.read<MessageBloc>().add(LoadMoreMessages(
          sessionId: widget.sessionId,
          beforeMessageId: beforeMessageId,
        ));
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(sessionId: widget.sessionId),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: BlocConsumer<MessageBloc, MessageState>(
              listener: (context, state) {
                if (state is MessageActionFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is MessagesLoaded) {
                  // 第一次加载完成后滚动到底部
                  if (state.isInitialLoad && state.messages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  }
                  
                  // 加载更多完成
                  if (_isLoadingMore) {
                    setState(() {
                      _isLoadingMore = false;
                    });
                  }
                  
                  // 更新是否还有更多消息
                  setState(() {
                    _hasMoreMessages = state.hasMore;
                  });
                }
              },
              builder: (context, state) {
                if (state is MessageInitial || 
                    (state is MessagesLoading && state.isInitialLoading)) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MessagesLoaded) {
                  return _buildMessageList(context, state);
                } else if (state is MessagesLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MessageBloc>().add(LoadMessages(
                              sessionId: widget.sessionId,
                              limit: 20,
                              initial: true,
                            ));
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
          ),
          
          // 输入框
          ChatInput(
            sessionId: widget.sessionId,
            onMessageSent: _scrollToBottom,
          ),
        ],
      ),
    );
  }
  
  /// 构建消息列表
  Widget _buildMessageList(BuildContext context, MessagesLoaded state) {
    final messages = state.messages;
    
    if (messages.isEmpty) {
      return const Center(child: Text('没有消息记录，发送第一条消息开始对话吧！'));
    }
    
    return Stack(
      children: [
        // 消息列表
        ListView.builder(
          controller: _scrollController,
          reverse: true, // 倒序显示，最新的消息在底部
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isLastInGroup = _isLastInMessageGroup(messages, index);
            final isFirstInGroup = _isFirstInMessageGroup(messages, index);
            
            return MessageBubble(
              message: message,
              isLastInGroup: isLastInGroup,
              isFirstInGroup: isFirstInGroup,
              onResend: message.status == MessageStatus.failed 
                  ? () => _handleResendMessage(message.id) 
                  : null,
              onDeleteMessage: () => _handleDeleteMessage(message.id),
              onRevokeMessage: message.senderId == state.currentUserId && 
                              message.status != MessageStatus.sending &&
                              message.status != MessageStatus.failed
                  ? () => _handleRevokeMessage(message.id)
                  : null,
            );
          },
        ),
        
        // 加载更多指示器
        if (_isLoadingMore)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
  
  /// 判断是否是一组消息中的最后一条
  /// 
  /// 相同发送者且消息时间间隔小于2分钟的消息会被归为一组
  bool _isLastInMessageGroup(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];
    
    // 如果发送者不同，则是最后一条
    if (currentMessage.senderId != nextMessage.senderId) return true;
    
    // 如果时间间隔大于2分钟，则是最后一条
    final timeDiff = currentMessage.timestamp.difference(nextMessage.timestamp).inMinutes;
    return timeDiff >= 2;
  }
  
  /// 判断是否是一组消息中的第一条
  bool _isFirstInMessageGroup(List<Message> messages, int index) {
    if (index == 0) return true;
    
    final currentMessage = messages[index];
    final prevMessage = messages[index - 1];
    
    // 如果发送者不同，则是第一条
    if (currentMessage.senderId != prevMessage.senderId) return true;
    
    // 如果时间间隔大于2分钟，则是第一条
    final timeDiff = prevMessage.timestamp.difference(currentMessage.timestamp).inMinutes;
    return timeDiff >= 2;
  }
  
  /// 处理重发消息事件
  void _handleResendMessage(String messageId) {
    context.read<MessageBloc>().add(RetrySendMessage(messageId: messageId));
  }
  
  /// 处理删除消息事件
  void _handleDeleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除消息'),
          content: const Text('确定要删除此消息吗？这将从你的设备上删除此消息，但对方可能仍然可以看到它。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MessageBloc>().add(DeleteMessage(messageId: messageId));
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  /// 处理撤回消息事件
  void _handleRevokeMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('撤回消息'),
          content: const Text('确定要撤回此消息吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MessageBloc>().add(RevokeMessage(messageId: messageId));
              },
              child: const Text('撤回'),
            ),
          ],
        );
      },
    );
  }
  
  /// 滚动到消息列表底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // 因为是反向列表，所以是0
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
} 