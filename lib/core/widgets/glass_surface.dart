import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_dimensions.dart';
import '../config/theme/app_shadows.dart';

/// 悬浮导航在内容布局中需要预留的空间。
///
/// 导航本身通过 [GlassNavigationSurface] 叠在页面底部；使用 `extendBody`
/// 的壳页面应使用该度量，让最后一项内容停在胶囊上沿而非被盖住。
class GlassNavigationMetrics {
  const GlassNavigationMetrics._();

  static double navigationHeight(MediaQueryData mediaQuery) =>
      (mediaQuery.size.shortestSide * 0.17).clamp(56.0, 64.0).toDouble();

  static double bottomGap(MediaQueryData mediaQuery) =>
      (mediaQuery.size.height * 0.006).clamp(4.0, 8.0).toDouble();

  static double contentBottomInset(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return navigationHeight(mediaQuery) +
        mediaQuery.padding.bottom +
        bottomGap(mediaQuery);
  }
}

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

/// 底部导航专用的悬浮玻璃底座。
///
/// 导航保持比内容卡片更低的透明度和更强的背景模糊，让页面氛围能够
/// 透出，同时用白色边缘确保与页面内容有清晰、克制的分界。
class GlassNavigationSurface extends StatelessWidget {
  final Widget child;

  const GlassNavigationSurface({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColorsDark.backgroundElevated : AppColors.backgroundCard;
    final primary = isDark ? AppColorsDark.accentPrimary : AppColors.primary;
    final shortestSide = screenSize.shortestSide;
    final isExpanded = shortestSide >= 600;
    final navigationHeight =
        GlassNavigationMetrics.navigationHeight(mediaQuery);
    final horizontalMargin = (screenSize.width * 0.04)
        .clamp(12.0, isExpanded ? 32.0 : 24.0)
        .toDouble();
    final bottomGap = GlassNavigationMetrics.bottomGap(mediaQuery);
    DisplayFeature? verticalHinge;

    for (final feature in mediaQuery.displayFeatures) {
      final isHinge = feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold;
      if (isHinge && feature.bounds.height > feature.bounds.width) {
        verticalHinge = feature;
        break;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var alignment = Alignment.bottomCenter;
        var navigationWidth = constraints.maxWidth - horizontalMargin * 2;

        if (verticalHinge != null) {
          final leftPaneWidth = verticalHinge.bounds.left;
          final rightPaneWidth = screenSize.width - verticalHinge.bounds.right;
          final useRightPane = rightPaneWidth > leftPaneWidth;
          final paneWidth = useRightPane ? rightPaneWidth : leftPaneWidth;
          navigationWidth = paneWidth - horizontalMargin * 2;
          alignment =
              useRightPane ? Alignment.bottomRight : Alignment.bottomLeft;
        }

        final maximumWidth = isExpanded ? 640.0 : navigationWidth;
        navigationWidth = math.min(navigationWidth, maximumWidth);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalMargin,
            0,
            horizontalMargin,
            mediaQuery.padding.bottom + bottomGap,
          ),
          child: Align(
            alignment: alignment,
            heightFactor: 1,
            child: SizedBox(
              width: navigationWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(navigationHeight / 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: isDark ? 0.78 : 0.68),
                      borderRadius: BorderRadius.circular(navigationHeight / 2),
                      border: Border.all(
                        color: isDark
                            ? AppColorsDark.accentLight.withValues(alpha: 0.32)
                            : AppColors.onPrimary.withValues(alpha: 0.88),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: SizedBox(
                        height: navigationHeight,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
                  color:
                      (isDark ? AppColorsDark.accentPrimary : AppColors.primary)
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
  final double atmosphereIntensity;

  const GlassBackdrop({
    required this.child,
    this.atmosphereIntensity = 1,
    super.key,
  });

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
            child: _AmbientOrb(
              color: light.withValues(alpha: 0.18 * atmosphereIntensity),
              size: 360,
            ),
          ),
          Positioned(
            top: 280,
            right: -150,
            child: _AmbientOrb(
              color: primary.withValues(alpha: 0.10 * atmosphereIntensity),
              size: 320,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _AmbientOrb(
              color: light.withValues(alpha: 0.08 * atmosphereIntensity),
              size: 260,
            ),
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
