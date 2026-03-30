import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

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
    Key? key,
    required this.categories,
    this.onCategoryClicked,
    this.itemsPerRow = 5,
    this.itemHeight = 80.0,
    this.spacing = 10.0,
    this.runSpacing = 16.0,
  }) : super(key: key);

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
              child: ClipOval(
                child: Image.network(
                  category.iconUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.borderInput,
                      child: Icon(
                        Icons.category,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
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
