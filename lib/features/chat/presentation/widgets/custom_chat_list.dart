import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_message.dart' as domain;
import 'package:dskk_flutter_refactor/features/chat/domain/entities/participant.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/widgets/chat_message_bubble.dart';

/// Custom chat list widget that renders messages using the original ChatMessageBubble
class CustomChatList extends StatefulWidget {
  final List<domain.ChatMessage> messages;
  final int currentUserParticipantId;
  final Participant? opponent;
  final ScrollController? scrollController;
  final Function()? onEndReached;
  final bool isLoadingMore;
  
  const CustomChatList({
    super.key,
    required this.messages,
    required this.currentUserParticipantId,
    required this.opponent,
    this.scrollController,
    this.onEndReached,
    this.isLoadingMore = false,
  });

  @override
  State<CustomChatList> createState() => _CustomChatListState();
}

class _CustomChatListState extends State<CustomChatList> {
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Trigger load more when scrolled to top (in reverse mode)
      if (currentScroll >= maxScroll - 200 && widget.onEndReached != null && !widget.isLoadingMore) {
        widget.onEndReached!();
      }
    }
  }
  
  bool _shouldShowTimestampSeparator(domain.ChatMessage currentMessage, domain.ChatMessage? previousMessage) {
    if (previousMessage == null) return true;
    if (currentMessage.createTime == null || previousMessage.createTime == null) return false;
    
    final currentTime = currentMessage.createTime!;
    final previousTime = previousMessage.createTime!;
    
    // Show timestamp if messages are more than 5 minutes apart
    return currentTime.difference(previousTime).inMinutes.abs() > 5;
  }
  
  Widget _buildTimestampSeparator(DateTime timestamp, bool isFirstInList) {
    final now = DateTime.now();
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    
    
    String dateString;
    if (messageDate == todayDate) {
      dateString = '今天';
    } else if (messageDate == yesterdayDate) {
      dateString = '昨天';
    } else if (now.difference(messageDate).inDays < 7) {
      dateString = DateFormat.EEEE('zh_CN').format(timestamp);
    } else {
      dateString = DateFormat('MM月dd日').format(timestamp);
    }
    
    final timeString = DateFormat('HH:mm').format(timestamp);
    final displayString = isFirstInList ? dateString : '$dateString $timeString';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: AppColors.borderPrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Text(
            displayString,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Text(
          '暂无消息',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Newest messages at bottom
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      cacheExtent: 1000, // Increased cache extent for better scrolling performance
      addAutomaticKeepAlives: false, // Reduce memory usage
      addRepaintBoundaries: true, // Optimize repainting
      itemCount: widget.messages.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at top (when reverse mode)
        if (index == widget.messages.length && widget.isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        
        // Ensure index is in valid range
        if (index >= widget.messages.length) {
          return Container();
        }
        
        // In reverse mode with messages sorted newest first:
        // - index 0 is at the bottom (newest message)
        // - Messages list is already sorted newest first (index 0 = newest)
        // So we can use index directly
        final currentMessage = widget.messages[index];
        final previousMessage = (index < widget.messages.length - 1) 
            ? widget.messages[index + 1]
            : null;
        
        final bool isFirstInList = index == 0;
        
        if (currentMessage.createTime == null) {
          return RepaintBoundary(
            child: ChatMessageBubble(
              key: ValueKey(currentMessage.id),
              message: currentMessage,
              currentUserParticipantId: widget.currentUserParticipantId,
              opponent: widget.opponent,
            ),
          );
        }
        
        final bool showTimestamp = _shouldShowTimestampSeparator(currentMessage, previousMessage);
        
        return RepaintBoundary(
          child: Column(
            children: [
              if (showTimestamp)
                _buildTimestampSeparator(currentMessage.createTime!, isFirstInList),
              
              ChatMessageBubble(
                key: ValueKey(currentMessage.id),
                message: currentMessage,
                currentUserParticipantId: widget.currentUserParticipantId,
                opponent: widget.opponent,
              ),
            ],
          ),
        );
      },
    );
  }
}