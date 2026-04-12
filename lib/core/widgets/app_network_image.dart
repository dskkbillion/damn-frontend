import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';

/// 统一封装 CachedNetworkImage 的图片组件。
///
/// 支持 shimmer 占位、圆角裁剪、Hero 动画、错误重试等功能。
class AppNetworkImage extends StatelessWidget {
  /// 图片 URL（必填）
  final String imageUrl;

  final double? width;
  final double? height;

  /// 图片填充方式，默认 [BoxFit.cover]
  final BoxFit fit;

  /// 圆角，非 null 时用 ClipRRect 裁剪
  final BorderRadius? borderRadius;

  /// Hero tag，非 null 时自动用 Hero 包裹（含 placeholder / error 状态）
  final String? heroTag;

  /// 淡入时长，默认 300ms
  final Duration fadeInDuration;

  /// 淡出时长，默认 300ms
  final Duration fadeOutDuration;

  /// 自定义 placeholder（优先于内置逻辑）
  final Widget? placeholder;

  /// 自定义 error widget（优先于内置逻辑）
  final Widget? errorWidget;

  /// 为 true 时在错误 widget 下方加"重试"按钮
  final bool showRetryOnError;

  /// 重试回调，仅当 [showRetryOnError] == true 时生效
  final VoidCallback? onRetry;

  /// true 时用 ShimmerEffect 包裹占位容器，false 时用纯色占位
  final bool useShimmerPlaceholder;

  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    this.showRetryOnError = false,
    this.onRetry,
    this.useShimmerPlaceholder = true,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;

    final base = Container(
      width: width,
      height: height,
      color: AppColors.borderPrimary,
    );

    if (useShimmerPlaceholder) {
      return ShimmerEffect(child: base);
    }
    return base;
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      color: AppColors.borderPrimary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported,
            color: AppColors.textTertiary,
          ),
          if (showRetryOnError && onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '重试',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (ctx, url) => _buildPlaceholder(ctx),
      errorWidget: (ctx, url, error) => _buildErrorWidget(ctx),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return image;
  }
}
