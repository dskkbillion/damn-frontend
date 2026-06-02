import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日期格式化
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../../domain/entities/chat_message.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 国际化资源
import 'chat_message_bubble.dart'; // 复用 isAiSummaryMessage 前缀表（唯一事实来源）

/// AI 需求摘要气泡（替代旧的 AllocateMessageBubble），修复 #377：
/// 杜绝 AI 内部 prompt 结构（如 `**Service Conversation Summary**` 标题）
/// 被当作 Markdown 渲染成加粗标题泄漏进聊天 UI。
///
/// 渲染策略（绝不使用 MarkdownBody）：
///  1. 命中已知泄漏前缀（复用 [ChatMessageBubble.isAiSummaryMessage] 的前缀表）
///     → 判定为内部结构泄漏样本，不渲染原文，显示中性占位文案。
///  2. 未命中（正常 summary）→ 先 **无条件** strip 掉 `**` / 行首 `#` 等
///     markdown 强调与标题标记（保留换行），再用纯 [Text] 展示。
///     无条件 strip 是兜底：即便前缀检测漏判，渲染态也保证不含 `**...**`。
class AiSummaryMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final String sellerName; // 发送方或接收方的名称，由 chat_message_bubble 提供
  final bool isCurrentUserMessage; // 是否是当前用户发送的消息

  const AiSummaryMessageBubble({
    super.key,
    required this.message,
    required this.sellerName,
    required this.isCurrentUserMessage,
  });

  /// 确定性去除 markdown 强调/标题标记，保留换行与正文。
  /// 处理：`**bold**`、`__bold__`、`*italic*`、`_italic_`、行首 `#` 标题序列、
  /// 行首列表符号 `- ` / `* ` / `+ `。不依赖任何渲染库，纯字符串变换。
  ///
  /// 关键：调用方对所有未命中泄漏前缀的样本**无条件**调用本方法，
  /// 保证渲染态绝不出现 `**...**` 等原始标记。
  static String stripMarkdownMarkers(String input) {
    var out = input;
    // 去掉成对的强调标记 **...** / __...__ / *...* / _..._（保留中间文本）
    out = out.replaceAll('**', '');
    out = out.replaceAll('__', '');
    // 单字符强调标记（避免误伤普通星号/下划线时仅去成对包裹的）
    out = out.replaceAll(RegExp(r'(?<!\*)\*(?!\*)'), '');
    out = out.replaceAll(RegExp(r'(?<![\w])_(?![\w])'), '');
    // 行首 markdown 标题 `#`、`##` … 与行首列表符号 `- ` `* ` `+ `
    out = out.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '');
    out = out.replaceAll(RegExp(r'^\s{0,3}[-*+]\s+', multiLine: true), '');
    // 行内反引号代码标记
    out = out.replaceAll('`', '');
    return out.trim();
  }

  @override
  State<AiSummaryMessageBubble> createState() => _AiSummaryMessageBubbleState();
}

class _AiSummaryMessageBubbleState extends State<AiSummaryMessageBubble> {
  bool _isExpanded = false;
  static const int maxCharCount = 100;

  /// 是否为内部结构泄漏样本（命中已知泄漏前缀）。
  bool get _isLeakedSample =>
      ChatMessageBubble.isAiSummaryMessage(widget.message.context);

  /// 实际用于展示的安全文本：
  ///  - 泄漏样本 → 中性占位文案；
  ///  - 正常样本 → 无条件 strip 后的正文。
  String _displayText(AppLocalizations s) {
    if (_isLeakedSample) {
      return s.chat_summary_hidden;
    }
    return AiSummaryMessageBubble.stripMarkdownMarkers(widget.message.context);
  }

  // 根据当前用户是发送者还是接收者生成不同的标题文本。
  String get _titleText {
    final appLocalizations = AppLocalizations.of(context);
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
    final appLocalizations = AppLocalizations.of(context);
    final safeText = _displayText(appLocalizations);
    // 泄漏占位文案较短，不参与截断/展开；正常文本按长度判断。
    final bool needsTruncation =
        !_isLeakedSample && safeText.length > maxCharCount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标和标题行
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.warning, // 黄色圆形
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.warning_amber_rounded,
                        color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _titleText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 标题行右侧时间
                Text(
                  DateFormat('HH:mm').format(widget.message.createTime),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),

          // 消息内容（安全渲染：纯 Text，绝不使用 MarkdownBody）
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  needsTruncation && !_isExpanded
                      ? "${safeText.substring(0, maxCharCount)}..."
                      : safeText,
                  style: TextStyle(
                    fontSize: 16,
                    // 泄漏占位文案用次要色弱化，正常正文用主文本色。
                    color: _isLeakedSample
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    fontStyle:
                        _isLeakedSample ? FontStyle.italic : FontStyle.normal,
                  ),
                ),

                // 展开/收起按钮（仅正常长文本）
                if (needsTruncation)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isExpanded
                            ? appLocalizations.chat_collapse
                            : appLocalizations.chat_expand,
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
