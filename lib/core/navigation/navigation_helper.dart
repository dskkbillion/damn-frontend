import 'package:flutter/material.dart';
import '../animations/page_transitions.dart';

/// 导航辅助类
/// 提供各种页面切换动画的便捷方法
class NavigationHelper {
  /// 标准页面导航（适合平级页面）
  /// 使用滑动切换动画
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  /// [isRightToLeft] - 是否从右到左滑动，默认true
  static Future<T?> pushPage<T>(
    BuildContext context, 
    Widget page, {
    bool isRightToLeft = true,
  }) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.slideTransition(
        page,
        isRightToLeft: isRightToLeft,
      ),
    );
  }
  
  /// 详情页导航（适合子级页面）
  /// 使用缩放切换动画，给用户"深入查看"的感觉
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> pushDetailPage<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.scaleTransition(page),
    );
  }
  
  /// 模态页导航（适合弹出式页面）
  /// 使用向上滑动动画，符合"弹出"的操作习惯
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> pushModalPage<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.slideUpTransition(page),
    );
  }
  
  /// 高级页面导航（适合重要页面）
  /// 使用高级渐变动画，提供更有质感的切换效果
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> pushPremiumPage<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.premiumFadeTransition(page),
    );
  }
  
  /// iOS风格页面导航
  /// 使用iOS风格的滑动动画
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> pushIOSStylePage<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.iosStyleTransition(page),
    );
  }
  
  /// 替换当前页面（适合登录后跳转等场景）
  /// 使用渐变动画
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> replacePage<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.pushReplacement<T, Object?>(
      context,
      CustomPageTransitions.premiumFadeTransition(page),
    );
  }
  
  /// 清除所有页面并导航到新页面（适合注销登录等场景）
  /// 使用渐变动画
  /// 
  /// [context] - 上下文
  /// [page] - 目标页面
  static Future<T?> pushAndClearAll<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      CustomPageTransitions.premiumFadeTransition(page),
      (route) => false,
    );
  }
  
  /// 带动画的返回方法
  /// 
  /// [context] - 上下文
  /// [result] - 返回结果
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
  
  /// 返回到指定页面
  /// 
  /// [context] - 上下文
  /// [predicate] - 判断条件
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);
  }
  
  /// 返回到根页面
  /// 
  /// [context] - 上下文
  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// 卖家模式专用导航方法
  /// 进入时向左滑动，退出时向右滑动
  /// 
  /// [context] - 上下文
  /// [page] - 卖家模式页面
  static Future<T?> pushSellerMode<T>(
    BuildContext context, 
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      CustomPageTransitions.slideTransition(
        page,
        isRightToLeft: true, // 从右边滑入，营造向左进入效果
      ),
    );
  }
  
  /// 从卖家模式返回买家模式
  /// 使用页面替换而不是pop，确保向右滑动动画
  /// 
  /// [context] - 上下文
  /// [buyerPage] - 买家模式页面
  static Future<void> returnToBuyerMode(BuildContext context, Widget buyerPage) {
    return Navigator.pushReplacement(
      context,
      CustomPageTransitions.slideTransition(
        buyerPage,
        isRightToLeft: false, // 从左边滑入，营造"向右返回"的效果
      ),
    );
  }
}

/// 页面切换动画类型枚举
enum PageTransitionType {
  /// 滑动切换
  slide,
  /// 缩放切换
  scale,
  /// 向上滑动
  slideUp,
  /// 高级渐变
  premiumFade,
  /// iOS风格
  iosStyle,
}

/// 页面切换动画配置
class PageTransitionConfig {
  /// 动画类型
  final PageTransitionType type;
  /// 动画持续时间
  final Duration duration;
  /// 滑动方向（仅对slide类型有效）
  final bool isRightToLeft;
  
  const PageTransitionConfig({
    required this.type,
    this.duration = const Duration(milliseconds: 300),
    this.isRightToLeft = true,
  });
  
  /// 创建对应的PageRouteBuilder
  PageRouteBuilder<T> createRoute<T>(Widget page) {
    switch (type) {
      case PageTransitionType.slide:
        return CustomPageTransitions.slideTransition(
          page,
          isRightToLeft: isRightToLeft,
          duration: duration,
        );
      case PageTransitionType.scale:
        return CustomPageTransitions.scaleTransition(
          page,
          duration: duration,
        );
      case PageTransitionType.slideUp:
        return CustomPageTransitions.slideUpTransition(
          page,
          duration: duration,
        );
      case PageTransitionType.premiumFade:
        return CustomPageTransitions.premiumFadeTransition(
          page,
          duration: duration,
        );
      case PageTransitionType.iosStyle:
        return CustomPageTransitions.iosStyleTransition(
          page,
          duration: duration,
        );
    }
  }
}

/// 扩展Navigator类，添加自定义动画方法
extension NavigatorExtensions on NavigatorState {
  /// 使用自定义配置推送页面
  Future<T?> pushWithConfig<T>(
    Widget page,
    PageTransitionConfig config,
  ) {
    return push<T>(config.createRoute<T>(page));
  }
  
  /// 使用自定义配置替换页面
  Future<T?> pushReplacementWithConfig<T>(
    Widget page,
    PageTransitionConfig config,
  ) {
    return pushReplacement<T, Object?>(config.createRoute<T>(page));
  }
} 