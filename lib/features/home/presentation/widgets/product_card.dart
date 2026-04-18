import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../domain/entities/home_feed_item.dart';

/// 商品/服务卡片组件
class ProductCard extends StatelessWidget {
  /// 商品/服务数据
  final HomeFeedItem item;

  /// 卡片点击回调
  final VoidCallback? onCardClicked;

  /// "让ta看看"按钮点击回调
  final VoidCallback? onRecommendClicked;

  /// 卡片宽度
  final double? width;

  /// 卡片高度
  final double? height;

  /// 图片高度
  final double imageHeight;

  /// 图片宽高比
  final double? aspectRatio;

  /// 是否显示"让ta看看"按钮
  final bool showRecommendButton;

  const ProductCard({
    Key? key,
    required this.item,
    this.onCardClicked,
    this.onRecommendClicked,
    this.width,
    this.height,
    this.imageHeight = 150.0,
    this.aspectRatio = 1.0,
    this.showRecommendButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardClicked,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.borderSecondary,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusSm),
                topRight: Radius.circular(AppDimensions.radiusSm),
              ),
              child: AspectRatio(
                aspectRatio: aspectRatio!,
                child: _buildImage(context),
              ),
            ),

            // 商品信息
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 评分和评价数
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        item.score.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Text(
                        '(${item.evaluateNum})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXs),

                  // 商品名称（优先使用翻译名称）
                  Text(
                    item.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  // 价格和"让ta看看"按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PriceFormatter.format(item.sellingPrice),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (showRecommendButton)
                        GestureDetector(
                          onTap: onRecommendClicked,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSm,
                              vertical: AppDimensions.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.product_recommend_button,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片组件
  Widget _buildImage(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;

    // 检查是否有图片URL
    if (item.images.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: item.images.first,
        fit: BoxFit.cover,
        heroTag: 'product-image-${item.id}',
      );
    } else {
      // 如果没有图片URL，显示占位图
      return Container(
        color: AppColors.borderPrimary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                color: AppColors.textTertiary,
                size: 40,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                item.name.isNotEmpty ? item.name.substring(0, item.name.length > 10 ? 10 : item.name.length) : appLocalizations.product_default_name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
  }
}
