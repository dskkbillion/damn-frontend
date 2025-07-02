import 'package:flutter/material.dart';

/// 应用颜色系统
/// 定义了整个应用中使用的标准颜色
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // ==================== 主色调 ====================
  /// 主色 - 品牌色
  static const Color primary = Color(0xFFB66D0E);
  
  /// 主色变体 - 稍深的品牌色
  static const Color primaryVariant = Color(0xFFBF7D2A);
  
  /// 主色浅色 - 较浅的品牌色
  static const Color primaryLight = Color(0xFFD0903D);
  
  /// 主色深色 - 较深的品牌色
  static const Color primaryDark = Color(0xFF8C430A);

  // ==================== 功能色 ====================
  /// 错误/危险色
  static const Color error = Color(0xFFE53E3E);
  
  /// 成功色
  static const Color success = Color(0xFF38A169);
  
  /// 警告色
  static const Color warning = Color(0xFFDD6B20);
  
  /// 信息色
  static const Color info = Color(0xFF3182CE);

  // ==================== 文字颜色 ====================
  /// 主要文字颜色
  static const Color textPrimary = Color(0xFF212121);
  
  /// 次要文字颜色
  static const Color textSecondary = Color(0xFF666666);
  
  /// 三级文字颜色
  static const Color textTertiary = Color(0xFF999999);
  
  /// 禁用文字颜色
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// 链接文字颜色
  static const Color textLink = primary;

  // ==================== 背景颜色 ====================
  /// 主背景色
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  
  /// 次要背景色
  static const Color backgroundSecondary = Color(0xFFF6F6F6);
  
  /// 三级背景色
  static const Color backgroundTertiary = Color(0xFFEDEDED);
  
  /// 卡片背景色 - 很淡的主题色
  static const Color backgroundCard = Color(0xFFFDF9F5);

  // ==================== 边框颜色 ====================
  /// 主要边框颜色
  static const Color borderPrimary = Color(0xFFE0E0E0);
  
  /// 次要边框颜色
  static const Color borderSecondary = Color(0xFFF0F0F0);
  
  /// 输入框边框颜色
  static const Color borderInput = Color(0xFFE0E0E0);
  
  /// 输入框焦点边框颜色
  static const Color borderInputFocus = primary;

  // ==================== 分隔线颜色 ====================
  /// 分隔线颜色
  static const Color divider = Color(0xFFE0E0E0);

  // ==================== 覆盖层颜色 ====================
  /// 遮罩层颜色
  static const Color overlay = Color(0x80000000);
  
  /// 禁用覆盖层颜色
  static const Color overlayDisabled = Color(0x61000000);

  // ==================== 灰色系列 ====================
  static const Map<int, Color> grey = {
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    900: Color(0xFF212121),
  };

  // ==================== 状态颜色 ====================
  /// 在线状态
  static const Color statusOnline = success;
  
  /// 离线状态
  static const Color statusOffline = Color(0xFF9E9E9E); // grey[500]
  
  /// 忙碌状态
  static const Color statusBusy = warning;
  
  /// 勿扰状态
  static const Color statusDoNotDisturb = error;

  // ==================== 常用颜色组合 ====================
  /// 获取对应主色的文字颜色
  static Color getOnPrimaryColor() => Colors.white;
  
  /// 获取对应错误色的文字颜色
  static Color getOnErrorColor() => Colors.white;
  
  /// 获取对应成功色的文字颜色
  static Color getOnSuccessColor() => Colors.white;
  
  /// 获取对应警告色的文字颜色
  static Color getOnWarningColor() => Colors.white;
  
  /// 获取对应信息色的文字颜色
  static Color getOnInfoColor() => Colors.white;

  // ==================== 透明度变体 ====================
  /// 获取指定颜色的透明度变体
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// 主色透明度变体
  static Color get primaryWithOpacity05 => primary.withOpacity(0.05);
  static Color get primaryWithOpacity10 => primary.withOpacity(0.1);
  static Color get primaryWithOpacity15 => primary.withOpacity(0.15);
  static Color get primaryWithOpacity20 => primary.withOpacity(0.2);
  static Color get primaryWithOpacity50 => primary.withOpacity(0.5);
  
  /// 卡片专用背景色变体 - 极淡主题色
  static Color get backgroundCardTinted => primaryWithOpacity05;
} 



 
 