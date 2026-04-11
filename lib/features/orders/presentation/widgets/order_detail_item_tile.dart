import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget to display a single order item within the OrderDetailPage.
class OrderDetailItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderDetailItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final canNavigate = item.productId > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        onTap: canNavigate
            ? () => context.go('/home/product/${item.productId}')
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: Image.network(
                  item.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 70, height: 70,
                      color: AppColors.backgroundSecondary,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70, height: 70,
                    color: AppColors.backgroundSecondary,
                    child: Icon(Icons.broken_image, color: AppColors.textTertiary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (canNavigate) ...[
                          const SizedBox(width: AppDimensions.spacingSm),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: colorScheme.secondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    if (item.skuName != null && item.skuName!.isNotEmpty)
                      Text(
                        item.skuName!,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          PriceFormatter.format(item.price),
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
                        ),
                      ],
                    ),
                    // 显示交付天数和可修改次数
                    if (item.deliveryDay != null || item.editNum != null) ...[
                      const SizedBox(height: AppDimensions.spacingSm),
                      Row(
                        children: [
                          if (item.deliveryDay != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: colorScheme.secondary
                            ),
                            const SizedBox(width: AppDimensions.spacingXs),
                            Text(
                              '交付天数: ${item.deliveryDay}天',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary
                              ),
                            ),
                          ],
                          if (item.deliveryDay != null && item.editNum != null)
                            const SizedBox(width: AppDimensions.spacingLg),
                          if (item.editNum != null) ...[
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: colorScheme.secondary
                            ),
                            const SizedBox(width: AppDimensions.spacingXs),
                            Text(
                              '可修改次数: ${item.editNum}次',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
