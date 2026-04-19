import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/enums/product_status.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_managed_product.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/status_tag.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 商品卡片组件
/// 
/// 用于在商品管理列表页面显示商品信息和操作按钮
class ProductCard extends StatelessWidget {
  /// 商品数据
  final SellerManagedProduct product;
  
  /// 编辑按钮点击回调
  final Function(SellerManagedProduct) onEdit;
  
  /// 删除按钮点击回调
  final Function(SellerManagedProduct)? onDelete;
  
  /// 上架/下架切换回调
  final Function(SellerManagedProduct, bool)? onToggleStatus;
  
  /// 发布按钮点击回调 (针对草稿商品)
  final Function(SellerManagedProduct)? onPublish;
  
  /// 查看详情回调
  final Function(SellerManagedProduct)? onView;
  
  /// 构造函数
  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.onPublish,
    this.onView,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 商品状态标签
    final statusTag = _buildStatusTag();
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppDimensions.spacingSm, horizontal: AppDimensions.spacingLg),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品基本信息
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: product.images.isNotEmpty 
                      ? Image.network(
                          product.images.split(',').first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildErrorImage(),
                        )
                      : _buildErrorImage(),
                ),
                const SizedBox(width: 12),
                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // statusTag, // 暂时注释掉状态标签
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                                                  '¥${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.sales != null)
                        Text(
                          AppLocalizations.of(context)?.seller_product_card_sales(product.sales!) ?? 'Sales: ${product.sales}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建状态标签
  Widget _buildStatusTag() {
    switch (product.status) {
      case ProductStatus.normal:
        return StatusTags.selling();
      case ProductStatus.disabled:
        return StatusTags.disabled();
      case ProductStatus.draft:
        return StatusTags.draft();
      case ProductStatus.unknown:
        return StatusTag(text: product.status.displayName, type: StatusTagType.warning);
      case ProductStatus.reviewing:
        return StatusTag(text: product.status.displayName, type: StatusTagType.info);
      case ProductStatus.rejected:
        return StatusTag(text: product.status.displayName, type: StatusTagType.defaultTag);
      case ProductStatus.soldOut:
        return StatusTag(text: product.status.displayName, type: StatusTagType.defaultTag);
    }
  }
  
  /// 构建操作按钮
  List<Widget> _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttons = <Widget>[];

    // 查看按钮 (所有商品都可以查看)
    if (onView != null) {
      buttons.add(
        OutlinedButton(
          onPressed: () => onView!(product),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(60, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(l10n?.seller_product_card_view ?? 'View'),
        ),
      );
      buttons.add(const SizedBox(width: 8));
    }

    // 编辑按钮 (所有商品都可以编辑)
    buttons.add(
      OutlinedButton(
        onPressed: () => onEdit(product),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(60, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(l10n?.product_management_action_edit ?? 'Edit'),
      ),
    );

    // 状态切换按钮 (已发布的商品可以上架/下架)
    if (onToggleStatus != null && product.isSwitchable) {
      buttons.add(const SizedBox(width: 8));
      final bool isEnabled = product.status == ProductStatus.normal;

      buttons.add(
        OutlinedButton(
          onPressed: () => onToggleStatus!(product, !isEnabled),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(60, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(isEnabled
              ? (l10n?.product_management_action_off_shelf ?? 'Off Shelf')
              : (l10n?.product_management_action_on_shelf ?? 'On Shelf')),
        ),
      );
    }

    // 发布按钮 (草稿商品可以发布)
    if (onPublish != null && product.isPublishable) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        FilledButton(
          onPressed: () => onPublish!(product),
          style: FilledButton.styleFrom(
            minimumSize: const Size(60, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(l10n?.product_management_action_publish ?? 'Publish'),
        ),
      );
    }

    // 删除按钮 (所有商品都可以删除)
    if (onDelete != null) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        OutlinedButton(
          onPressed: () => onDelete!(product),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(60, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: AppColors.error,
          ),
          child: Text(l10n?.product_management_action_delete ?? 'Delete'),
        ),
      );
    }

    return buttons;
  }
  
  /// 构建图片加载错误占位图
  Widget _buildErrorImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.backgroundTertiary,
      child: Icon(
        Icons.image,
        color: AppColors.grey[500],
        size: 40,
      ),
    );
  }
} 