import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme/app_dimensions.dart';

/// DeepStream 统一转场动画
/// 淡入并轻微缩放 300ms easeOutCubic。
class DeepStreamPageTransition extends CustomTransitionPage<void> {
  DeepStreamPageTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.animationStandard,
          reverseTransitionDuration: AppDimensions.animationStandard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final scaleAnimation = Tween<double>(begin: 0.985, end: 1)
                .animate(curvedAnimation);

            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
        );
}

/// 无转场动画（用于 Tab 根页面切换）
class DeepStreamNoTransitionPage extends NoTransitionPage<void> {
  const DeepStreamNoTransitionPage({
    required super.child,
    super.key,
  });
}

/// Hero 专用转场动画（fade + 轻微缩放）。
/// 用于需要 Hero 共享元素动画的页面，避免额外的横向运动干扰共享元素。
class DeepStreamHeroPageTransition extends CustomTransitionPage<void> {
  DeepStreamHeroPageTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.animationStandard,
          reverseTransitionDuration: AppDimensions.animationStandard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final scaleAnimation = Tween<double>(begin: 0.99, end: 1)
                .animate(fadeAnimation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(scale: scaleAnimation, child: child),
            );
          },
        );
}
