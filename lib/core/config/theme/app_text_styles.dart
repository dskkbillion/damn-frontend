import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用文字样式系统
/// 定义了整个应用中使用的标准文字样式
class AppTextStyles {
  // 私有构造函数，防止实例化
  AppTextStyles._();

  // ==================== 基础字体配置 ====================
  /// 默认字体家族
  static const String _defaultFontFamily = 'PingFang SC';
  
  /// 备用字体家族
  static const List<String> _fallbackFontFamilies = [
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  // ==================== 字体大小常量 ====================
  static const double _fontSize10 = 10.0;
  static const double _fontSize12 = 12.0;
  static const double _fontSize14 = 14.0;
  static const double _fontSize16 = 16.0;
  static const double _fontSize18 = 18.0;
  static const double _fontSize20 = 20.0;
  static const double _fontSize24 = 24.0;
  static const double _fontSize28 = 28.0;
  static const double _fontSize32 = 32.0;

  // ==================== 行高常量 ====================
  static const double _lineHeight1_2 = 1.2;
  static const double _lineHeight1_4 = 1.4;
  static const double _lineHeight1_5 = 1.5;
  static const double _lineHeight1_6 = 1.6;

  // ==================== 标题样式 ====================
  /// 超大标题 - 32px, Bold
  static TextStyle get displayLarge => TextStyle(
    fontSize: _fontSize32,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_2,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 大标题 - 28px, Bold
  static TextStyle get displayMedium => TextStyle(
    fontSize: _fontSize28,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_2,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 中等标题 - 24px, Bold
  static TextStyle get displaySmall => TextStyle(
    fontSize: _fontSize24,
    fontWeight: FontWeight.bold,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 标题样式 (Headline) ====================
  /// 大标题 - 20px, SemiBold
  static TextStyle get headlineLarge => TextStyle(
    fontSize: _fontSize20,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 中等标题 - 18px, SemiBold
  static TextStyle get headlineMedium => TextStyle(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 小标题 - 16px, SemiBold
  static TextStyle get headlineSmall => TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 标题样式 (Title) ====================
  /// 大标题 - 18px, Medium
  static TextStyle get titleLarge => TextStyle(
    fontSize: _fontSize18,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 中等标题 - 16px, Medium
  static TextStyle get titleMedium => TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 小标题 - 14px, Medium
  static TextStyle get titleSmall => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 正文样式 (Body) ====================
  /// 大正文 - 16px, Regular
  static TextStyle get bodyLarge => TextStyle(
    fontSize: _fontSize16,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 中等正文 - 14px, Regular
  static TextStyle get bodyMedium => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 小正文 - 12px, Regular
  static TextStyle get bodySmall => TextStyle(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textSecondary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 标签样式 (Label) ====================
  /// 大标签 - 14px, Medium
  static TextStyle get labelLarge => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 中等标签 - 12px, Medium
  static TextStyle get labelMedium => TextStyle(
    fontSize: _fontSize12,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textPrimary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 小标签 - 10px, Medium
  static TextStyle get labelSmall => TextStyle(
    fontSize: _fontSize10,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.textSecondary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 特殊样式 ====================
  /// 按钮文字样式
  static TextStyle get button => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w500,
    height: _lineHeight1_4,
    color: AppColors.getOnPrimaryColor(),
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 链接文字样式
  static TextStyle get link => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textLink,
    decoration: TextDecoration.underline,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 强调文字样式
  static TextStyle get emphasis => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w600,
    height: _lineHeight1_5,
    color: AppColors.primary,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  /// 禁用文字样式
  static TextStyle get disabled => TextStyle(
    fontSize: _fontSize14,
    fontWeight: FontWeight.w400,
    height: _lineHeight1_5,
    color: AppColors.textDisabled,
    fontFamily: _defaultFontFamily,
    fontFamilyFallback: _fallbackFontFamilies,
  );

  // ==================== 颜色变体方法 ====================
  /// 获取指定颜色的文字样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 获取次要颜色的文字样式
  static TextStyle asSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }

  /// 获取三级颜色的文字样式
  static TextStyle asTertiary(TextStyle style) {
    return style.copyWith(color: AppColors.textTertiary);
  }

  /// 获取禁用颜色的文字样式
  static TextStyle asDisabled(TextStyle style) {
    return style.copyWith(color: AppColors.textDisabled);
  }

  /// 获取强调颜色的文字样式
  static TextStyle asEmphasis(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }
} 
 
 
 