import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

/// Widget to display a single order item within the OrderDetailPage.
class OrderDetailItemTile extends StatelessWidget {
  final OrderItem item;

  /// 是否展示交付天数 / 可修改次数。轻咨询形态下买家端不再需要这两个旧服务型字段，
  /// 买家侧（OrderItemsSection）传 false 隐藏；卖家端走独立渲染路径，默认 true 不受影响。
  final bool showDeliveryMeta;

  const OrderDetailItemTile({
    super.key,
    required this.item,
    this.showDeliveryMeta = true,
  });

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
          AppNetworkImage(
            imageUrl: item.imageUrl,
            width: 70,
            height: 70,
            borderRadius: BorderRadius.circular(8.0),
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
                      RegionConfig.formatPrice(item.price),
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
                    ),
                  ],
                ),
                // 显示交付天数和可修改次数
                if (showDeliveryMeta &&
                    (item.deliveryDay != null || item.editNum != null)) ...[
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