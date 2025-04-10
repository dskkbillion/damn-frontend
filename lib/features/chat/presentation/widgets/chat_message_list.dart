import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import 'chat_message_item.dart';
import 'loading_indicator.dart';

/// 聊天消息列表组件
class ChatMessageList extends StatefulWidget {
  /// 消息列表
  final List<Message> messages;
  
  /// 滚动控制器
  final ScrollController scrollController;
  
  /// 是否正在加载更多
  final bool isLoadingMore;
  
  /// 消息长按回调
  final void Function(Message) onMessageLongPress;
  
  /// 需要高亮显示的消息ID
  final String? highlightMessageId;

  const ChatMessageList({
    Key? key,
    required this.messages,
    required this.scrollController,
    this.isLoadingMore = false,
    required this.onMessageLongPress,
    this.highlightMessageId,
  }) : super(key: key);

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final GlobalKey _highlightedMessageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // 消息列表加载完成后，如果需要高亮显示特定消息，滚动到该消息
    if (widget.highlightMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToHighlightedMessage();
      });
    }
  }

  void _scrollToHighlightedMessage() {
    if (_highlightedMessageKey.currentContext != null) {
      Scrollable.ensureVisible(
        _highlightedMessageKey.currentContext!,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 按时间排序消息 (从旧到新)
    final sortedMessages = List<Message>.from(widget.messages);
    sortedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return Column(
      children: [
        // 加载更多指示器
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LoadingIndicator(size: 24.0),
          ),
        
        // 消息列表
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            reverse: true, // 默认显示最新消息 (底部)
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: sortedMessages.length,
            itemBuilder: (context, index) {
              final message = sortedMessages[sortedMessages.length - 1 - index]; // 倒序显示
              final isHighlighted = message.id == widget.highlightMessageId;
              
              return Container(
                key: isHighlighted ? _highlightedMessageKey : null,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: isHighlighted
                    ? BoxDecoration(
                        color: Colors.yellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.0),
                      )
                    : null,
                child: GestureDetector(
                  onLongPress: () => widget.onMessageLongPress(message),
                  child: ChatMessageItem(
                    message: message,
                    showTimeLabel: _shouldShowTimeLabel(index, sortedMessages),
                    showSenderAvatar: message.senderType == MessageSenderType.USER,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 判断是否应显示时间标签
  bool _shouldShowTimeLabel(int index, List<Message> messages) {
    // 首条消息显示时间
    if (index == messages.length - 1) {
      return true;
    }
    
    final currentMessage = messages[messages.length - 1 - index];
    final previousMessage = messages[messages.length - index];
    
    // 如果两条消息间隔超过5分钟，则显示时间标签
    return currentMessage.timestamp.difference(previousMessage.timestamp).inMinutes.abs() > 5;
  }
} 