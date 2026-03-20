import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';

/// Displays dynamic content based on the order's status in the SellerOrderDetailPage.
class SellerDynamicContentArea extends StatelessWidget {
  final Order order;

  const SellerDynamicContentArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    AppLogger.d('[SellerDynamicContentArea] Building for state: ${order.state}');
    // Use a switch statement to return different content widgets based on the state
    switch (order.state) {
      case OrderStatus.awaitingStart:
        // No specific dynamic content needed for this state usually
        return const SizedBox.shrink(); // Return empty widget
      
      case OrderStatus.awaitingDelivery:
        return _buildAwaitingDeliveryContent(context);

      // Add case for awaitingConfirmation
      case OrderStatus.awaitingConfirmation:
        return _buildAwaitingConfirmationContent(context);

      // Add case for orderCompleted
      case OrderStatus.orderCompleted:
        AppLogger.d('[SellerDynamicContentArea] Matched orderCompleted state.');
        return _buildOrderCompletedContent(context);

      // Add case for canceled
      case OrderStatus.canceled:
         return _buildCanceledContent(context);

      // Add case for applyForRefuse
      case OrderStatus.applyForRefuse:
         return _buildApplyForRefuseContent(context);

      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
      case OrderStatus.sellerSupplementaryMaterials:
        return _buildAfterSaleContent(context);

      default:
        // Default case, return empty if no specific content for the state
        return const SizedBox.shrink();
    }
  }

  // --- Content Builder Methods for Specific States ---

  /// Builds content for the 'Awaiting Delivery' state.
  Widget _buildAwaitingDeliveryContent(BuildContext context) {
    // 买家材料现在在 SellerOrderMaterialsSection 中显示
    // 这里可以显示其他特定于"待交付"状态的内容
    return const SizedBox.shrink();
  }


  /// Builds content for the 'Awaiting Confirmation' state.
  Widget _buildAwaitingConfirmationContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12.0),
         side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
       ),
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(
                children: [
                  Icon(Icons.task_alt_outlined, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('服务已交付', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
               Text(
                 '您已完成服务交付，请等待买家确认。如有问题，买家可能会发起售后。' ,
                 style: textTheme.bodyMedium,
               ),
              // TODO: 后续版本可以添加交付内容的详情显示
           ],
         ),
       ),
    );
  }

  /// Builds content for the 'Order Completed' state.
  Widget _buildOrderCompletedContent(BuildContext context) {
    AppLogger.d('[SellerDynamicContentArea] Executing _buildOrderCompletedContent.');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Display a simple confirmation card
    return Card(
       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12.0),
         side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
       ),
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Row(
            children: [
              Icon(Icons.verified_outlined, size: 20, color: Colors.green[700]), // Use a verified icon
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '此订单已顺利完成。', 
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
              ),
              // TODO: Optionally, if API provides evaluation status, display it here.
              // Example: Text(order.evaluationStatus ?? '尚未评价', style: textTheme.bodySmall)
            ],
         ),
       ),
    );
  }

  /// Builds content for the 'Canceled' state.
  Widget _buildCanceledContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Display a simple cancellation card
    return Card(
       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12.0),
         side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
       ),
       color: colorScheme.errorContainer.withOpacity(0.3), // Use error color hint
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Row(
            children: [
              Icon(Icons.cancel_outlined, size: 20, color: colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '此订单已被取消。', 
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onErrorContainer)
                ),
              ),
              // TODO: Optionally, if API provides cancellation reason, display it here.
              // Example: Text(order.cancelReason ?? '', style: textTheme.bodySmall)
            ],
         ),
       ),
    );
  }

  /// Builds content for the 'Apply For Refuse' state.
  Widget _buildApplyForRefuseContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Display a card indicating refusal request submitted
    return Card(
       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       elevation: 0,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12.0),
         side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
       ),
       color: colorScheme.surfaceVariant.withOpacity(0.3), // Neutral background
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('已申请拒绝订单', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 4),
                     Text(
                      '您的拒绝申请已提交，正在等待处理。', 
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                    ),
                    // TODO: If API/Order entity provides refusal reason/remarks, display here.
                  ],
                )
              ),
            ],
         ),
       ),
    );
  }

  Widget _buildAfterSaleContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final bool mediation = order.state == OrderStatus.applyingForMediation;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      color: mediation
          ? colorScheme.primaryContainer.withOpacity(0.28)
          : colorScheme.surfaceVariant.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              mediation ? Icons.gavel_outlined : Icons.support_agent_outlined,
              size: 20,
              color: mediation ? colorScheme.primary : colorScheme.secondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediation ? '平台介入中' : '售后处理中',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mediation
                        ? '平台已介入当前售后流程。请继续在聊天室与买家沟通补充说明，平台会结合聊天记录继续处理。'
                        : '当前订单已进入售后流程。请在聊天室继续与买家沟通，订单详情页仅保留流程状态与操作入口。',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: Implement builder methods for other states
  // Widget _buildAfterSaleContent(BuildContext context) { ... }
}
