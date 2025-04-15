import 'package:flutter/material.dart';

class OrderStatusSection extends StatelessWidget {
  const OrderStatusSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '我的订单',
            style: TextStyle(
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
                '待付款',
                onTap: () => _navigateToOrders(context, 'pending'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.sync,
                '进行中',
                onTap: () => _navigateToOrders(context, 'processing'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.check_circle_outline,
                '已完成',
                onTap: () => _navigateToOrders(context, 'completed'),
              ),
              _buildOrderStatusItem(
                context,
                Icons.undo,
                '退款/售后',
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
    // TODO: 使用导航服务
    // navigationService.navigateToOrders(status: status);

    // 临时解决方案：显示一个提示，说明导航到特定订单页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导航到$status订单列表')),
    );
  }
}
