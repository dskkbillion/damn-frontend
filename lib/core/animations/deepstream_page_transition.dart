import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme/app_dimensions.dart';

/// DeepStream 统一转场动画
/// 横向滑入 300ms easeOutCubic（设计规范）
class DeepStreamPageTransition extends CustomTransitionPage<void> {
  DeepStreamPageTransition({
    required super.child,
    super.key,
  }) : super(
          transitionDuration: AppDimensions.animationStandard,
          reverseTransitionDuration: AppDimensions.animationStandard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: child,
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
