import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/shimmer_effect.dart';

/// 卖家端页面级骨架屏。
///
/// 用于首屏数据加载，保持页面的卡片结构可见，避免用一个转圈遮住整页。
class SellerPageSkeleton extends StatelessWidget {
  final SellerSkeletonVariant variant;

  const SellerPageSkeleton({
    this.variant = SellerSkeletonVariant.list,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBackdrop(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: ShimmerEffect(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildSections(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    switch (variant) {
      case SellerSkeletonVariant.detail:
        return [
          _buildCard(height: 116, lines: 2),
          _buildCard(height: 184, lines: 4),
          _buildCard(height: 132, lines: 3),
        ];
      case SellerSkeletonVariant.form:
        return [
          _buildCard(height: 96, lines: 2),
          _buildCard(height: 220, lines: 5),
          _buildCard(height: 154, lines: 3),
        ];
      case SellerSkeletonVariant.list:
        return List.generate(4, (_) => _buildCard(height: 112, lines: 3));
    }
  }

  Widget _buildCard({required double height, required int lines}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(width: 132, height: 18),
            const SizedBox(height: AppDimensions.spacingMd),
            ...List.generate(lines, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                  child: _line(width: index.isEven ? double.infinity : 210, height: 13),
                )),
          ],
        ),
      ),
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }
}

enum SellerSkeletonVariant { list, detail, form }
