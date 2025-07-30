import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

// Import OrderItem entity using the correct path
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';

/// 页面：让用户选择要发起的售后类型
class SelectAfterSalesTypePage extends StatelessWidget {
  // Changed parameter: Receive the full OrderItem object
  final OrderItem orderItem;

  const SelectAfterSalesTypePage({
    super.key,
    required this.orderItem, // Changed constructor parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择售后类型'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section 1 - Display Order Item Info (Uses passed item)
            _buildOrderItemInfo(context, orderItem),
            const SizedBox(height: 24.0),

            // Section 2 - Selectable After-Sales Types
            _buildTypeSelectionList(context),
          ],
        ),
      ),
    );
  }

  // Method now accepts OrderItem and uses its data
  Widget _buildOrderItemInfo(BuildContext context, OrderItem item) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Use item.imageUrl
            Container(
              width: 60, height: 60,
              color: Colors.grey[300],
              child: item.imageUrl.isNotEmpty
                 ? ClipRRect(
                     borderRadius: BorderRadius.circular(4.0), // Add slight rounding
                     child: Image.network(item.imageUrl, fit: BoxFit.cover,
                       errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey[500]),
                       loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                     ),
                   )
                 : Icon(Icons.image, color: Colors.grey[500]),
            ),
            const SizedBox(width: 16),
            // Use item fields for text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.skuName ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('¥${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for the list of selectable types
  Widget _buildTypeSelectionList(BuildContext context) {
    // Get item ID from the widget's orderItem property
    final currentItemId = orderItem.id;
    return Column(
      children: [
        _buildTypeTile(
          context,
          icon: Icons.refresh,
          title: '我要重新制作',
          subtitle: '对收到的制作不满意，可与作者协商重做',
          onTap: () {
             print('Selected: 重新制作 for item $currentItemId');
             // Pass orderItem as extra
             context.push('/afterSalesApply?itemId=$currentItemId&type=REMAKE', extra: orderItem);
          },
        ),
         _buildTypeTile(
          context,
          icon: Icons.add_box_outlined,
          title: '我要补充',
          subtitle: '收到的制作不完善，可与作者协商补充',
           onTap: () {
             print('Selected: 补充 for item $currentItemId');
             // Pass orderItem as extra
             context.push('/afterSalesApply?itemId=$currentItemId&type=SUPPLEMENT', extra: orderItem);
          },
        ),
        _buildTypeTile(
          context,
          icon: Icons.currency_exchange,
          title: '我要退款',
          subtitle: '协商退款',
           onTap: () {
             print('Selected: 退款 for item $currentItemId');
             // Pass orderItem as extra
              context.push('/afterSalesApply?itemId=$currentItemId&type=REFUND', extra: orderItem);
          },
        ),
      ],
    );
  }

  // Helper to build individual type selection tiles
  Widget _buildTypeTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
      return Card(
         margin: const EdgeInsets.only(bottom: 12.0),
         child: ListTile(
           leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
           title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
           subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
           trailing: const Icon(Icons.chevron_right),
           onTap: onTap,
         ),
      );
  }

} 