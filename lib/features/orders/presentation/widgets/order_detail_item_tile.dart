import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// Widget to display a single order item within the OrderDetailPage.
class OrderDetailItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderDetailItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 70, height: 70,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70, height: 70,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: textTheme.titleMedium, // 使用标准字体大小
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                if (item.skuName != null && item.skuName!.isNotEmpty)
                  Text(
                    item.skuName!,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${item.price.toStringAsFixed(2)}',
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
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      if (item.deliveryDay != null) ...[
                        Icon(
                          Icons.schedule, 
                          size: 14, 
                          color: colorScheme.secondary
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).order_item_delivery_days(item.deliveryDay!),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary
                          ),
                        ),
                      ],
                      if (item.deliveryDay != null && item.editNum != null)
                        const SizedBox(width: 16),
                      if (item.editNum != null) ...[
                        Icon(
                          Icons.edit, 
                          size: 14, 
                          color: colorScheme.secondary
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context).order_item_edit_count(item.editNum!),
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
    );
  }
} 