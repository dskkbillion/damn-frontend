import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // 添加日期格式化导入
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../utils/markdown_style_helper.dart';
import '../../domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

class AllocateMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final String sellerName; // 发送方或接收方的名称，由chat_message_bubble提供
  final bool isCurrentUserMessage; // 是否是当前用户发送的消息
  
  const AllocateMessageBubble({
    Key? key, 
    required this.message,
    required this.sellerName,
    required this.isCurrentUserMessage,
  }) : super(key: key);

  @override
  State<AllocateMessageBubble> createState() => _AllocateMessageBubbleState();
}

class _AllocateMessageBubbleState extends State<AllocateMessageBubble> {
  bool _isExpanded = false;
  static const int maxCharCount = 100;
  
  bool get _needsTruncation => widget.message.context.length > maxCharCount;
  
  // 根据当前用户是发送者还是接收者生成不同的标题文本
  String get _titleText {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    if (widget.isCurrentUserMessage) {
      // 当前用户是发送者（买家）
      return appLocalizations.chat_i_want_seller_to_see;
    } else {
      // 当前用户是接收者（卖家）
      return "${widget.sellerName}${appLocalizations.chat_wants_to_see}";
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 警告图标和标题行
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA500), // 黄色圆形
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.warning_amber_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _titleText, // 使用动态生成的标题
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 在标题行右侧添加时间
                if (widget.message.createTime != null)
                  Text(
                    DateFormat('HH:mm').format(widget.message.createTime!),
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12.0,
                    ),
                  ),
              ],
            ),
          ),
          
          // 消息内容
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 根据展开状态显示普通文本或Markdown
                if (_needsTruncation && !_isExpanded) 
                  // 未展开状态显示截断的普通文本
                  Text(
                    "${widget.message.context.substring(0, maxCharCount)}...",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  )
                else
                  // 展开状态或短消息使用Markdown渲染
                  MarkdownBody(
                    data: widget.message.context,
                    selectable: true,
                    styleSheet: MarkdownStyleHelper.buildChatBubbleStyle(
                      context, 
                      const Color(0xFF212121), // 黑色文本
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                      }
                    },
                    shrinkWrap: true,
                  ),
                
                // 展开/收起按钮
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
                        _isExpanded ? appLocalizations.chat_collapse : appLocalizations.chat_expand,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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