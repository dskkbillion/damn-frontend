import 'package:flutter/material.dart';

/// DeepStream 的默认页面转场：淡入并伴随极轻微的缩放。
///
/// 这让内容像浮在冰蓝表面上自然聚焦，而不会像传统导航那样从侧边
/// 推入，和应用内的玻璃层级保持一致。
class DeepStreamFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const DeepStreamFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final scaleAnimation = Tween<double>(begin: 0.985, end: 1).animate(
      curvedAnimation,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(scale: scaleAnimation, child: child),
    );
  }
}
