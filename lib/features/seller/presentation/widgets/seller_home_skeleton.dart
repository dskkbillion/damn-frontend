import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';

/// 卖家中心首页加载骨架。
///
/// 使用与内容卡片相同的间距和边缘层级，避免首次加载时出现突兀的转圈页面。
class SellerHomeSkeleton extends StatelessWidget {
  const SellerHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildPanel(height: 142, lines: 3),
          _buildPanel(height: 126, lines: 2),
          _buildPanel(height: 132, lines: 3),
          _buildPanel(height: 196, lines: 4),
        ],
      ),
    );
  }

  Widget _buildPanel({required double height, required int lines}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: ShimmerEffect(
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonLine(width: 132, height: 18),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    lines,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == lines - 1 ? 0 : AppDimensions.spacingSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkeletonLine(
                              width: double.infinity,
                              height: index == 0 ? 42 : 28,
                            ),
                            const SizedBox(height: 10),
                            const _SkeletonLine(width: double.infinity, height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }
}
