import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// Displays dynamic content based on the order's status in the SellerOrderDetailPage.
class SellerDynamicContentArea extends StatelessWidget {
  final Order order;

  const SellerDynamicContentArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    print('[SellerDynamicContentArea] Building for state: ${order.state}');
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
        print('[SellerDynamicContentArea] Matched orderCompleted state.');
        return _buildOrderCompletedContent(context);

      // Add case for canceled
      case OrderStatus.canceled:
         return _buildCanceledContent(context);

      // Add case for applyForRefuse
      case OrderStatus.applyForRefuse:
         return _buildApplyForRefuseContent(context);

      // TODO: Implement cases for other relevant seller states
      // case OrderStatus.afterSale: // Or more specific after-sales states
      //   return _buildAfterSaleContent(context);

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
                  Text(AppLocalizations.of(context)!.order_seller_dynamic_delivered, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
               Text(
                 AppLocalizations.of(context)!.order_seller_dynamic_delivered_msg,
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
    print('[SellerDynamicContentArea] Executing _buildOrderCompletedContent.');
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
                  AppLocalizations.of(context)!.order_seller_dynamic_completed,
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
                  AppLocalizations.of(context)!.order_seller_dynamic_canceled,
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
                     Text(AppLocalizations.of(context)!.order_seller_dynamic_refused, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 4),
                     Text(
                      AppLocalizations.of(context)!.order_seller_dynamic_refused_msg,
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

  // TODO: Implement builder methods for other states
  // Widget _buildAfterSaleContent(BuildContext context) { ... }
}

