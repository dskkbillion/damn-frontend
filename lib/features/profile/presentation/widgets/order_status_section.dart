import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

class OrderStatusSection extends StatelessWidget {
  const OrderStatusSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.profile_orders,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToAllOrders(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderStatusItem(
                context,
                Icons.access_time,
                appLocalizations.profile_pending_payment,
                onTap: () => _navigateToOrders(context, 'awaitingPayment'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.edit_note,
                appLocalizations.profile_in_progress,
                onTap: () => _navigateToOrders(context, 'awaitingSubmission'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.local_shipping_outlined,
                appLocalizations.profile_completed,
                onTap: () => _navigateToOrders(context, 'awaitingConfirmation'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.undo,
                appLocalizations.profile_refund,
                onTap: () => _navigateToOrders(context, 'afterSale'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(
    BuildContext context,
    IconData icon,
    String text, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrders(BuildContext context, String status) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    const String basePath = '/profile/orders';
    final String pathWithQuery = '$basePath?status=$status';

    try {
      AppLogger.d('Navigating to: $pathWithQuery');
      context.go(pathWithQuery);
    } catch (e) {
      AppLogger.d('Error navigating to $pathWithQuery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.profile_navigation_error('$e'))),
      );
    }
  }

  void _navigateToAllOrders(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    const String basePath = '/profile/orders';

    try {
      AppLogger.d('Navigating to all orders: $basePath');
      context.go(basePath);
    } catch (e) {
      AppLogger.d('Error navigating to $basePath: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.profile_navigation_error('$e'))),
      );
    }
  }
}
