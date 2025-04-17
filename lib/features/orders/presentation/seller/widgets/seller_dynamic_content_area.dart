import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasRemarks = order.buyerRemark != null && order.buyerRemark!.isNotEmpty;
    // Assume an attachment field exists - replace with actual field name later
    final List<Map<String, String>> buyerAttachments = []; // Placeholder - GET FROM order.buyerAttachments LATER
    final bool hasAttachments = buyerAttachments.isNotEmpty;

    // Build content sections conditionally
    List<Widget> contentWidgets = [];

    // Section 1: Buyer Remarks
    if (hasRemarks) {
      contentWidgets.add(_buildSectionHeader(context, Icons.notes_rounded, '买家备注'));
      contentWidgets.add(Padding(
         padding: const EdgeInsets.only(top: 8.0, bottom: 16.0), // Add bottom padding
         child: Text(order.buyerRemark!, style: textTheme.bodyMedium),
      ));
    }

    // Section 2: Buyer Attachments (Based on assumed field)
    if (hasAttachments) {
        contentWidgets.add(_buildSectionHeader(context, Icons.attachment_rounded, '买家附件'));
        contentWidgets.addAll(
           buyerAttachments.map((attachment) => _buildAttachmentTile(context, attachment)).toList()
        );
        contentWidgets.add(const SizedBox(height: 8)); // Padding after last attachment
    }

    // If no remarks and no attachments, show nothing for this state in dynamic area
    if (contentWidgets.isEmpty) {
       return const SizedBox.shrink();
    }

    // Combine sections in a Card
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
           children: contentWidgets,
         ),
       ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Helper widget to display a single attachment
  Widget _buildAttachmentTile(BuildContext context, Map<String, String> attachment) {
    final String name = attachment['name'] ?? '未知文件';
    final String? url = attachment['url']; // URL might be null

    return ListTile(
      leading: Icon(Icons.insert_drive_file_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(name, style: Theme.of(context).textTheme.bodyMedium),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      onTap: url != null ? () {
        // TODO: Implement file download/preview functionality using the url
        print('Tapped attachment: $name, URL: $url');
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('查看附件功能待实现: $name')),
          );
        // Example using url_launcher:
        // if (await canLaunchUrl(Uri.parse(url))) {
        //   await launchUrl(Uri.parse(url));
        // } else {
        //   print('Could not launch $url');
        // }
      } : null, // Disable tap if no URL
      trailing: url != null ? const Icon(Icons.download_for_offline_outlined, size: 20) : null,
    );
  }

  /// Builds content for the 'Awaiting Confirmation' state.
  Widget _buildAwaitingConfirmationContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // final sn = order.shippingInfo.logisticsNo; // Remove logisticsNo dependency

    // For service orders, this state means service delivered, awaiting buyer confirmation.
    // Display a generic message for now, until we know how delivery info is stored.
    
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
                  Icon(Icons.task_alt_outlined, size: 20, color: colorScheme.primary), // Use a different icon
                  const SizedBox(width: 8),
                  Text('服务已交付', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
               Text(
                 '您已完成服务交付，请等待买家确认。如有问题，买家可能会发起售后。' ,
                 style: textTheme.bodyMedium,
               ),
              // TODO: Later, display actual delivery content (text, files) if available in Order entity.
              // Remove SN display and copy button
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

  // TODO: Implement builder methods for other states
  // Widget _buildAfterSaleContent(BuildContext context) { ... }
}

