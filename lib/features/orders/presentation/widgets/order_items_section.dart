import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import '../../domain/entities/order.dart';
import 'order_detail_item_tile.dart';

/// 订单商品列表组件
class OrderItemsSection extends StatelessWidget {
  final Order order;

  const OrderItemsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.d('🔍 OrderItemsSection: 商品数量 ${order.items.length}');
    final items = order.items;
    if (items.isEmpty) {
      AppLogger.d('⚠️ OrderItemsSection: 商品列表为空');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: const Center(
          child: Text('暂无商品信息'),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderPrimary,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '商品信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    '${items.length}件',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            child: Column(
              children: items.map((item) => OrderDetailItemTile(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
