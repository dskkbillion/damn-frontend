import 'package:flutter/material.dart';
import 'app_colors.dart';

/// DeepStream 文字样式系统
///
/// 字体栈：
/// - 中文标题：HarmonyOS Sans SC（fallback PingFang SC）
/// - 正文/UI：PingFang SC（fallback Inter）
/// - 等宽/价格：JetBrains Mono
class AppTextStyles {
  AppTextStyles._();

  // ==================== 字体家族 ====================
  /// 标题字体（中文优先）
  static const String headingFont = 'HarmonyOS Sans SC';

  /// 正文字体
  static const String bodyFont = 'PingFang SC';

  /// 等宽字体（代码/价格）
  static const String monoFont = 'JetBrains Mono';

  /// 标题 fallback
  static const List<String> _headingFallback = [
    'PingFang SC',
    'Inter',
    'Helvetica Neue',
    'sans-serif',
  ];

  /// 正文 fallback
  static const List<String> _bodyFallback = [
    'Inter',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  /// 等宽 fallback
  static const List<String> _monoFallback = [
    'SF Mono',
    'Menlo',
    'Consolas',
    'monospace',
  ];

  // ==================== 字体大小 ====================
  static const double _fontSize10 = 10.0;
  static const double _fontSize12 = 12.0;
  static const double _fontSize14 = 14.0;
  static const double _fontSize16 = 16.0;
  static const double _fontSize18 = 18.0;
  static const double _fontSize20 = 20.0;
  static const double _fontSize24 = 24.0;
  static const double _fontSize28 = 28.0;

  // ==================== 行高 ====================
  static const double _lineHeight1_2 = 1.2;
  static const double _lineHeight1_4 = 1.4;
  static const double _lineHeight1_5 = 1.5;
  static const double _lineHeight1_6 = 1.6;

  // ==================== Display 样式（标题字体） ====================
  /// 超大标题 - 28px, Bold
  static TextStyle get displayLarge => const TextStyle(
    fontSize: _fontSize28,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_2,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  /// 大标题 - 24px, Bold
  static TextStyle get displayMedium => const TextStyle(
    fontSize: _fontSize24,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_2,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  /// 中等标题 - 20px, Bold
  static TextStyle get displaySmall => const TextStyle(
    fontSize: _fontSize20,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  // ==================== Headline 样式（标题字体） ====================
  /// 大标题 - 20px, SemiBold
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  /// 中等标题 - 18px, SemiBold
  static TextStyle get headlineMedium => const TextStyle(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  /// 小标题 - 16px, SemiBold
  static TextStyle get headlineSmall => const TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: headingFont,
    fontFamilyFallback: _headingFallback,
  );

  // ==================== Title 样式（正文字体） ====================
  /// 大标题 - 18px, Medium
  static TextStyle get titleLarge => const TextStyle(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 中等标题 - 16px, Medium
  static TextStyle get titleMedium => const TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 小标题 - 14px, Medium
  static TextStyle get titleSmall => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  // ==================== Body 样式（正文字体） ====================
  /// 大正文 - 16px, Regular
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_6,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 中等正文 - 14px, Regular
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 小正文 - 12px, Regular
  static TextStyle get bodySmall => const TextStyle(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textSecondary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  // ==================== Label 样式（正文字体） ====================
  /// 大标签 - 14px, Medium
  static TextStyle get labelLarge => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 中等标签 - 12px, Medium
  static TextStyle get labelMedium => const TextStyle(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 小标签 - 10px, Medium
  static TextStyle get labelSmall => const TextStyle(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textSecondary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  // ==================== 价格样式（等宽字体） ====================
  /// 大价格 - 24px, Bold, JetBrains Mono
  static TextStyle get priceLarge => const TextStyle(
    fontSize: _fontSize24,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_2,
    color: AppColors.textPrimary,
    fontFamily: monoFont,
    fontFamilyFallback: _monoFallback,
  );

  /// 中等价格 - 16px, SemiBold, JetBrains Mono
  static TextStyle get priceMedium => const TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: monoFont,
    fontFamilyFallback: _monoFallback,
  );

  /// 小价格 - 12px, Medium, JetBrains Mono
  static TextStyle get priceSmall => const TextStyle(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textSecondary,
    fontFamily: monoFont,
    fontFamilyFallback: _monoFallback,
  );

  // ==================== 特殊样式 ====================
  /// 按钮文字样式
  static TextStyle get button => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.onPrimary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 链接文字样式
  static TextStyle get link => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textLink,
    decoration: TextDecoration.underline,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 强调文字样式
  static TextStyle get emphasis => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_5,
    color: AppColors.primary,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  /// 禁用文字样式
  static TextStyle get disabled => const TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textDisabled,
    fontFamily: bodyFont,
    fontFamilyFallback: _bodyFallback,
  );

  // ==================== 颜色变体方法 ====================
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle asSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }

  static TextStyle asTertiary(TextStyle style) {
    return style.copyWith(color: AppColors.textTertiary);
  }

  static TextStyle asDisabled(TextStyle style) {
    return style.copyWith(color: AppColors.textDisabled);
  }

  static TextStyle asEmphasis(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }
}
