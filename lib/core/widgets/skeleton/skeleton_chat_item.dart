import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import 'shimmer_effect.dart';

/// 聊天列表骨架项
///
/// 左侧圆形头像占位 + 右侧名称条、消息预览条 + 右上角时间小条。
class SkeletonChatItem extends StatelessWidget {
  const SkeletonChatItem({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            // 右侧内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称 + 时间行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 名称条
                      Container(
                        height: 14.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                      ),
                      // 时间小条
                      Container(
                        height: 10.0,
                        width: 40.0,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  // 消息预览条
                  Container(
                    height: 12.0,
                    width: double.infinity,
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
