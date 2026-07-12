import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import '../../domain/entities/order.dart';
import 'order_detail_item_tile.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 订单商品列表组件
class OrderItemsSection extends StatelessWidget {
  final Order order;

  const OrderItemsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final items = order.items;
    if (items.isEmpty) {
      return GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(AppLocalizations.of(context).order_items_empty),
        ),
      );
    }
    
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_items_title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context).order_items_count(items.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              // 买家端订单详情不展示交付天数/可修改次数（轻咨询形态旧字段）
              children: items
                  .map((item) =>
                      OrderDetailItemTile(item: item, showDeliveryMeta: false))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
