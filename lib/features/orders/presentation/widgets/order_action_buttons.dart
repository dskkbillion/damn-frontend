import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_dialogs.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_button_builder.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    // 使用 order_status.dart 中定义的实际枚举值
    switch (order.state) {
      case OrderStatus.awaitingPayment: // 待付款
        // #374 超时未付款订单：后端 autoCancel 已生效但状态尚未刷新到 canceled 时，
        // 不再渲染「取消订单 / 去支付」按钮（与列表页 order_item_card_action_buttons.dart 同款守卫）。
        final isTimedOut = order.autoCancelTime != null &&
            order.autoCancelTime!.isBefore(DateTime.now());
        if (!isTimedOut) {
          buttons.add(_buildButton(context, l10n.order_action_cancel, () {
            dialogs.showConfirmationDialog(
              context: context,
              title: l10n.order_confirm_cancel_title,
              content: l10n.order_confirm_cancel_content,
              onConfirm: () {
                context.read<OrderDetailBloc>().add(OrderActionRequested(
                    action: OrderAction.cancel, orderId: order.id.toString()));
              },
            );
          }));
          primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              final isLoading = state is OrderDetailPaymentLoading;
              return _buildButton(
                context,
                isLoading
                    ? l10n.order_action_processing
                    : l10n.order_action_go_pay,
                isLoading
                    ? null
                    : () {
                        context
                            .read<OrderDetailBloc>()
                            .add(GoToPayment(orderId: order.id));
                      },
                isPrimary: true,
                isLoading: isLoading,
              );
            },
          );
        }
        break;

      // 待提交状态 - 需要提交材料
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        primaryButton =
            _buildButton(context, l10n.order_action_submit_materials, () {
          dialogs.showRequirementSubmissionDialog(context);
        }, isPrimary: true);
        buttons
            .add(_buildButton(context, l10n.order_action_contact_support, () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.order_snackbar_connecting_support)),
          );
        }));
        if (order.state == OrderStatus.buyAwaitingSubmission) {
          // 如果是材料重传状态，显示查看反馈按钮
          buttons
              .add(_buildButton(context, l10n.order_action_view_feedback, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.order_snackbar_feedback_in_progress)),
            );
          }));
        }
        buttons.add(_buildButton(context, l10n.order_action_cancel, () {
          dialogs.showConfirmationDialog(
            context: context,
            title: l10n.order_confirm_cancel_title,
            content: l10n.order_confirm_cancel_content,
            onConfirm: () {
              context.read<OrderDetailBloc>().add(OrderActionRequested(
                  action: OrderAction.cancel, orderId: order.id.toString()));
            },
          );
        }));
        break;

      // 待发货/待交付，允许提醒发货
      // #375 关联：平台介入(applyingForMediation)为 disabled 功能，且正确触发应基于
      // 售后单(refundId)而非订单(order.id)，移除从订单详情直接跳转的错误入口。
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingStart:
        buttons
            .add(_buildButton(context, l10n.order_action_remind_delivery, () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.order_snackbar_reminded_delivery)));
        }));
        break;

      case OrderStatus.awaitingConfirmation: // 待收货
        buttons.add(_buildButton(context, l10n.order_action_view_delivery, () {
          dialogs.showDeliveryDialog(context);
        }));
        // #375 关联：移除「平台介入」错误入口（disabled 功能 + 应基于 refundId 而非 order.id）
        buttons
            .add(_buildButton(context, l10n.order_action_apply_after_sale, () {
          _navigateToAfterSales(context);
        }));
        primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final isLoading = state is OrderDetailActionLoading;
            return _buildButton(
              context,
              isLoading
                  ? l10n.order_action_processing
                  : l10n.order_action_confirm_receipt,
              isLoading
                  ? null
                  : () {
                      dialogs.showConfirmationDialog(
                        context: context,
                        title: l10n.order_confirm_receipt_title,
                        content: l10n.order_confirm_receipt_content,
                        onConfirm: () {
                          context.read<OrderDetailBloc>().add(
                              OrderActionRequested(
                                  action: OrderAction.confirmReceipt,
                                  orderId: order.id.toString()));
                        },
                      );
                    },
              isPrimary: true,
              isLoading: isLoading,
            );
          },
        );
        break;

      case OrderStatus.awaitingEvaluation: // 待评价
        buttons.add(_buildButton(context, l10n.order_action_view_logistics, () {
          print('查看物流 for order ${order.id}');
        }));
        buttons
            .add(_buildButton(context, l10n.order_action_apply_after_sale, () {
          _navigateToAfterSales(context);
        }));
        primaryButton =
            _buildButton(context, l10n.order_action_go_evaluate, () {
          _navigateToEvaluation(context);
        }, isPrimary: true);
        break;

      case OrderStatus.orderCompleted: // 已完成
        buttons.add(_buildButton(context, l10n.order_action_apply_rework, () {
          dialogs.showOrderDemandDialog(context, 'reform');
        }));
        buttons
            .add(_buildButton(context, l10n.order_action_apply_after_sale, () {
          _navigateToAfterSales(context);
        }));
        buttons.add(_buildButton(context, l10n.order_action_delete_order, () {
          dialogs.showConfirmationDialog(
            context: context,
            title: l10n.order_confirm_delete_title,
            content: l10n.order_confirm_delete_content,
            onConfirm: () {
              context.read<OrderDetailBloc>().add(OrderActionRequested(
                  action: OrderAction.delete, orderId: order.id.toString()));
            },
          );
        }));
        break;

      case OrderStatus.canceled: // 已取消
      case OrderStatus.afterSale: // 售后处理中
      case OrderStatus.AfterSaleRejection: // 售后被拒
      case OrderStatus.applyingForMediation: // 平台介入中
        buttons.add(_buildButton(context, l10n.order_action_view_order, () {
          print('查看订单: ${order.id}');
        }));
        buttons.add(_buildButton(context, l10n.order_action_delete_order, () {
          dialogs.showConfirmationDialog(
            context: context,
            title: l10n.order_confirm_delete_title,
            content: l10n.order_confirm_delete_content,
            onConfirm: () {
              context.read<OrderDetailBloc>().add(OrderActionRequested(
                  action: OrderAction.delete, orderId: order.id.toString()));
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
      BuildContext context, String text, VoidCallback? onPressed,
      {bool isPrimary = false, bool isLoading = false}) {
    return OrderActionButtonBuilder.buildButton(
      context,
      text,
      onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
    );
  }

  void _navigateToAfterSales(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    try {
      if (order.items.isNotEmpty) {
        final firstItem = order.items.first;
        final firstItemId = firstItem.id;
        Future.delayed(const Duration(milliseconds: 50), () {
          if (context.mounted) {
            try {
              context.push('/selectAfterSalesType/$firstItemId',
                  extra: firstItem);
              print(
                  'Navigate to select after sales type for item ID: $firstItemId');
            } catch (e) {
              print('Error navigating to after sales: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(l10n.order_snackbar_nav_failed(e.toString()))),
                );
              }
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.order_snackbar_no_items_after_sale)),
        );
        print(
            'Error: Cannot apply after sales for order ${order.id} with no items.');
      }
    } catch (e) {
      print('Error in _navigateToAfterSales: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.order_snackbar_operation_failed(e.toString()))),
      );
    }
  }

  void _navigateToEvaluation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    try {
      if (order.items.isNotEmpty) {
        final firstItem = order.items.first;
        Future.delayed(const Duration(milliseconds: 50), () {
          if (context.mounted) {
            try {
              context.push('/evaluation/${order.id}', extra: firstItem);
              print('Navigate to evaluation for order ID: ${order.id}');
            } catch (e) {
              print('Error navigating to evaluation: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(l10n.order_snackbar_nav_failed(e.toString()))),
                );
              }
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.order_snackbar_no_items_evaluate)),
        );
        print('Error: Cannot evaluate order ${order.id} with no items.');
      }
    } catch (e) {
      print('Error in _navigateToEvaluation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.order_snackbar_operation_failed(e.toString()))),
      );
    }
  }

  // #375 关联：原 _navigateToPlatformIntervention 方法已随「平台介入」入口移除而删除
  // （平台介入为 disabled 功能，正确触发应基于售后单 refundId 而非订单 order.id）。
}
