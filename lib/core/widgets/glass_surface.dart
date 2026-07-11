import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_dimensions.dart';
import '../config/theme/app_shadows.dart';

/// DeepStream 的轻量玻璃表面。
///
/// 只用于导航栏、悬浮操作区和弹层等浮动层，不用于密集内容卡片。
class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;

  const GlassSurface({
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppDimensions.radiusLg),
    ),
    this.blur = 18,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColorsDark.backgroundElevated : AppColors.backgroundCard;
    final border =
        isDark ? AppColorsDark.borderSecondary : AppColors.borderPrimary;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.84 : 0.78),
            border: Border.all(
              color: border.withValues(alpha: isDark ? 0.72 : 0.9),
              width: AppDimensions.borderThin,
            ),
            boxShadow: AppShadows.upward,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
