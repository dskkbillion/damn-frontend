import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import '../bloc/ai_chat/ai_chat_bloc.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/domain/entities/ai_chat_message_entity.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  late ScrollController _scrollController;
  bool _showScrollToBottomButton = false;
  bool _isNearBottom = true;
  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // 初始化后自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrollingProgrammatically) return; // 忽略程序化滚动
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = 100.0; // 距离底部100像素时认为在底部附近
    
    // 检查是否接近底部
    final isNearBottom = (maxScroll - currentScroll) <= threshold;
    
    if (isNearBottom != _isNearBottom) {
      setState(() {
        _isNearBottom = isNearBottom;
        _showScrollToBottomButton = !isNearBottom;
      });
    }

    // 检查是否滚动到顶部，触发加载更多历史消息
    if (currentScroll <= 50 && !_scrollController.position.outOfRange) {
      final state = context.read<AiChatBloc>().state;
      if (state.hasMoreHistory && 
          !state.isLoadingMoreHistory && 
          state.messages.isNotEmpty) {
        print("[ChatMessageList] Triggering LoadMoreHistory");
        context.read<AiChatBloc>().add(const LoadMoreHistory());
      }
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    _isScrollingProgrammatically = true;
    
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ).then((_) {
        _isScrollingProgrammatically = false;
      });
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _isScrollingProgrammatically = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    return BlocListener<AiChatBloc, AiChatState>(
      listenWhen: (previous, current) => 
          previous.shouldScrollToBottom != current.shouldScrollToBottom ||
          (previous.messages.length < current.messages.length && current.messages.isNotEmpty),
      listener: (context, state) {
        // 当有新消息时且用户在底部附近时，自动滚动到底部
        if ((state.shouldScrollToBottom || _isNearBottom) && state.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
      child: Stack(
        children: [
          BlocBuilder<AiChatBloc, AiChatState>(
            builder: (context, state) {
              // --- Handle Loading/Error/Empty States ---
              if (state.status == AiChatStatus.loadingHistory && state.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
              }
               if (state.status == AiChatStatus.historyLoadFailure && state.messages.isEmpty) {
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Icon(Icons.error_outline, color: Colors.red, size: 48),
                           const SizedBox(height: 16),
                           Text(
                             s.ai_docs_recommendations_error(state.errorMessage ?? '未知错误'),
                             style: const TextStyle(color: Colors.red),
                             textAlign: TextAlign.center,
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () {
                               if (state.selectedConversationId != null) {
                                 context.read<AiChatBloc>().add(
                                   SelectConversation(state.selectedConversationId!)
                                 );
                               }
                             },
                             child: const Text('重试'),
                           ),
                         ],
                       ),
                     )
                   );
               }
                // Show empty message only if not loading and not currently streaming
                if (state.messages.isEmpty && 
                    state.status != AiChatStatus.streamingResponse && 
                    state.status != AiChatStatus.loadingHistory) {
                   return Center(
                       child: Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                             const SizedBox(height: 16),
                             Text(
                               s.ai_docs_welcome_title,
                               style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.grey[600],
                               ),
                             ),
                             const SizedBox(height: 8),
                             Text(
                               s.ai_docs_welcome_message,
                               textAlign: TextAlign.center,
                               style: TextStyle(color: Colors.grey[600]),
                             ),
                           ],
                         ),
                       )
                   );
               }

              // --- Build Message List ---
              return ListView.builder(
                controller: _scrollController, 
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                itemCount: _getItemCount(state),
                itemBuilder: (context, index) => _buildItem(context, state, index),
              );
            },
          ),
          
          // 回到底部按钮
          if (_showScrollToBottomButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  _scrollToBottom();
                  context.read<AiChatBloc>().add(const ScrollToBottom());
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
        ],
      ),
    );
  }

  int _getItemCount(AiChatState state) {
    int count = state.messages.length;
    
    // 在顶部添加加载更多指示器
    if (state.isLoadingMoreHistory) {
      count += 1;
    }
    
    // 在底部添加流式响应指示器
    if (state.status == AiChatStatus.streamingResponse) {
      count += 1;
    }
    
    return count;
  }

  Widget _buildItem(BuildContext context, AiChatState state, int index) {
    // 顶部加载更多指示器
    if (state.isLoadingMoreHistory && index == 0) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('加载更多消息...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    // 调整消息索引（如果有加载指示器）
    final messageIndex = state.isLoadingMoreHistory ? index - 1 : index;
    
    // 底部流式响应指示器
    if (state.status == AiChatStatus.streamingResponse && 
        messageIndex == state.messages.length) {
      final streamingPlaceholder = AiChatMessageEntity(
        messageId: 'streaming_placeholder',
        content: state.streamingResponseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        conversationId: state.selectedConversationId ?? -1,
      );
      return ChatMessageBubble(
        key: const ValueKey('streaming_bubble'),
        message: streamingPlaceholder,
        isStreaming: true,
      );
    }

    // 普通消息
    if (messageIndex >= 0 && messageIndex < state.messages.length) {
      final message = state.messages[messageIndex];
      return ChatMessageBubble(
        key: ValueKey(message.messageId),
        message: message,
      );
    }
    
    // 应该不会到达这里，但为了安全返回空容器
    return const SizedBox.shrink();
  }

  // --- Move _buildMessageItem INSIDE the class --- 
  Widget _buildMessageItem(BuildContext context, AiChatMessageEntity message, {bool isStreaming = false}) {
    bool isUser = message.sender == MessageSender.user;
    
    // Determine background color based on sender and streaming state
    Color bubbleColor;
    if (isUser) {
        bubbleColor = Colors.blue[100]!;
    } else if (isStreaming) {
        bubbleColor = Colors.grey[200]!; // Slightly different grey for streaming
    } else {
        bubbleColor = Colors.grey[300]!;
    }

    return Align(
      // Align user messages to the right, AI/System messages to the left
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        constraints: BoxConstraints(
           maxWidth: MediaQuery.of(context).size.width * 0.75 // Max width for bubbles
        ),
        child: Column(
           crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min, // Prevent column taking full width
           children: [
              // --- Display Image Attachment (if any) ---
              if (message.fileUrls?.isNotEmpty ?? false)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 8.0),
                   child: ClipRRect( // Clip image corners
                     borderRadius: BorderRadius.circular(8.0),
                     child: Image.network( 
                        message.fileUrls!.first,
                        height: 150, 
                        fit: BoxFit.cover,
                        // Add loading and error builders for robustness
                        loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                                height: 150,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                   value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                ),
                            );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, color: Colors.red, size: 50),
                        ), 
                     ), 
                   ), 
                 ),
              // --- Display Message Content (with potential cursor for streaming) ---
               Row(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.end, // Align cursor properly
                 children: [
                   Flexible( // Allow text to wrap
                     child: Text(
                        // Show ellipsis if streaming text is empty initially
                        (isStreaming && message.content.isEmpty) ? "..." : message.content,
                        style: const TextStyle(fontSize: 15.0, color: Colors.black87),
                      ),
                   ),
                    // Add blinking cursor only if streaming
                   if (isStreaming)
                      const _BlinkingCursor(), // Use the new stateful widget
                 ],
               ),
              // --- Display Timestamp (Optional) ---
              if (message.timestamp != null && !isStreaming) // Don't show timestamp for streaming msg
               Padding(
                 padding: const EdgeInsets.only(top: 4.0),
                 child: Text(
                  // Basic HH:mm format. Requires intl package for better localization.
                  message.timestamp!.toIso8601String().substring(11, 16), 
                  style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
                 ),
               )
           ],
        ),
      ),
    );
  }
}

// --- Stateful Widget for the Blinking Cursor Animation ---

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Make it blink continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
         '|', 
         style: TextStyle(fontSize: 15.0, color: Colors.black87, fontWeight: FontWeight.bold)
      ),
    );
  }
} 