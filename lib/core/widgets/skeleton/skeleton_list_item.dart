import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import 'shimmer_effect.dart';

/// 通用列表骨架项
///
/// 左侧圆形头像占位 + 右侧标题行和副标题行占位。
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColorsDark.backgroundCard
        : AppColors.backgroundTertiary;

    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [
            // 圆形头像占位
            Container(
              width: AppDimensions.iconAvatar,
              height: AppDimensions.iconAvatar,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            // 右侧两行占位
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    width: 160.0,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
