import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: AspectRatio(
                aspectRatio: aspectRatio!,
                child: _buildImage(context),
              ),
            ),
            
            // 商品信息
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                      const SizedBox(width: 4),
                      Text(
                        item.score.toStringAsFixed(1), // 修改这里，限制为1位小数
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.evaluateNum})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 商品名称
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 价格和"让ta看看"按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PriceFormatter.format(item.sellingPrice),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (showRecommendButton)
                        GestureDetector(
                          onTap: onRecommendClicked,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              S.of(context).product_recommend_button,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
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
    final S s = S.of(context);
    
    // 检查是否有图片URL
    if (item.images.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.images.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.grey[400],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  s.product_image_loading_failed,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 如果没有图片URL，显示占位图
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                color: Colors.grey[400],
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                item.name.isNotEmpty ? item.name.substring(0, item.name.length > 10 ? 10 : item.name.length) : s.product_default_name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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