import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 根据订单状态显示不同文本和样式的 Widget
class OrderStatusWidget extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String statusText;
    Color statusColor;

    // 使用 order_status.dart 中定义的实际枚举值
    switch (status) {
      case OrderStatus.awaitingPayment: // 待付款
        statusText = l10n.order_status_awaiting_payment;
        statusColor = colorScheme.error;
        break;
      case OrderStatus.awaitingSubmission:
        statusText = l10n.order_status_awaiting_submission;
        statusColor = Colors.orange;
        break;
      case OrderStatus.buyAwaitingSubmission:
        statusText = l10n.order_status_buy_awaiting_submission;
        statusColor = Colors.orange;
        break;
      case OrderStatus.awaitingStart:
        statusText = l10n.order_status_awaiting_start;
        statusColor = Colors.blue;
        break;
      case OrderStatus.awaitingDelivery: // 待发货
        statusText = l10n.order_status_awaiting_delivery;
        statusColor = Colors.orange;
        break;
      case OrderStatus.awaitingConfirmation: // 待收货
        statusText = l10n.order_status_awaiting_confirmation;
        statusColor = colorScheme.primary;
        break;
      case OrderStatus.awaitingEvaluation: // 待评价
        statusText = l10n.order_status_awaiting_evaluation;
        statusColor = Colors.green;
        break;
      case OrderStatus.orderCompleted: // 已完成
        statusText = l10n.order_status_completed;
        statusColor = colorScheme.secondary;
        break;
      case OrderStatus.canceled: // 已取消
        statusText = l10n.order_status_canceled;
        statusColor = Colors.grey;
        break;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation: // 售后相关状态
        statusText = l10n.order_status_after_sale;
        statusColor = Colors.blueGrey;
        break;
      // case OrderStatus.sellerSupplementaryMaterials:
      // case OrderStatus.applyForRefuse:
         // 这两个状态含义不明确，暂时归入未知
      case OrderStatus.unknown:
      default:
        statusText = l10n.order_status_unknown;
        statusColor = Colors.grey;
        break;
    }

    return Text(
      statusText,
      style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
    );
  }
} 