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

/// 内容卡片使用的玻璃表面。
///
/// 视觉重点放在边缘高光、细边框和柔和阴影；背景透明度保持克制，
/// 避免密集内容页面被大面积蓝色光效覆盖。
class GlassCard extends StatelessWidget {
  final Widget child;
  /// Optional width for cards used in grids; column cards still expand by default.
  final double? width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final Color? tintColor;
  final double? tintOpacity;
  final double blur;

  const GlassCard({
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(AppDimensions.spacingXl),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppDimensions.radiusLg),
    ),
    this.tintColor,
    this.tintOpacity,
    this.blur = 18,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = tintColor ??
        (isDark ? AppColorsDark.backgroundElevated : AppColors.backgroundCard);
    final opacity = tintOpacity ?? (isDark ? 0.72 : 0.58);
    final edgeColor = isDark
        ? AppColorsDark.accentLight.withValues(alpha: 0.28)
        : AppColors.onPrimary.withValues(alpha: 0.82);

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: width ?? double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: surface.withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border.all(color: edgeColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColorsDark.accentPrimary : AppColors.primary)
                      .withValues(alpha: 0.09),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 为玻璃卡片提供非常克制的主题氛围背景。
class GlassBackdrop extends StatelessWidget {
  final Widget child;

  const GlassBackdrop({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? AppColorsDark.gradientAtmosphere
        : AppColors.gradientAtmosphere;
    final primary = isDark ? AppColorsDark.accentPrimary : AppColors.primary;
    final light = isDark ? AppColorsDark.accentLight : AppColors.primaryLight;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -140,
            left: -130,
            child: _AmbientOrb(color: light.withValues(alpha: 0.18), size: 360),
          ),
          Positioned(
            top: 280,
            right: -150,
            child: _AmbientOrb(color: primary.withValues(alpha: 0.10), size: 320),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _AmbientOrb(color: light.withValues(alpha: 0.08), size: 260),
          ),
          child,
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _AmbientOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
