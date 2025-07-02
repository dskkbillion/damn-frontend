import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';

/// Widget displaying information while waiting for seller action (accept or deliver).
class WaitingActionArea extends StatelessWidget {
  final Order order;

  const WaitingActionArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String waitingMessage;
    switch (order.state) {
      case OrderStatus.awaitingStart: // 假设这是等待卖家开启服务
        waitingMessage = '等待卖家开启服务。';
        break;
      case OrderStatus.awaitingDelivery: // 等待卖家发货
        waitingMessage = '卖家备货中，请耐心等待发货。';
        break;
      default:
        waitingMessage = '等待处理中...'; // Fallback
    }

    final hasBuyerRemark = order.buyerRemark != null && order.buyerRemark!.isNotEmpty;

    return Card(
      // 使用统一的Card主题，移除自定义样式
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 使用标准间距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20), // Use an info icon
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    waitingMessage,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
            // Conditionally display buyer remark
            if (hasBuyerRemark) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '买家备注:',
                style: textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                order.buyerRemark!,
                style: textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 