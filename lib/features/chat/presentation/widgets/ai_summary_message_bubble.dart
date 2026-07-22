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

  List<_SummarySection> _parseSections(String text) {
    final sections = <_SummarySection>[];
    String? heading;
    final rows = <_SummaryRow>[];

    void flush() {
      if (heading == null && rows.isEmpty) return;
      sections.add(_SummarySection(
        title: heading,
        rows: List<_SummaryRow>.from(rows),
      ));
      heading = null;
      rows.clear();
    }

    for (final rawLine in text.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final divider = line.indexOf(RegExp(r'[:：]'));
      final isHeading = divider == line.length - 1 && divider > 0;
      if (isHeading) {
        flush();
        heading = line.substring(0, divider).trim();
        continue;
      }

      if (divider > 0 && divider < line.length - 1) {
        rows.add(_SummaryRow(
          label: line.substring(0, divider).trim(),
          value: line.substring(divider + 1).trim(),
        ));
      } else {
        rows.add(_SummaryRow(value: line));
      }
    }
    flush();
    return sections;
  }

  String _previewText(String safeText, List<_SummarySection> sections) {
    const preferredLabels = ['服务内容', '需求', '目标', '服务期望', '服务建议'];
    for (final label in preferredLabels) {
      for (final section in sections) {
        for (final row in section.rows) {
          if (row.label?.contains(label) == true && row.value.isNotEmpty) {
            return row.value;
          }
        }
      }
    }
    for (final section in sections) {
      for (final row in section.rows) {
        if (row.value.isNotEmpty) return row.value;
      }
    }
    return safeText;
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
    final sections =
        _isLeakedSample ? const <_SummarySection>[] : _parseSections(safeText);
    final canExpand = !_isLeakedSample &&
        (sections.length > 1 ||
            sections.expand((section) => section.rows).length > 2);
    final preview = _previewText(safeText, sections);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientStream,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 19, color: AppColors.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleText,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('HH:mm').format(widget.message.createTime),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canExpand)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: _isExpanded
                        ? appLocalizations.chat_collapse
                        : appLocalizations.chat_expand,
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    icon: AnimatedRotation(
                      turns: _isExpanded ? .5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: _isExpanded
                      ? KeyedSubtree(
                          key: const ValueKey('expanded-summary'),
                          child: _buildExpandedContent(sections, safeText),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('collapsed-summary'),
                          child: _buildPreview(preview),
                        ),
                ),
                if (canExpand) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded
                                ? appLocalizations.chat_collapse
                                : appLocalizations.chat_expand,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(String preview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Text(
        preview,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          height: 1.55,
          color:
              _isLeakedSample ? AppColors.textTertiary : AppColors.textPrimary,
          fontStyle: _isLeakedSample ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
      List<_SummarySection> sections, String fallback) {
    if (sections.isEmpty) return _buildPreview(fallback);
    return Column(
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          _SummarySectionCard(section: sections[index]),
          if (index != sections.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SummarySection {
  final String? title;
  final List<_SummaryRow> rows;

  const _SummarySection({required this.title, required this.rows});
}

class _SummaryRow {
  final String? label;
  final String value;

  const _SummaryRow({this.label, required this.value});
}

class _SummarySectionCard extends StatelessWidget {
  final _SummarySection section;

  const _SummarySectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title?.isNotEmpty == true) ...[
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
          ],
          for (var index = 0; index < section.rows.length; index++) ...[
            _SummaryRowView(row: section.rows[index]),
            if (index != section.rows.length - 1) const SizedBox(height: 7),
          ],
        ],
      ),
    );
  }
}

class _SummaryRowView extends StatelessWidget {
  final _SummaryRow row;

  const _SummaryRowView({required this.row});

  @override
  Widget build(BuildContext context) {
    if (row.label == null) {
      return Text(
        row.value,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${row.label}  ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          TextSpan(
            text: row.value,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
