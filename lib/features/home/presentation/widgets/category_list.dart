import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

import '../../domain/entities/home_category.dart';

/// 分类列表组件
class CategoryList extends StatelessWidget {
  /// 分类列表
  final List<HomeCategory> categories;

  /// 分类点击回调
  final Function(HomeCategory category)? onCategoryClicked;

  /// 每行显示的分类数量
  final int itemsPerRow;

  /// 分类项目高度
  final double itemHeight;

  /// 分类项目之间的间距
  final double spacing;

  /// 行之间的间距
  final double runSpacing;

  const CategoryList({
    super.key,
    required this.categories,
    this.onCategoryClicked,
    this.itemsPerRow = 5,
    this.itemHeight = 80.0,
    this.spacing = 10.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: WrapAlignment.spaceBetween,
        children: categories.map((category) {
          return _buildCategoryItem(context, category);
        }).toList(),
      ),
    );
  }

  /// 构建分类项目
  Widget _buildCategoryItem(BuildContext context, HomeCategory category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32 - (spacing * (itemsPerRow - 1))) / itemsPerRow;

    return GestureDetector(
      onTap: () {
        if (onCategoryClicked != null) {
          onCategoryClicked!(category);
        }
      },
      child: SizedBox(
        width: itemWidth,
        height: itemHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: AppNetworkImage(
                imageUrl: category.iconUrl,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
