import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart';
import '../utils/markdown_style_helper.dart';

/// Custom bubble widget for allocate message type - matching original warning style
class CustomAllocateBubble extends StatefulWidget {
  final types.CustomMessage message;
  final Map<String, dynamic> allocateData;
  final bool isCurrentUser;
  final VoidCallback? onProductTap;

  const CustomAllocateBubble({
    super.key,
    required this.message,
    required this.allocateData,
    required this.isCurrentUser,
    this.onProductTap,
  });

  @override
  State<CustomAllocateBubble> createState() => _CustomAllocateBubbleState();
}

class _CustomAllocateBubbleState extends State<CustomAllocateBubble> {
  bool _isExpanded = false;
  static const int maxCharCount = 100;
  
  String get _messageContent {
    // Get original context from metadata
    return widget.message.metadata?['originalContext'] ?? 
           widget.allocateData['message'] ?? 
           '分配消息';
  }
  
  bool get _needsTruncation => _messageContent.length > maxCharCount;
  
  // Generate title text based on sender/receiver
  String get _titleText {
    final S s = S.of(context);
    final sellerName = widget.allocateData['sellerName'] ?? '卖家';
    
    if (widget.isCurrentUser) {
      // Current user is sender (buyer)
      return s.chat_i_want_seller_to_see;
    } else {
      // Current user is receiver (seller)
      return "${sellerName}${s.chat_wants_to_see}";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6), // Light gray background matching original
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning icon and title row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA500), // Yellow circle matching original
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _titleText, // Dynamic title
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Time in title row
                if (widget.message.createdAt != null)
                  Text(
                    DateFormat('HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(widget.message.createdAt!),
                    ),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12.0,
                    ),
                  ),
              ],
            ),
          ),
          
          // Message content
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show truncated text or full Markdown based on expansion state
                if (_needsTruncation && !_isExpanded) 
                  // Unexpanded state - show truncated plain text
                  Text(
                    "${_messageContent.substring(0, maxCharCount)}...",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  )
                else
                  // Expanded state or short message - use Markdown rendering
                  MarkdownBody(
                    data: _messageContent,
                    selectable: true,
                    styleSheet: MarkdownStyleHelper.buildChatBubbleStyle(
                      context, 
                      const Color(0xFF212121), // Black text
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                      }
                    },
                    shrinkWrap: true,
                  ),
                
                // Expand/Collapse button
                if (_needsTruncation) 
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isExpanded ? s.chat_collapse : s.chat_expand,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Optional: Add product link if available
                if (widget.allocateData['productId'] != null)
                  GestureDetector(
                    onTap: widget.onProductTap,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '查看相关商品',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}