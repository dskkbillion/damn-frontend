import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_dialogs.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_button_builder.dart';

/// 根据订单状态显示【订单详情页】可用操作按钮的 Widget
class OrderDetailActionButtons extends StatelessWidget {
  final Order order;

  const OrderDetailActionButtons({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final dialogs = OrderActionDialogs(order: order);
    final buttons = <Widget>[];
    Widget? primaryButton;

    // 使用 order_status.dart 中定义的实际枚举值
    switch (order.state) {
      case OrderStatus.awaitingPayment: // 待付款
        buttons.add(_buildButton(context, '取消订单', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '取消订单',
            content: '您确定要取消这个订单吗？',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.cancel, 
                  orderId: order.id.toString()
                )
              );
            },
          );
        }));
        primaryButton = _buildButton(context, '去支付', () {
          context.read<OrderDetailBloc>().add(GoToPayment(orderId: order.id));
        }, isPrimary: true);
        break;

      // 待提交状态 - 需要提交材料
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        primaryButton = _buildButton(context, '提交材料', () {
          dialogs.showRequirementSubmissionDialog(context);
        }, isPrimary: true);
        buttons.add(_buildButton(context, '联系客服', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('正在连接客服...')),
          );
        }));
        if (order.state == OrderStatus.buyAwaitingSubmission) {
          // 如果是材料重传状态，显示查看反馈按钮
          buttons.add(_buildButton(context, '查看反馈', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('查看卖家反馈功能开发中')),
            );
          }));
        }
        buttons.add(_buildButton(context, '取消订单', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '取消订单',
            content: '您确定要取消这个订单吗？',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.cancel, 
                  orderId: order.id.toString()
                )
              );
            },
          );
        }));
        break;
      
      // 待发货/待交付，允许提醒和平台介入
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingStart:
        buttons.add(_buildButton(context, '提醒发货', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已提醒卖家发货'))
          );
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          dialogs.showPlatformInterventionDialog(context);
        }));
        break;

      case OrderStatus.awaitingConfirmation: // 待收货
        buttons.add(_buildButton(context, '查看交付', () {
          dialogs.showDeliveryDialog(context);
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          dialogs.showPlatformInterventionDialog(context);
        }));
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        primaryButton = _buildButton(context, '确认收货', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '确认收货',
            content: '您确定已经收到货品，并确认收货吗？',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.confirmReceipt, 
                  orderId: order.id.toString()
                )
              );
            },
          );
        }, isPrimary: true);
        break;

      case OrderStatus.awaitingEvaluation: // 待评价
        buttons.add(_buildButton(context, '查看物流', () {
          print('查看物流 for order ${order.id}');
        }));
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        primaryButton = _buildButton(context, '去评价', () {
          _navigateToEvaluation(context);
        }, isPrimary: true);
        break;

      case OrderStatus.orderCompleted: // 已完成
        buttons.add(_buildButton(context, '申请重做', () {
          dialogs.showOrderDemandDialog(context, 'reform');
        }));
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        buttons.add(_buildButton(context, '删除订单', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '删除订单',
            content: '您确定要删除这个订单吗？删除后将无法恢复。',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.delete, 
                  orderId: order.id.toString()
                )
              );
            },
          );
        }));
        break;

      case OrderStatus.canceled: // 已取消
      case OrderStatus.afterSale: // 售后处理中
      case OrderStatus.AfterSaleRejection: // 售后被拒
      case OrderStatus.applyingForMediation: // 平台介入中
        buttons.add(_buildButton(context, '查看订单', () {
          print('查看订单: ${order.id}');
        }));
        buttons.add(_buildButton(context, '删除订单', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '删除订单',
            content: '您确定要删除这个订单吗？删除后将无法恢复。',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.delete, 
                  orderId: order.id.toString()
                )
              );
            },
          );
        }));
        break;

      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
      case OrderStatus.unknown:
        break;
    }

    // 如果没有按钮，不显示
    if (buttons.isEmpty && primaryButton == null) {
      return const SizedBox.shrink();
    }

    // 将主要按钮添加到列表中
    if (primaryButton != null) {
      buttons.add(primaryButton);
    }

    return OrderActionButtonBuilder.buildResponsiveButtonLayout(buttons);
  }

  Widget _buildButton(
    BuildContext context, 
    String text, 
    VoidCallback onPressed, 
    {bool isPrimary = false}
  ) {
    return OrderActionButtonBuilder.buildButton(
      context, 
      text, 
      onPressed, 
      isPrimary: isPrimary
    );
  }

  void _navigateToAfterSales(BuildContext context) {
    if (order.items.isNotEmpty) {
      final firstItem = order.items.first;
      final firstItemId = firstItem.id;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (context.mounted) {
          context.push('/selectAfterSalesType/$firstItemId', extra: firstItem);
          print('Navigate to select after sales type for item ID: $firstItemId');
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
      );
      print('Error: Cannot apply after sales for order ${order.id} with no items.');
    }
  }

  void _navigateToEvaluation(BuildContext context) {
    if (order.items.isNotEmpty) {
      final firstItem = order.items.first;
      final firstItemId = firstItem.id;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (context.mounted) {
          context.push('/evaluation/$firstItemId', extra: firstItem);
          print('Navigate to evaluation for item ID: $firstItemId');
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('错误：无法为没有商品的订单进行评价')),
      );
      print('Error: Cannot evaluate order ${order.id} with no items.');
    }
  }
}