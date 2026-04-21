import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/data/datasources/simple_mock_order_data_source.dart';
import 'package:dskk_flutter_refactor/core/config/app_config.dart';

/// Mock订单预览页面
/// 用于快速预览各种状态的订单详情页
class MockOrdersPreviewPage extends StatelessWidget {
  const MockOrdersPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 自动启用mock模式
    if (!AppConfig.useMockData) {
      AppConfig.enableMockMode();
    }
    
    final mockOrders = SimpleMockOrderDataSource.getAllMockOrders();
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mock订单预览'),
            Text(
              'Mock模式: ${AppConfig.useMockData ? "已启用" : "未启用"}',
              style: TextStyle(fontSize: 12, color: AppConfig.useMockData ? Colors.green : Colors.red),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '订单详情页预览',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击下方任意订单状态，预览对应的订单详情页',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 按状态分组显示订单
          _buildStatusSection(context, '待付款订单', OrderStatus.awaitingPayment, mockOrders),
          _buildStatusSection(context, '待提交订单', OrderStatus.awaitingSubmission, mockOrders),
          _buildStatusSection(context, '待开始订单', OrderStatus.awaitingStart, mockOrders),
          _buildStatusSection(context, '待发货订单', OrderStatus.awaitingDelivery, mockOrders),
          _buildStatusSection(context, '待确认订单', OrderStatus.awaitingConfirmation, mockOrders),
          _buildStatusSection(context, '待评价订单', OrderStatus.awaitingEvaluation, mockOrders),
          _buildStatusSection(context, '已完成订单', OrderStatus.orderCompleted, mockOrders),
          _buildStatusSection(context, '已取消订单', OrderStatus.canceled, mockOrders),
          _buildStatusSection(context, '售后订单', OrderStatus.afterSale, mockOrders),
          
          const SizedBox(height: 32),
          
          // 快捷测试区
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        '快捷测试',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 支付结果页面测试
                  ListTile(
                    leading: const Icon(Icons.payment, color: Colors.green),
                    title: const Text('支付成功页面'),
                    subtitle: const Text('测试支付成功后的结果页'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/payment/result?success=true&orderId=1001');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.payment, color: Colors.red),
                    title: const Text('支付失败页面'),
                    subtitle: const Text('测试支付失败后的结果页'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/payment/result?success=false&errorMessage=支付失败测试');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.purple),
                    title: const Text('简化测试页面'),
                    subtitle: const Text('测试订单数据直接显示（不通过Bloc）'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/test/order/1001');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusSection(
    BuildContext context, 
    String title, 
    OrderStatus status, 
    List<dynamic> allOrders,
  ) {
    final orders = allOrders.where((order) => order.state == status).toList();
    if (orders.isEmpty) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 20,
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
          ...orders.map((order) => Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.2),
                  child: Text(
                    '${order.id}',
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(order.items.first.productName),
                subtitle: Text(
                  '订单号: ${order.orderSn}\n金额: ¥${order.priceSummary.payPrice.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 跳转到订单详情页
                  context.push('/orderDetail/${order.id}');
                },
              ),
              if (orders.last != order) Divider(height: 1, color: Colors.grey[200]),
            ],
          )),
        ],
      ),
    );
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return Colors.orange;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return Colors.blue;
      case OrderStatus.awaitingStart:
        return Colors.indigo;
      case OrderStatus.awaitingDelivery:
        return Colors.purple;
      case OrderStatus.awaitingConfirmation:
        return Colors.teal;
      case OrderStatus.awaitingEvaluation:
        return Colors.amber;
      case OrderStatus.orderCompleted:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.grey;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingPayment:
        return Icons.payment;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return Icons.upload_file;
      case OrderStatus.awaitingStart:
        return Icons.play_circle_outline;
      case OrderStatus.awaitingDelivery:
        return Icons.local_shipping;
      case OrderStatus.awaitingConfirmation:
        return Icons.check_circle_outline;
      case OrderStatus.awaitingEvaluation:
        return Icons.star_outline;
      case OrderStatus.orderCompleted:
        return Icons.done_all;
      case OrderStatus.canceled:
        return Icons.cancel;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
        return Icons.support_agent;
      default:
        return Icons.help_outline;
    }
  }
}