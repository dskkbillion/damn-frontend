import 'package:flutter/material.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    switch (order.state) {
      case OrderStatus.awaitingPayment:
        if (onCancel != null) buttons.add(_buildButton(context, l10n.order_action_cancel, onCancel!));
        if (onPay != null) buttons.add(_buildButton(context, l10n.order_action_go_pay, onPay!, isPrimary: true));
        break;
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
        if (onRemindDelivery != null) buttons.add(_buildButton(context, l10n.order_action_remind_delivery, onRemindDelivery!));
        if (onCancel != null) buttons.add(_buildButton(context, l10n.order_action_cancel, onCancel!));
        break;
      case OrderStatus.awaitingConfirmation:
        if (onViewLogistics != null) buttons.add(_buildButton(context, l10n.order_action_view_logistics, onViewLogistics!));
        if (onApplyAfterSale != null) buttons.add(_buildButton(context, l10n.order_action_apply_after_sale, onApplyAfterSale!));
        if (onConfirmReceipt != null) buttons.add(_buildButton(context, l10n.order_action_confirm_receipt, onConfirmReceipt!, isPrimary: true));
        break;
      case OrderStatus.awaitingEvaluation:
        if (onViewLogistics != null) buttons.add(_buildButton(context, l10n.order_action_view_logistics, onViewLogistics!));
        if (onApplyAfterSale != null) buttons.add(_buildButton(context, l10n.order_action_apply_after_sale, onApplyAfterSale!));
        if (onEvaluate != null) buttons.add(_buildButton(context, l10n.order_action_go_evaluate, onEvaluate!, isPrimary: true));
        break;
      case OrderStatus.orderCompleted:
        if (onApplyAfterSale != null) buttons.add(_buildButton(context, l10n.order_action_apply_after_sale, onApplyAfterSale!));
        if (onViewDetails != null) buttons.add(_buildButton(context, l10n.order_action_view_details, onViewDetails!));
        if (onDelete != null) buttons.add(_buildButton(context, l10n.order_action_delete_order, onDelete!));
        break;
      case OrderStatus.canceled:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
        if (onViewDetails != null) buttons.add(_buildButton(context, l10n.order_action_view_details, onViewDetails!));
        if (onDelete != null) buttons.add(_buildButton(context, l10n.order_action_delete_order, onDelete!));
        break;
      default:
        // For unknown or states with no specific actions on list card, maybe show details button
         if (onViewDetails != null) buttons.add(_buildButton(context, l10n.order_action_view_details, onViewDetails!));
        break;
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

    const buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
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