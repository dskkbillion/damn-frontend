import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

class OrderStatusSection extends StatelessWidget {
  const OrderStatusSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
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
          Text(
            s.profile_orders,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderStatusItem(
                context,
                Icons.access_time,
                s.profile_pending_payment,
                onTap: () => _navigateToOrders(context, 'pending'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.sync,
                s.profile_in_progress,
                onTap: () => _navigateToOrders(context, 'processing'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.check_circle_outline,
                s.profile_completed,
                onTap: () => _navigateToOrders(context, 'completed'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.undo,
                s.profile_refund,
                onTap: () => _navigateToOrders(context, 'refund'),
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
    final s = S.of(context);
    
    const String basePath = '/orders';
    final String pathWithQuery = '$basePath?status=$status';

    try {
      print('Navigating to: $pathWithQuery');
      context.go(pathWithQuery);
    } catch (e) {
      print('Error navigating to $pathWithQuery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.profile_navigation_error('$e'))),
      );
    }
  }
}
