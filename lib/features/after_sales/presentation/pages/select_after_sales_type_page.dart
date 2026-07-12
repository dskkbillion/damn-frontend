import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

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
        title: Text(AppLocalizations.of(context).after_sales_select_type_title),
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
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(12.0),
      tintColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      tintOpacity: 0.3,
      child: Row(
          children: [
            // Use item.imageUrl
            Container(
              width: 60, height: 60,
              color: AppColors.backgroundSecondary,
              child: item.imageUrl.isNotEmpty
                 ? AppNetworkImage(
                     imageUrl: item.imageUrl,
                     fit: BoxFit.cover,
                     borderRadius: BorderRadius.circular(4.0),
                   )
                 : Icon(Icons.image, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 16),
            // Use item fields for text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.skuName ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${RegionConfig.currencySymbol}${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // Placeholder for the list of selectable types
  Widget _buildTypeSelectionList(BuildContext context) {
    // Get item ID from the widget's orderItem property
    final currentItemId = orderItem.id;
    final s = AppLocalizations.of(context);
    return Column(
      children: [
        _buildTypeTile(
          context,
          icon: Icons.refresh,
          title: s.after_sales_type_remake_title,
          subtitle: s.after_sales_type_remake_subtitle,
          onTap: () {
             print('Selected: REMAKE for item $currentItemId');
             // Pass orderItem as extra
             context.push('/afterSalesApply?itemId=$currentItemId&type=REMAKE', extra: orderItem);
          },
        ),
         _buildTypeTile(
          context,
          icon: Icons.add_box_outlined,
          title: s.after_sales_type_supplement_title,
          subtitle: s.after_sales_type_supplement_subtitle,
           onTap: () {
             print('Selected: SUPPLEMENT for item $currentItemId');
             // Pass orderItem as extra
             context.push('/afterSalesApply?itemId=$currentItemId&type=SUPPLEMENT', extra: orderItem);
          },
        ),
        _buildTypeTile(
          context,
          icon: Icons.currency_exchange,
          title: s.after_sales_type_refund_title,
          subtitle: s.after_sales_type_refund_subtitle,
           onTap: () {
             print('Selected: REFUND for item $currentItemId');
             // Pass orderItem as extra
              context.push('/afterSalesApply?itemId=$currentItemId&type=REFUND', extra: orderItem);
          },
        ),
      ],
    );
  }

  // Helper to build individual type selection tiles
  Widget _buildTypeTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
      return GlassCard(
         margin: const EdgeInsets.only(bottom: 12.0),
         padding: EdgeInsets.zero,
         borderRadius: BorderRadius.circular(12.0),
         tintOpacity: 0.62,
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
