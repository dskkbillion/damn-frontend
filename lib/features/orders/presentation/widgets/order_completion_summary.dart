import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

/// Widget displaying summary information for completed or canceled orders.
class OrderCompletionSummary extends StatelessWidget {
  final Order order;

  const OrderCompletionSummary({super.key, required this.order});

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    // Using intl for better formatting, adjust pattern as needed
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = order.state == OrderStatus.orderCompleted;

    // Icon based on state
    final IconData statusIconData = isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined;
    final Color statusIconColor = isCompleted ? Colors.green : Colors.red;

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

    return Card(
      // 使用统一Card主题
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 使用标准间距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 Icon(statusIconData, color: statusIconColor, size: 22), // Add status icon
                 const SizedBox(width: 8),
                 Text(
                   title,
                   style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Keep title prominent
                 ),
               ],
             ),
            const SizedBox(height: 16),
             const Divider(height: 1, thickness: 0.5), // Add a divider
             const SizedBox(height: 16),
            Row(
              children: [
                Text(
                    timeLabel,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]) // Slightly darker grey label
                ),
                const SizedBox(width: 8),
                Text(
                   _formatDateTime(time),
                   style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500) // Make time slightly bolder
                ),
              ],
            ),
            if (isCompleted && evaluation != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 16),
              Text(
                '评价内容',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
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
                const SizedBox(height: 10),
                Text(
                  evaluation.remark!.trim(),
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
              if (imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrls[index],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
            // TODO: Re-add cancel reason display if Order entity is updated with `cancelReason` field.
            // TODO: Potentially add a link to evaluation if completed and not evaluated yet,
            // though the primary evaluation trigger might be elsewhere.
          ],
        ),
      ),
    );
  }
} 
