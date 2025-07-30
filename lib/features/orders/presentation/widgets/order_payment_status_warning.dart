import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

/// 订单支付状态警告组件
class OrderPaymentStatusWarning extends StatelessWidget {
  final Order order;

  const OrderPaymentStatusWarning({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // 只有在订单状态为"待付款"时才显示警告
    if (order.state != OrderStatus.awaitingPayment) {
      return const SizedBox.shrink();
    }

    // 检查订单是否已经超过自动取消时间但仍未支付
    final now = DateTime.now();
    final orderCreatedAt = order.createdAt;
    final timeDifference = now.difference(orderCreatedAt).inMinutes;
    
    // 如果订单创建超过30分钟且仍为待付款状态，显示警告
    if (timeDifference > 30) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '支付状态提醒',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '如果您已经完成支付但订单仍显示"待付款"，可能是系统延迟所致。请稍后刷新页面查看。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}