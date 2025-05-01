import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';

/// Displays a card with a title and description based on the order's current status,
/// from the seller's perspective.
class SellerStatusDescriptionCard extends StatelessWidget {
  final Order order;

  const SellerStatusDescriptionCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String title = '未知状态';
    String description = '订单当前处于未知状态。';
    IconData? iconData; // Optional icon

    // Determine content based on order status
    switch (order.state) {
      case OrderStatus.awaitingStart:
        title = '等待卖家接单';
        description = '请尽快确认是否接受此订单。如在 xx 时间内未响应，订单将自动取消，并可能影响您的店铺评分。'; // Placeholder, refine time later
        iconData = Icons.hourglass_top_rounded;
        break;
      case OrderStatus.awaitingDelivery:
        title = '等待卖家发货';
        description = '请尽快备货并安排发货。买家正在等待您的商品/服务。';
        iconData = Icons.inventory_2_outlined;
        break;
      case OrderStatus.awaitingConfirmation:
        title = '等待买家确认收货';
        description = '您已发货，请等待买家确认收货。您也可以查看物流或提醒买家。';
        iconData = Icons.local_shipping_outlined;
        break;
       case OrderStatus.orderCompleted:
         title = '订单已完成';
         description = '订单已成功完成。您可以邀请买家进行评价。';
         iconData = Icons.check_circle_outline_rounded;
         break;
       case OrderStatus.canceled:
         title = '订单已取消';
         description = '此订单已被取消。';
         iconData = Icons.cancel_outlined;
         break;
       // TODO: Add cases for other seller-relevant statuses (afterSale, applyForRefuse, etc.)
      default:
        title = '处理中'; // Generic fallback
        description = '订单正在处理中，请关注后续状态更新。';
        iconData = Icons.sync;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: colorScheme.surfaceVariant.withOpacity(0.3), // Use a slightly different background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (iconData != null)
              Icon(iconData, size: 32, color: colorScheme.primary),
            if (iconData != null)
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4.0),
                  Text(description, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

