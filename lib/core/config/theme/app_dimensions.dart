/// 应用尺寸系统
/// 定义了整个应用中使用的标准尺寸、间距和圆角
class AppDimensions {
  // 私有构造函数，防止实例化
  AppDimensions._();

  // ==================== 间距系统 ====================
  /// 超小间距 - 4px
  static const double spacingXs = 4.0;
  
  /// 小间距 - 8px
  static const double spacingSm = 8.0;
  
  /// 中等间距 - 12px
  static const double spacingMd = 12.0;
  
  /// 大间距 - 16px
  static const double spacingLg = 16.0;
  
  /// 超大间距 - 20px
  static const double spacingXl = 20.0;
  
  /// 超超大间距 - 24px
  static const double spacingXxl = 24.0;
  
  /// 巨大间距 - 32px
  static const double spacingXxxl = 32.0;
  
  /// 超巨大间距 - 48px
  static const double spacingXxxxl = 48.0;

  // ==================== 圆角系统（DeepStream 设计语言） ====================
  /// 无圆角
  static const double radiusNone = 0.0;

  /// 小圆角 - 6px
  static const double radiusSm = 6.0;

  /// 中等圆角 - 10px
  static const double radiusMd = 10.0;

  /// 大圆角 - 14px
  static const double radiusLg = 14.0;

  /// 超大圆角 - 20px
  static const double radiusXl = 20.0;

  /// 胶囊圆角 - 999px（全圆角按钮/标签）
  static const double radiusPill = 999.0;

  /// 圆形 - 999px
  static const double radiusCircle = 999.0;

  // ==================== 边框宽度 ====================
  /// 细边框 - 0.5px
  static const double borderThin = 0.5;
  
  /// 标准边框 - 1px
  static const double borderStandard = 1.0;
  
  /// 粗边框 - 2px
  static const double borderThick = 2.0;
  
  /// 超粗边框 - 4px
  static const double borderExtraThick = 4.0;

  // ==================== 组件高度 ====================
  /// 按钮高度
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  
  /// 输入框高度
  static const double inputHeightSm = 32.0;
  static const double inputHeightMd = 40.0;
  static const double inputHeightLg = 48.0;
  
  /// AppBar高度 (使用Flutter默认值)
  static const double appBarHeight = 56.0;
  
  /// TabBar高度
  static const double tabBarHeight = 46.0;
  
  /// BottomNavigationBar高度
  static const double bottomNavHeight = 56.0;
  
  /// 卡片最小高度
  static const double cardMinHeight = 80.0;
  
  /// 列表项高度
  static const double listItemHeightSm = 48.0;
  static const double listItemHeightMd = 56.0;
  static const double listItemHeightLg = 72.0;

  // ==================== 图标尺寸 ====================
  /// 小图标 - 16px
  static const double iconSm = 16.0;
  
  /// 中等图标 - 20px
  static const double iconMd = 20.0;
  
  /// 大图标 - 24px
  static const double iconLg = 24.0;
  
  /// 超大图标 - 32px
  static const double iconXl = 32.0;
  
  /// 头像图标 - 40px
  static const double iconAvatar = 40.0;

  // ==================== 容器尺寸 ====================
  /// 页面水平边距
  static const double pageHorizontalPadding = spacingLg;
  
  /// 页面垂直边距
  static const double pageVerticalPadding = spacingLg;
  
  /// 卡片内边距
  static const double cardPadding = spacingLg;
  
  /// 对话框内边距
  static const double dialogPadding = spacingXl;
  
  /// 底部导航栏内边距
  static const double bottomNavPadding = spacingSm;

  // ==================== 阴影相关 ====================
  /// 阴影模糊半径
  static const double shadowBlurRadiusSm = 2.0;
  static const double shadowBlurRadiusMd = 4.0;
  static const double shadowBlurRadiusLg = 8.0;
  static const double shadowBlurRadiusXl = 16.0;
  
  /// 阴影偏移
  static const double shadowOffsetSm = 1.0;
  static const double shadowOffsetMd = 2.0;
  static const double shadowOffsetLg = 4.0;
  static const double shadowOffsetXl = 8.0;

  // ==================== 响应式断点 ====================
  /// 手机屏幕断点
  static const double breakpointMobile = 480.0;
  
  /// 平板屏幕断点
  static const double breakpointTablet = 768.0;
  
  /// 桌面屏幕断点
  static const double breakpointDesktop = 1024.0;
  
  /// 大桌面屏幕断点
  static const double breakpointLargeDesktop = 1440.0;

  // ==================== 最大宽度限制 ====================
  /// 内容最大宽度
  static const double contentMaxWidth = 1200.0;
  
  /// 对话框最大宽度
  static const double dialogMaxWidth = 400.0;
  
  /// 卡片最大宽度
  static const double cardMaxWidth = 320.0;

  // ==================== 最小触摸目标尺寸 ====================
  /// 最小触摸目标尺寸 (遵循Material Design规范)
  static const double minTouchTarget = 48.0;
  
  /// 小型触摸目标尺寸
  static const double minTouchTargetSm = 32.0;

  // ==================== 动画持续时间（DeepStream 动效语言） ====================
  /// 快速动画 - 150ms
  static const Duration animationFast = Duration(milliseconds: 150);

  /// 标准动画 - 300ms（对齐横向滑入转场）
  static const Duration animationStandard = Duration(milliseconds: 300);

  /// 慢速动画 - 400ms
  static const Duration animationSlow = Duration(milliseconds: 400);

  /// 超慢动画 - 600ms
  static const Duration animationExtraSlow = Duration(milliseconds: 600);

  // ==================== 便捷方法 ====================
  /// 获取水平间距
  static double getHorizontalSpacing(double multiplier) => spacingLg * multiplier;
  
  /// 获取垂直间距
  static double getVerticalSpacing(double multiplier) => spacingLg * multiplier;
  
  /// 获取响应式间距 (根据屏幕宽度)
  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return spacingSm;
    } else if (screenWidth < breakpointTablet) {
      return spacingMd;
    } else {
      return spacingLg;
    }
  }
  
  /// 获取响应式圆角
  static double getResponsiveRadius(double screenWidth) {
    if (screenWidth < breakpointMobile) {
      return radiusSm;
    } else if (screenWidth < breakpointTablet) {
      return radiusMd;
    } else {
      return radiusLg;
    }
  }
} 
 
 
 