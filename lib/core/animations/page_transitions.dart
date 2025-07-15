import 'package:flutter/material.dart';

/// 自定义页面切换动画库
/// 提供多种页面切换动画效果，提升用户体验
class CustomPageTransitions {
  /// 滑动切换动画（适合平级页面）
  /// 
  /// [page] - 目标页面widget
  /// [isRightToLeft] - 是否从右到左滑动，默认true
  /// [duration] - 动画持续时间，默认300ms
  static PageRouteBuilder<T> slideTransition<T>(
    Widget page, {
    bool isRightToLeft = true,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 定义滑动方向
        // Offset(1.0, 0.0) = 新页面从屏幕右边开始，向左滑入到中心
        // Offset(-1.0, 0.0) = 新页面从屏幕左边开始，向右滑入到中心
        var begin = isRightToLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  /// 缩放切换动画（适合详情页面）
  /// 
  /// [page] - 目标页面widget
  /// [duration] - 动画持续时间，默认350ms
  static PageRouteBuilder<T> scaleTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 缩放动画：从0.85放大到1.0
        var scaleAnimation = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        // 渐变动画：从透明到不透明
        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  /// 向上滑动切换动画（适合模态页面）
  /// 
  /// [page] - 目标页面widget
  /// [duration] - 动画持续时间，默认400ms
  static PageRouteBuilder<T> slideUpTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 从底部向上滑动
        var slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
  
  /// 高级渐变切换动画（适合重要页面）
  /// 
  /// [page] - 目标页面widget
  /// [duration] - 动画持续时间，默认450ms
  static PageRouteBuilder<T> premiumFadeTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 前一个页面稍微缩小
        var exitScale = Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        ));
        
        // 当前页面从透明渐现并稍微放大
        var enterFade = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        var enterScale = Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        return Stack(
          children: [
            // 前一个页面效果
            if (secondaryAnimation.value > 0)
              ScaleTransition(
                scale: exitScale,
                child: Container(
                  color: Colors.black.withOpacity(0.1 * secondaryAnimation.value),
                ),
              ),
            // 当前页面效果
            ScaleTransition(
              scale: enterScale,
              child: FadeTransition(
                opacity: enterFade,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// iOS风格的页面切换动画
  /// 
  /// [page] - 目标页面widget
  /// [duration] - 动画持续时间，默认400ms
  static PageRouteBuilder<T> iosStyleTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 当前页面从右侧滑入
        var slideInAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        
        // 前一个页面向左滑出一部分
        var slideOutAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        ));
        
        return Stack(
          children: [
            // 前一个页面
            if (secondaryAnimation.value > 0)
              SlideTransition(
                position: slideOutAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.15 * secondaryAnimation.value),
                ),
              ),
            // 当前页面
            SlideTransition(
              position: slideInAnimation,
              child: child,
            ),
          ],
        );
      },
    );
  }

  /// 反向滑动切换动画（专门用于返回场景）
  /// 
  /// [page] - 目标页面widget
  /// [duration] - 动画持续时间，默认300ms
  static PageRouteBuilder<T> reverseSlideTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 强制从左边滑入，营造向右移动的效果
        var begin = const Offset(-1.0, 0.0); // 明确从左边开始
        var end = Offset.zero;
        var curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
} 