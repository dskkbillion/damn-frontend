import 'package:flutter/material.dart';

/// DeepStream 亮色模式颜色系统（Surface Mode）
///
/// 基于流光蓝（Stream Blue）设计语言。
/// 字段名保持与旧版一致，86 处现有引用自动生效。
class AppColors {
  AppColors._();

  // ==================== 主色调（sky 蓝） ====================
  /// 主色 - 品牌蓝 sky-700
  static const Color primary = Color(0xFF0369A1);

  /// 主色变体 - sky-600
  static const Color primaryVariant = Color(0xFF0284C7);

  /// 主色浅色 - sky-400
  static const Color primaryLight = Color(0xFF38BDF8);

  /// 主色深色 - sky-800
  static const Color primaryDark = Color(0xFF075985);

  // ==================== 功能色（亮色模式） ====================
  /// 错误/危险色 - rose-600
  static const Color error = Color(0xFFE11D48);

  /// 成功色 - emerald-600
  static const Color success = Color(0xFF059669);

  /// 警告色 - amber-500
  static const Color warning = Color(0xFFF59E0B);

  /// 信息色 - sky-500
  static const Color info = Color(0xFF0EA5E9);

  // ==================== 文字颜色（slate 系） ====================
  /// 主要文字颜色 - slate-800
  static const Color textPrimary = Color(0xFF1E293B);

  /// 次要文字颜色 - slate-500
  static const Color textSecondary = Color(0xFF64748B);

  /// 三级文字颜色 - slate-400
  static const Color textTertiary = Color(0xFF94A3B8);

  /// 禁用文字颜色 - slate-300
  static const Color textDisabled = Color(0xFFCBD5E1);

  /// 链接文字颜色
  static const Color textLink = primary;

  // ==================== 背景颜色（stone 系） ====================
  /// 主背景色 - stone-50（暖石灰）
  static const Color backgroundPrimary = Color(0xFFFAFAF9);

  /// 次要背景色 - stone-100
  static const Color backgroundSecondary = Color(0xFFF5F5F4);

  /// 三级背景色 - stone-200
  static const Color backgroundTertiary = Color(0xFFE7E5E4);

  /// 卡片背景色 - 纯白浮于暖石灰底
  static const Color backgroundCard = Color(0xFFFFFFFF);

  /// 悬停背景色 - stone-100
  static const Color backgroundHover = Color(0xFFF5F5F4);

  // ==================== 边框颜色 ====================
  /// 主要边框颜色 - slate-200
  static const Color borderPrimary = Color(0xFFE2E8F0);

  /// 次要边框颜色 - slate-100
  static const Color borderSecondary = Color(0xFFF1F5F9);

  /// 输入框边框颜色 - slate-300
  static const Color borderInput = Color(0xFFCBD5E1);

  /// 输入框焦点边框颜色 - 品牌蓝
  static const Color borderInputFocus = primary;

  // ==================== 分隔线颜色 ====================
  /// 分隔线颜色 - slate-200
  static const Color divider = Color(0xFFE2E8F0);

  // ==================== 覆盖层颜色 ====================
  /// 遮罩层颜色 (50% 透明度)
  static const Color overlay = Color(0x80000000);

  /// 轻覆盖层颜色 (30% 透明度)
  static const Color overlayLight = Color(0x4D000000);

  /// 重覆盖层颜色 (60% 透明度)
  static const Color overlayHeavy = Color(0x99000000);

  /// 禁用覆盖层颜色
  static const Color overlayDisabled = Color(0x61000000);

  // ==================== 灰色系列（slate） ====================
  static const Map<int, Color> grey = {
    50: Color(0xFFF8FAFC),
    100: Color(0xFFF1F5F9),
    200: Color(0xFFE2E8F0),
    300: Color(0xFFCBD5E1),
    400: Color(0xFF94A3B8),
    500: Color(0xFF64748B),
    600: Color(0xFF475569),
    700: Color(0xFF334155),
    800: Color(0xFF1E293B),
    900: Color(0xFF0F172A),
  };

  // ==================== 状态颜色 ====================
  /// 在线状态
  static const Color statusOnline = success;

  /// 离线状态
  static const Color statusOffline = Color(0xFF94A3B8); // slate-400

  /// 忙碌状态
  static const Color statusBusy = warning;

  /// 勿扰状态
  static const Color statusDoNotDisturb = error;

  // ==================== 卖家模块强调色 ====================
  /// 卖家强调色 - 琥珀金
  static const Color sellerAccent = Color(0xFFBF7D2A);

  /// 卖家强调色 - 浅底 (10% 透明度)
  static const Color sellerAccentLight = Color(0x1ABF7D2A);

  // ==================== 聊天模块颜色 ====================
  /// 聊天发送方气泡色
  static const Color chatBubbleSent = Color(0xFFC9E6FF);

  // ==================== 强调色 ====================
  /// 强调色 - 亮 sky-400
  static const Color accentLight = Color(0xFF38BDF8);

  /// 强调色 - 深 sky-800
  static const Color accentDark = Color(0xFF075985);

  /// 强调色 - 光晕（用于 glow 效果）
  static const Color accentGlow = Color(0xFF7DD3FC); // sky-300

  // ==================== 节点色（Agent/状态标识） ====================
  /// 人类节点 - violet-600
  static const Color nodeHuman = Color(0xFF7C3AED);

  /// Agent 节点 - sky-700（品牌蓝）
  static const Color nodeAgent = Color(0xFF0369A1);

  /// 活跃节点 - green-700
  static const Color nodeActive = Color(0xFF15803D);

  /// 空闲节点 - slate-400
  static const Color nodeIdle = Color(0xFF94A3B8);

  // ==================== 常用颜色组合 ====================
  /// 主色上的前景色（const 兼容）
  static const Color onPrimary = Color(0xFFFFFFFF);

  @Deprecated('Use AppColors.onPrimary instead')
  static Color getOnPrimaryColor() => Colors.white;
  static Color getOnErrorColor() => Colors.white;
  static Color getOnSuccessColor() => Colors.white;
  static Color getOnWarningColor() => Colors.white;
  static Color getOnInfoColor() => Colors.white;

  // ==================== 透明度变体 ====================
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color get primaryWithOpacity05 => primary.withValues(alpha: 0.05);
  static Color get primaryWithOpacity10 => primary.withValues(alpha: 0.1);
  static Color get primaryWithOpacity15 => primary.withValues(alpha: 0.15);
  static Color get primaryWithOpacity20 => primary.withValues(alpha: 0.2);
  static Color get primaryWithOpacity50 => primary.withValues(alpha: 0.5);

  /// 卡片专用背景色变体
  static Color get backgroundCardTinted => primaryWithOpacity05;

  // ==================== 渐变 ====================
  /// 品牌流光渐变（水平）
  static const LinearGradient gradientStream = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// 光晕渐变（径向）
  static const RadialGradient gradientGlow = RadialGradient(
    colors: [Color(0x407DD3FC), Color(0x007DD3FC)],
    radius: 0.8,
  );

  /// 氛围渐变（垂直，用于页面背景）
  static const LinearGradient gradientAtmosphere = LinearGradient(
    colors: [Color(0xFFFAFAF9), Color(0xFFF0F9FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// DeepStream 暗色模式颜色系统（Deep Mode）
///
/// 深海背景 + 流光蓝强调 + 发光边框。
class AppColorsDark {
  AppColorsDark._();

  // ==================== 主色调 ====================
  /// 品牌蓝 - 暗色模式主色
  static const Color accentPrimary = Color(0xFF58A6FF);

  /// 品牌蓝 - 亮变体
  static const Color accentLight = Color(0xFF79C0FF);

  /// 品牌蓝 - 深变体
  static const Color accentDark = Color(0xFF1F6FEB);

  // ==================== 背景（深海层级） ====================
  /// 最深层 - 深海
  static const Color backgroundDeep = Color(0xFF0A0E14);

  /// 主背景
  static const Color backgroundPrimary = Color(0xFF0F1419);

  /// 卡片背景
  static const Color backgroundCard = Color(0xFF151B23);

  /// 浮起层背景
  static const Color backgroundElevated = Color(0xFF1A222C);

  /// 悬停背景
  static const Color backgroundHover = Color(0xFF1F2937);

  // ==================== 文字 ====================
  /// 主要文字
  static const Color textPrimary = Color(0xFFE6EDF3);

  /// 次要文字
  static const Color textSecondary = Color(0xFF8B949E);

  /// 三级文字
  static const Color textTertiary = Color(0xFF484F58);

  /// 禁用文字
  static const Color textDisabled = Color(0xFF30363D);

  // ==================== 边框 ====================
  /// 主要边框
  static const Color borderPrimary = Color(0xFF21262D);

  /// 次要边框
  static const Color borderSecondary = Color(0xFF30363D);

  /// 输入框边框
  static const Color borderInput = Color(0xFF30363D);

  /// 输入框焦点边框
  static const Color borderInputFocus = Color(0xFF58A6FF);

  // ==================== 功能色（暗色模式） ====================
  static const Color error = Color(0xFFF85149);
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color info = Color(0xFF58A6FF);

  // ==================== 卖家模块强调色（暗色） ====================
  /// 卖家强调色 - 暗色模式琥珀金（略亮）
  static const Color sellerAccent = Color(0xFFD4A04A);

  /// 卖家强调色 - 暗色浅底 (10% 透明度)
  static const Color sellerAccentLight = Color(0x1AD4A04A);

  // ==================== 聊天模块颜色（暗色） ====================
  /// 聊天发送方气泡色 - 暗色模式
  static const Color chatBubbleSent = Color(0xFF1A3A5C);

  // ==================== 分隔线 ====================
  static const Color divider = Color(0xFF21262D);

  // ==================== 覆盖层 ====================
  static const Color overlay = Color(0xCC000000);

  /// 轻覆盖层颜色 (30% 透明度)
  static const Color overlayLight = Color(0x4D000000);

  /// 重覆盖层颜色 (60% 透明度)
  static const Color overlayHeavy = Color(0x99000000);

  // ==================== 节点色（暗色） ====================
  static const Color nodeHuman = Color(0xFFA78BFA); // violet-400
  static const Color nodeAgent = Color(0xFF58A6FF);
  static const Color nodeActive = Color(0xFF3FB950);
  static const Color nodeIdle = Color(0xFF484F58);

  // ==================== 渐变 ====================
  /// 深海流光渐变
  static const LinearGradient gradientStream = LinearGradient(
    colors: [Color(0xFF1F6FEB), Color(0xFF58A6FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// 深海光晕
  static const RadialGradient gradientGlow = RadialGradient(
    colors: [Color(0x4058A6FF), Color(0x0058A6FF)],
    radius: 0.8,
  );

  /// 深海氛围
  static const LinearGradient gradientAtmosphere = LinearGradient(
    colors: [Color(0xFF0A0E14), Color(0xFF0F1419)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
