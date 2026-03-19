import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

/// 根据订单状态显示【订单列表卡片】可用操作按钮的 Widget。
/// 通过回调函数将事件传递给父 Widget (OrderItemCard)。
class OrderItemCardActionButtons extends StatelessWidget {
  final Order order;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;
  final VoidCallback? onRemindDelivery;
  final VoidCallback? onViewLogistics;
  final VoidCallback? onConfirmReceipt;
  final VoidCallback? onDelete;
  final VoidCallback? onEvaluate;
  final VoidCallback? onApplyAfterSale;
  final VoidCallback? onViewDetails; // Generic view detail action

  const OrderItemCardActionButtons({
    super.key,
    required this.order,
    this.onCancel,
    this.onPay,
    this.onRemindDelivery,
    this.onViewLogistics,
    this.onConfirmReceipt,
    this.onDelete,
    this.onEvaluate,
    this.onApplyAfterSale,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    
    // 判断是否为轻咨询订单
    final isLightConsultation = OrderStatusMapper.isLightConsultationOrder(order);
    
    if (isLightConsultation) {
      // 轻咨询模式：使用简化的按钮
      switch (order.state) {
        case OrderStatus.awaitingPayment:
          if (onCancel != null) buttons.add(_buildButton(context, '取消', onCancel!));
          if (onPay != null) buttons.add(_buildButton(context, '支付', onPay!, isPrimary: true));
          break;
          
        // 待交付状态组（多个状态映射到一个）
        case OrderStatus.awaitingSubmission:
        case OrderStatus.buyAwaitingSubmission:
        case OrderStatus.awaitingStart:
        case OrderStatus.awaitingDelivery:
        case OrderStatus.awaitingConfirmation:
          if (onViewDetails != null) buttons.add(_buildButton(context, '查看', onViewDetails!));
          // 轻咨询模式下不需要"提醒发货"等电商按钮
          break;
          
        case OrderStatus.awaitingEvaluation:
          if (onApplyAfterSale != null) buttons.add(_buildButton(context, '申请售后', onApplyAfterSale!));
          if (onEvaluate != null) buttons.add(_buildButton(context, '评价', onEvaluate!, isPrimary: true));
          break;
          
        case OrderStatus.orderCompleted:
          if (onApplyAfterSale != null) buttons.add(_buildButton(context, '申请售后', onApplyAfterSale!));
          if (onViewDetails != null) buttons.add(_buildButton(context, '查看', onViewDetails!));
          break;
          
        case OrderStatus.applyingForMediation:
        case OrderStatus.afterSale:
        case OrderStatus.AfterSaleRejection:
        case OrderStatus.sellerSupplementaryMaterials:
        case OrderStatus.applyForRefuse:
          if (onViewDetails != null) buttons.add(_buildButton(context, '查看', onViewDetails!));
          // 平台介入状态可能需要联系客服
          break;
          
        case OrderStatus.canceled:
          if (onDelete != null) buttons.add(_buildButton(context, '删除', onDelete!));
          break;
          
        default:
          if (onViewDetails != null) buttons.add(_buildButton(context, '查看', onViewDetails!));
          break;
      }
    } else {
      // 原有复杂模式
      switch (order.state) {
        case OrderStatus.awaitingPayment:
          if (onCancel != null) buttons.add(_buildButton(context, '取消订单', onCancel!));
          if (onPay != null) buttons.add(_buildButton(context, '去支付', onPay!, isPrimary: true));
          break;
        case OrderStatus.awaitingDelivery:
        case OrderStatus.awaitingSubmission:
        case OrderStatus.buyAwaitingSubmission:
        case OrderStatus.awaitingStart:
          if (onRemindDelivery != null) buttons.add(_buildButton(context, '提醒发货', onRemindDelivery!));
          if (onCancel != null) buttons.add(_buildButton(context, '取消订单', onCancel!));
          break;
        case OrderStatus.awaitingConfirmation:
          if (onViewLogistics != null) buttons.add(_buildButton(context, '查看物流', onViewLogistics!));
          if (onConfirmReceipt != null) buttons.add(_buildButton(context, '确认收货', onConfirmReceipt!, isPrimary: true));
          break;
        case OrderStatus.awaitingEvaluation:
          if (onViewLogistics != null) buttons.add(_buildButton(context, '查看物流', onViewLogistics!));
          if (onApplyAfterSale != null) buttons.add(_buildButton(context, '申请售后', onApplyAfterSale!));
          if (onEvaluate != null) buttons.add(_buildButton(context, '去评价', onEvaluate!, isPrimary: true));
          break;
        case OrderStatus.orderCompleted:
        case OrderStatus.canceled:
        case OrderStatus.afterSale:
        case OrderStatus.AfterSaleRejection:
        case OrderStatus.applyingForMediation:
           if (onViewDetails != null) buttons.add(_buildButton(context, '查看详情', onViewDetails!));
           if (onDelete != null) buttons.add(_buildButton(context, '删除订单', onDelete!));
          break;
        default:
          // For unknown or states with no specific actions on list card, maybe show details button
           if (onViewDetails != null) buttons.add(_buildButton(context, '查看详情', onViewDetails!));
          break;
      }
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use the same layout as OrderDetailActionButtons for consistency
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.end,
      children: buttons,
    );
  }

  // Reuse the same button building logic (or extract to a shared utility)
  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed, {bool isPrimary = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    final buttonTextStyle = textTheme.bodyMedium;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    const buttonMinSize = Size(0, 36);

    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
               backgroundColor: colorScheme.primary,
               foregroundColor: colorScheme.onPrimary,
               padding: buttonPadding,
               textStyle: buttonTextStyle,
               shape: buttonShape,
               minimumSize: buttonMinSize,
               elevation: 2,
            ),
            child: Text(text),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              padding: buttonPadding,
              textStyle: buttonTextStyle,
              shape: buttonShape,
              minimumSize: buttonMinSize,
            ),
            child: Text(text),
          );
  }
} 
