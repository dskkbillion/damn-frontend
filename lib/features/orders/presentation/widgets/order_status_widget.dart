import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';

/// 根据订单状态显示不同文本和样式的 Widget
class OrderStatusWidget extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String statusText;
    Color statusColor;

    // 使用 order_status.dart 中定义的实际枚举值
    switch (status) {
      case OrderStatus.awaitingPayment: // 待付款
        statusText = '待付款';
        statusColor = colorScheme.error;
        break;
      case OrderStatus.awaitingSubmission:
        statusText = '待提交';
        statusColor = Colors.orange;
        break;
      case OrderStatus.buyAwaitingSubmission:
        statusText = '待重传';
        statusColor = Colors.orange;
        break;
      case OrderStatus.awaitingStart:
        statusText = '待接单';
        statusColor = Colors.blue;
        break;
      case OrderStatus.awaitingDelivery: // 待发货
        statusText = '待发货';
        statusColor = Colors.orange;
        break;
      case OrderStatus.awaitingConfirmation: // 待收货
        statusText = '待收货';
        statusColor = colorScheme.primary;
        break;
      case OrderStatus.awaitingEvaluation: // 待评价
        statusText = '待评价';
        statusColor = Colors.green;
        break;
      case OrderStatus.orderCompleted: // 已完成
        statusText = '已完成';
        statusColor = colorScheme.secondary;
        break;
      case OrderStatus.canceled: // 已取消
        statusText = '已取消';
        statusColor = Colors.grey;
        break;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation: // 售后相关状态
        statusText = '售后中'; // 统一显示为售后中？
        statusColor = Colors.blueGrey;
        break;
      // case OrderStatus.sellerSupplementaryMaterials:
      // case OrderStatus.applyForRefuse:
         // 这两个状态含义不明确，暂时归入未知
      case OrderStatus.unknown:
      default:
        statusText = '未知状态';
        statusColor = Colors.grey;
        break;
    }

    return Text(
      statusText,
      style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
    );
  }
} 