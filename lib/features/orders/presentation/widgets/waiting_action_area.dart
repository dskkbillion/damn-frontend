import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

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

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      borderRadius: BorderRadius.circular(12),
      tintOpacity: 0.62,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20), // Use an info icon
                const SizedBox(width: AppDimensions.spacingSm),
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
              const SizedBox(height: AppDimensions.spacingLg),
              const Divider(),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                '买家备注:',
                style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                order.buyerRemark!,
                style: textTheme.bodyMedium,
              ),
            ],
          ],
      ),
    );
  }
}
