import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

/// Widget displaying summary information for completed or canceled orders.
class OrderCompletionSummary extends StatelessWidget {
  final Order order;

  const OrderCompletionSummary({super.key, required this.order});

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = order.state == OrderStatus.orderCompleted;

    // Icon based on state
    final IconData statusIconData = isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined;
    final Color statusIconColor = isCompleted ? AppColors.success : AppColors.error;

    final title = isCompleted ? '订单已完成' : '订单已取消';
    final time = isCompleted ? order.completeTime : order.cancelTime;
    final timeLabel = isCompleted ? '完成时间:' : '取消时间:';
    final evaluation = order.evaluateDetail;
    final reviewerName = (evaluation?.anonymityFlag ?? false)
        ? '匿名评价'
        : ((evaluation?.buyer?.nickname ?? '').trim().isNotEmpty
            ? evaluation!.buyer!.nickname!.trim()
            : '买家评价');
    final imageUrls = evaluation?.images
            .where((item) => item.trim().isNotEmpty)
            .toList() ??
        const <String>[];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: const [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: const BoxDecoration(
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
                  statusIconData,
                  color: statusIconColor,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      timeLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      _formatDateTime(time),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (isCompleted && evaluation != null) ...[
                  const Divider(height: 24, thickness: 1),
                  Text(
                    '评价内容',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: List.generate(5, (index) {
                            final filled = index < (evaluation.score ?? 0);
                            return Icon(
                              filled ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 18,
                              color: filled ? Colors.amber : colorScheme.outline,
                            );
                          }),
                        ),
                      ),
                      Text(
                        reviewerName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (evaluation.createTime != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDateTime(evaluation.createTime),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if ((evaluation.remark ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    Text(
                      evaluation.remark!.trim(),
                      style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                  if (imageUrls.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingMd),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.spacingSm),
                        itemBuilder: (context, index) {
                          return AppNetworkImage(
                            imageUrl: imageUrls[index],
                            width: 72,
                            height: 72,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
