import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';

/// 根据订单状态显示【订单详情页】可用操作按钮的 Widget
class OrderDetailActionButtons extends StatelessWidget {
  final Order order;
  // TODO: 添加按钮点击的回调函数，例如 onCancel, onConfirmReceipt, onDelete 等

  const OrderDetailActionButtons({
    super.key,
    required this.order,
  });

  // --- Helper function for confirmation dialog ---
  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView( // Use SingleChildScrollView in case content is long
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                onConfirm(); // Execute the confirmation action
              },
            ),
          ],
        );
      },
    );
  }
  // --- End Helper function ---

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    // 使用 order_status.dart 中定义的实际枚举值
    switch (order.state) {
      case OrderStatus.awaitingPayment: // 待付款
        buttons.add(_buildButton(context, '取消订单', () {
           _showConfirmationDialog(
             context: context,
             title: '取消订单',
             content: '您确定要取消这个订单吗？',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.cancel, orderId: order.id.toString()));
             },
           );
        }));
        buttons.add(_buildButton(context, '去支付', () {
          context.read<OrderDetailBloc>().add(GoToPayment(orderId: order.id));
        }, isPrimary: true));
        break;
      // 待发货/待交付，允许取消和提醒
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
        buttons.add(_buildButton(context, '提醒发货', () {
          // TODO: Implement reminder logic (if any) - maybe a snackbar?
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已提醒卖家发货')));
        }));
        buttons.add(_buildButton(context, '取消订单', () { // 假设这些状态可以取消
           _showConfirmationDialog(
             context: context,
             title: '取消订单',
             content: '您确定要取消这个订单吗？',
             onConfirm: () {
                // Use correct parameter name 'action'
                context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.cancel, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.awaitingConfirmation: // 待收货
        buttons.add(_buildButton(context, '查看物流', () {
           context.read<OrderDetailBloc>().add(GoToTracking(orderId: order.id));
        }));
        buttons.add(_buildButton(context, '确认收货', () {
           // Call the confirmation dialog
          _showConfirmationDialog(
            context: context,
            title: '确认收货',
            content: '您确定已经收到货品，并确认收货吗？',
            onConfirm: () {
              // Use correct parameter name 'action'
              context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.confirmReceipt, orderId: order.id.toString()));
            },
          );
        }, isPrimary: true));
        break;
      case OrderStatus.awaitingEvaluation: // 待评价
         buttons.add(_buildButton(context, '查看物流', () {
           // TODO: Implement tracking navigation or show modal
           print('查看物流 for order ${order.id}');
           // Example: context.go('/tracking/${order.id}');
        }));
        buttons.add(_buildButton(context, '申请售后', () {
           if (order.items.isNotEmpty) {
             final firstItem = order.items.first; // Get the first item
             final firstItemId = firstItem.id;
             Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                   // Pass the OrderItem object via the 'extra' parameter
                   context.go('/selectAfterSalesType/$firstItemId', extra: firstItem);
                   print('Navigate to select after sales type for item ID: $firstItemId, passing item data (after delay)');
                }
             });
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
             );
             print('Error: Cannot apply after sales for order ${order.id} with no items.');
           }
        }));
        buttons.add(_buildButton(context, '去评价', () {
           // TODO: Implement navigation to evaluation page or show modal
           print('去评价 for order ${order.id}');
           // Example: context.go('/evaluate/${order.id}');
           // For now, just adding the existing event might be okay if it handles showing the form
            context.read<OrderDetailBloc>().add(GoToEvaluation(orderId: order.id));
        }, isPrimary: true));
        break;
      case OrderStatus.orderCompleted: // 已完成
         buttons.add(_buildButton(context, '申请售后', () {
           if (order.items.isNotEmpty) {
             final firstItem = order.items.first; // Get the first item
             final firstItemId = firstItem.id;
             Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                  // Pass the OrderItem object via the 'extra' parameter
                  context.go('/selectAfterSalesType/$firstItemId', extra: firstItem);
                  print('Navigate to select after sales type for item ID: $firstItemId, passing item data (after delay)');
                }
             });
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
             );
             print('Error: Cannot apply after sales for order ${order.id} with no items.');
           }
        }));
         buttons.add(_buildButton(context, '删除订单', () {
           _showConfirmationDialog(
             context: context,
             title: '删除订单',
             content: '您确定要删除这个订单吗？删除后将无法恢复。',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.delete, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.canceled: // 已取消
      case OrderStatus.afterSale: // 售后处理中 (通常不允许再申请)
      case OrderStatus.AfterSaleRejection: // 售后被拒 (是否允许再次申请? 业务决定, 暂时不加)
      case OrderStatus.applyingForMediation: // 平台介入中 (通常不允许再申请)
         buttons.add(_buildButton(context, '查看订单', () {
           // Just ensure detail page is loaded, no specific action needed?
           print('查看订单: ${order.id}');
         }));
        buttons.add(_buildButton(context, '删除订单', () {
           _showConfirmationDialog(
             context: context,
             title: '删除订单',
             content: '您确定要删除这个订单吗？删除后将无法恢复。',
             onConfirm: () {
               // Use correct parameter name 'action'
               context.read<OrderDetailBloc>().add(OrderActionRequested(action: OrderAction.delete, orderId: order.id.toString()));
             },
           );
        }));
        break;
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.unknown:
      default:
        break;
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.end,
      children: buttons,
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed, {bool isPrimary = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Define common style elements
    final buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10); // Increased padding
    final buttonTextStyle = textTheme.bodyMedium; // Use bodyMedium for better readability
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)); // Slightly less rounded
    const buttonMinSize = Size(0, 36); // Slightly taller minimum height

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
               elevation: 2, // Add slight elevation
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