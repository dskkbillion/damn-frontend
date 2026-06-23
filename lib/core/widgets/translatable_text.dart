import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

/// 支持原文/译文 toggle 的通用文本组件。
///
/// - 有翻译（translatedText 非空且与 originalText 不同）→ 默认显示译文，底部显示 toggle 行
/// - 无翻译或同语言 → 直接显示原文，无任何额外 UI
class TranslatableText extends StatefulWidget {
  final String originalText;
  final String? translatedText;
  final String? sourceLang;
  final String? provider;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableText({
    super.key,
    required this.originalText,
    this.translatedText,
    this.sourceLang,
    this.provider,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  bool _showOriginal = false;

  bool get _hasTranslation =>
      widget.translatedText != null &&
      widget.translatedText!.isNotEmpty &&
      widget.translatedText != widget.originalText;

  String get _displayText =>
      (_hasTranslation && !_showOriginal) ? widget.translatedText! : widget.originalText;

  String _sourceLangLabel(BuildContext context) {
    const langNames = {
      'zh': '中文',
      'en': 'English',
      'ja': '日本語',
      'ko': '한국어',
      'vi': 'Tiếng Việt',
    };
    final lang = widget.sourceLang?.toLowerCase() ?? '';
    return langNames[lang] ?? lang.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _displayText,
          style: widget.style,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
        ),
        if (_hasTranslation) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _showOriginal = !_showOriginal),
            child: Text(
              _showOriginal
                  ? '显示译文'
                  : '翻自 ${_sourceLangLabel(context)} · 查看原文',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
