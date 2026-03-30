import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// Enhanced Chat widget that adds missing features
class EnhancedChat extends StatefulWidget {
  final List<types.Message> messages;
  final void Function(types.PartialText) onSendPressed;
  final void Function()? onAttachmentPressed;
  final void Function(BuildContext, types.Message)? onMessageTap;
  final void Function(BuildContext, types.Message)? onMessageLongPress;
  final Future<void> Function()? onEndReached;
  final types.User user;
  final DefaultChatTheme theme;
  final Widget Function(types.CustomMessage, {required int messageWidth})? customMessageBuilder;
  final bool showUserAvatars;
  final bool showUserNames;
  final Widget Function(String userId)? avatarBuilder;
  final InputOptions inputOptions;
  final Widget? customBottomWidget;
  final ScrollPhysics? scrollPhysics;
  final DateFormat? dateFormat;
  final DateFormat? timeFormat;
  final bool usePreviewData;
  final bool hideBackgroundOnEmojiMessages;
  final EmojiEnlargementBehavior emojiEnlargementBehavior;
  final bool? isLastPage;
  final double? onEndReachedThreshold;

  const EnhancedChat({
    super.key,
    required this.messages,
    required this.onSendPressed,
    this.onAttachmentPressed,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onEndReached,
    required this.user,
    required this.theme,
    this.customMessageBuilder,
    this.showUserAvatars = true,
    this.showUserNames = false,
    this.avatarBuilder,
    this.inputOptions = const InputOptions(),
    this.customBottomWidget,
    this.scrollPhysics,
    this.dateFormat,
    this.timeFormat,
    this.usePreviewData = true,
    this.hideBackgroundOnEmojiMessages = false,
    this.emojiEnlargementBehavior = EmojiEnlargementBehavior.multi,
    this.isLastPage,
    this.onEndReachedThreshold,
  });

  @override
  State<EnhancedChat> createState() => _EnhancedChatState();
}

class _EnhancedChatState extends State<EnhancedChat> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final currentScroll = _scrollController.offset;
      
      // Update scroll to bottom button visibility
      // In reversed list, bottom is at 0
      setState(() {
        _showScrollToBottomButton = currentScroll > 300;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // In reversed list, bottom is at 0
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) {
    if (widget.onMessageLongPress != null) {
      widget.onMessageLongPress!(context, message);
      return;
    }

    // Default long press behavior
    final isCurrentUser = message.author.id == widget.user.id;
    _showMessagePopupMenu(context, message, isCurrentUser);
  }

  void _showMessagePopupMenu(BuildContext context, types.Message message, bool isCurrentUser) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final position = renderBox.localToGlobal(Offset.zero);
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final List<PopupMenuEntry<String>> menuItems = [];

    // Text messages support copy
    if (message is types.TextMessage) {
      menuItems.add(
        const PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 20),
              SizedBox(width: 8),
              Text('复制'),
            ],
          ),
        ),
      );
    }

    // Current user messages support revoke (within 2 minutes)
    if (isCurrentUser && _canWithdrawMessage(message)) {
      menuItems.add(
        const PopupMenuItem<String>(
          value: 'revoke',
          child: Row(
            children: [
              Icon(Icons.undo, size: 20),
              SizedBox(width: 8),
              Text('撤回'),
            ],
          ),
        ),
      );
    }

    if (menuItems.isEmpty) return;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: menuItems,
      elevation: 8.0,
    ).then<void>((String? selectedValue) {
      if (selectedValue == null) return;

      switch (selectedValue) {
        case 'copy':
          if (message is types.TextMessage) {
            Clipboard.setData(ClipboardData(text: message.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制到剪贴板')),
            );
          }
          break;
        case 'revoke':
          // Handle revoke through parent callback
          break;
      }
    });
  }

  bool _canWithdrawMessage(types.Message message) {
    // Can withdraw within 2 minutes
    final createTime = DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0);
    return DateTime.now().difference(createTime).inMinutes < 2;
  }


  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildStatusIndicator(types.Message message) {
    final status = message.metadata?['status'] as String?;
    
    IconData iconData;
    Color iconColor = Colors.grey;
    double iconSize = 14.0;

    switch (status) {
      case 'sending':
        iconData = Icons.schedule;
        break;
      case 'sent':
        iconData = Icons.done;
        break;
      case 'failed':
        iconData = Icons.error_outline;
        iconColor = AppColors.error;
        break;
      case 'read':
        iconData = Icons.done_all;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.done;
    }

    return Icon(iconData, size: iconSize, color: iconColor);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original Chat widget
        Chat(
          messages: widget.messages,
          onSendPressed: widget.onSendPressed,
          onAttachmentPressed: widget.onAttachmentPressed,
          onMessageTap: widget.onMessageTap,
          onEndReached: widget.onEndReached,
          user: widget.user,
          theme: widget.theme,
          customMessageBuilder: widget.customMessageBuilder,
          showUserAvatars: widget.showUserAvatars,
          showUserNames: widget.showUserNames,
          avatarBuilder: widget.avatarBuilder != null
              ? (user) => widget.avatarBuilder!(user.id)
              : null,
          inputOptions: widget.inputOptions,
          customBottomWidget: widget.customBottomWidget,
          scrollPhysics: widget.scrollPhysics,
          dateFormat: widget.dateFormat,
          timeFormat: widget.timeFormat,
          usePreviewData: widget.usePreviewData,
          hideBackgroundOnEmojiMessages: widget.hideBackgroundOnEmojiMessages,
          emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
          isLastPage: widget.isLastPage,
          onEndReachedThreshold: widget.onEndReachedThreshold,
          // Note: We can't easily wrap individual messages without modifying flutter_chat_ui
          // So time and status will need to be handled differently
        ),
        
        // Scroll to bottom FAB
        if (_showScrollToBottomButton)
          Positioned(
            right: 16.0,
            bottom: 80.0,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4.0,
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}