import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
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
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '支付状态提醒',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    '如果您已经完成支付但订单仍显示"待付款"，可能是系统延迟所致。请稍后刷新页面查看。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
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
