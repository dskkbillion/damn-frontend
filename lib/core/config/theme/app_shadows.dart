import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// 应用阴影系统
/// 定义了整个应用中使用的标准阴影效果
class AppShadows {
  // 私有构造函数，防止实例化
  AppShadows._();

  // ==================== 基础阴影颜色（亮色模式 - slate 系） ====================
  /// 阴影基础颜色 - rgba(30,41,59, 0.08)
  static const Color _shadowColor = Color(0x141E293B);

  /// 深色阴影颜色 - rgba(30,41,59, 0.10)
  static const Color _shadowColorDark = Color(0x1A1E293B);

  /// 浅色阴影颜色 - rgba(30,41,59, 0.04)
  static const Color _shadowColorLight = Color(0x0A1E293B);

  // ==================== 卡片阴影 ====================
  /// 无阴影
  static const List<BoxShadow> none = [];

  /// 轻微阴影 - 用于悬浮按钮、轻微层次
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, AppDimensions.shadowOffsetSm),
      blurRadius: AppDimensions.shadowBlurRadiusSm,
      spreadRadius: 0,
    ),
  ];

  /// 标准阴影 - 用于卡片、按钮
  static const List<BoxShadow> md = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, AppDimensions.shadowOffsetMd),
      blurRadius: AppDimensions.shadowBlurRadiusMd,
      spreadRadius: 0,
    ),
  ];

  /// 大阴影 - 用于弹出层、抽屉
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, AppDimensions.shadowOffsetLg),
      blurRadius: AppDimensions.shadowBlurRadiusLg,
      spreadRadius: 0,
    ),
  ];

  /// 超大阴影 - 用于模态对话框、重要提示
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: _shadowColorDark,
      offset: Offset(0, AppDimensions.shadowOffsetXl),
      blurRadius: AppDimensions.shadowBlurRadiusXl,
      spreadRadius: 0,
    ),
  ];

  // ==================== 特殊阴影效果 ====================
  /// 向上的阴影 - 用于底部导航栏
  static const List<BoxShadow> upward = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, -AppDimensions.shadowOffsetMd),
      blurRadius: AppDimensions.shadowBlurRadiusMd,
      spreadRadius: 0,
    ),
  ];

  /// 内阴影效果 - 用于输入框内凹效果
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, AppDimensions.shadowOffsetSm),
      blurRadius: AppDimensions.shadowBlurRadiusSm,
      spreadRadius: -1,
    ),
  ];

  /// 环形阴影 - 用于焦点状态（品牌蓝 sky-700）
  static const List<BoxShadow> focus = [
    BoxShadow(
      color: Color(0x330369A1), // 品牌蓝 20% 透明度
      offset: Offset(0, 0),
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];

  /// 品牌蓝光晕 - 用于重点元素高亮
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x400369A1), // 品牌蓝 25% 透明度
      offset: Offset(0, 0),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];

  /// 错误状态阴影（rose-600）
  static const List<BoxShadow> error = [
    BoxShadow(
      color: Color(0x1AE11D48), // rose-600 10% 透明度
      offset: Offset(0, AppDimensions.shadowOffsetMd),
      blurRadius: AppDimensions.shadowBlurRadiusMd,
      spreadRadius: 0,
    ),
  ];

  /// 成功状态阴影（emerald-600）
  static const List<BoxShadow> success = [
    BoxShadow(
      color: Color(0x1A059669), // emerald-600 10% 透明度
      offset: Offset(0, AppDimensions.shadowOffsetMd),
      blurRadius: AppDimensions.shadowBlurRadiusMd,
      spreadRadius: 0,
    ),
  ];

  /// 警告状态阴影（amber-500）
  static const List<BoxShadow> warning = [
    BoxShadow(
      color: Color(0x1AF59E0B), // amber-500 10% 透明度
      offset: Offset(0, AppDimensions.shadowOffsetMd),
      blurRadius: AppDimensions.shadowBlurRadiusMd,
      spreadRadius: 0,
    ),
  ];

  // ==================== 深度层次阴影 ====================
  /// 深度1 - 用于按钮、小卡片
  static const List<BoxShadow> depth1 = [
    BoxShadow(
      color: _shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// 深度2 - 用于卡片、菜单
  static const List<BoxShadow> depth2 = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// 深度3 - 用于弹出层、工具提示
  static const List<BoxShadow> depth3 = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 深度4 - 用于抽屉、侧边栏
  static const List<BoxShadow> depth4 = [
    BoxShadow(
      color: _shadowColor,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// 深度5 - 用于模态对话框、全屏覆盖
  static const List<BoxShadow> depth5 = [
    BoxShadow(
      color: _shadowColorDark,
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  // ==================== 动态阴影生成器 ====================
  /// 创建自定义阴影
  static List<BoxShadow> custom({
    required double offsetX,
    required double offsetY,
    required double blurRadius,
    double spreadRadius = 0,
    Color color = _shadowColor,
  }) {
    return [
      BoxShadow(
        color: color,
        offset: Offset(offsetX, offsetY),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// 创建有颜色的阴影
  static List<BoxShadow> colored({
    required Color color,
    double offsetY = AppDimensions.shadowOffsetMd,
    double blurRadius = AppDimensions.shadowBlurRadiusMd,
    double opacity = 0.1,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: Offset(0, offsetY),
        blurRadius: blurRadius,
        spreadRadius: 0,
      ),
    ];
  }

  /// 创建渐变阴影
  static List<BoxShadow> gradient({
    required List<Color> colors,
    double offsetY = AppDimensions.shadowOffsetMd,
    double blurRadius = AppDimensions.shadowBlurRadiusMd,
  }) {
    return colors.asMap().entries.map((entry) {
      int index = entry.key;
      Color color = entry.value;
      return BoxShadow(
        color: color.withValues(alpha: 0.1 / (index + 1)),
        offset: Offset(0, offsetY + index.toDouble()),
        blurRadius: blurRadius + index.toDouble(),
        spreadRadius: 0,
      );
    }).toList();
  }

  // ==================== 便捷方法 ====================
  /// 根据Material Design规范获取高度对应的阴影
  static List<BoxShadow> getElevationShadow(double elevation) {
    if (elevation <= 0) return none;
    if (elevation <= 1) return depth1;
    if (elevation <= 2) return depth2;
    if (elevation <= 4) return depth3;
    if (elevation <= 8) return depth4;
    return depth5;
  }

  /// 获取响应式阴影 (根据屏幕尺寸调整)
  static List<BoxShadow> getResponsiveShadow(double screenWidth) {
    if (screenWidth < AppDimensions.breakpointMobile) {
      return sm;
    } else if (screenWidth < AppDimensions.breakpointTablet) {
      return md;
    } else {
      return lg;
    }
  }

  /// 获取按钮状态阴影
  static List<BoxShadow> getButtonShadow({
    bool isPressed = false,
    bool isHovered = false,
    bool isDisabled = false,
  }) {
    if (isDisabled) return none;
    if (isPressed) return sm;
    if (isHovered) return lg;
    return md;
  }
}

/// DeepStream 暗色模式阴影系统
///
/// 暗色模式使用发光边框 + 品牌蓝光晕代替传统投影。
class AppShadowsDark {
  AppShadowsDark._();

  /// 无阴影
  static const List<BoxShadow> none = [];

  /// 轻微发光边框
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1421262D), // borderPrimary 8%
      offset: Offset(0, 0),
      blurRadius: 1,
      spreadRadius: 1,
    ),
  ];

  /// 标准发光边框
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x2121262D), // borderPrimary 13%
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  /// 大发光边框
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x3321262D), // borderPrimary 20%
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 品牌蓝光晕 - 用于焦点/高亮状态
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x4058A6FF), // accentPrimary 25%
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  /// 焦点状态
  static const List<BoxShadow> focus = [
    BoxShadow(
      color: Color(0x4058A6FF), // accentPrimary 25%
      offset: Offset(0, 0),
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];
}
 
 
 