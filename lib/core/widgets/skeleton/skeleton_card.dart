import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import 'shimmer_effect.dart';

/// 瀑布流卡片骨架
///
/// 矩形图片占位 + 下方两行文字占位，圆角使用 radiusMd。
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColorsDark.backgroundCard
        : AppColors.backgroundTertiary;

    return ShimmerEffect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          Container(
            width: double.infinity,
            height: 160.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          // 标题行
          Container(
            height: 14.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          // 副标题行（较短）
          Container(
            height: 12.0,
            width: 100.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
        ],
      ),
    );
  }
}
