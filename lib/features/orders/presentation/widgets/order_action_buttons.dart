import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_dialogs.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_button_builder.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

/// 根据订单状态显示【订单详情页】可用操作按钮的 Widget
class OrderDetailActionButtons extends StatelessWidget {
  final Order order;
  final Future<void> Function(Order)? onContactSeller;
  final bool isCreatingChat;

  const OrderDetailActionButtons({
    super.key,
    required this.order,
    this.onContactSeller,
    this.isCreatingChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final dialogs = OrderActionDialogs(order: order);
    final buttons = <Widget>[];
    Widget? primaryButton;

    // 判断是否为轻咨询订单
    final isLightConsultation = OrderStatusMapper.isLightConsultationOrder(order);

    // 轻咨询模式：使用简化的按钮
    if (isLightConsultation) {
      return _buildSimplifiedButtons(context);
    }

    // 原有复杂模式的按钮逻辑
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
        primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final isLoading = state is OrderDetailPaymentLoading;
            return _buildButton(
              context,
              isLoading ? '处理中...' : '去支付',
              isLoading ? null : () {
                context.read<OrderDetailBloc>().add(GoToPayment(orderId: order.id));
              },
              isPrimary: true,
              isLoading: isLoading,
            );
          },
        );
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
          _navigateToPlatformIntervention(context);
        }));
        break;

      case OrderStatus.awaitingConfirmation: // 待收货
        buttons.add(_buildButton(context, '查看交付', () {
          dialogs.showDeliveryDialog(context);
        }));
        buttons.add(_buildButton(context, '平台介入', () {
          _navigateToPlatformIntervention(context);
        }));
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final isLoading = state is OrderDetailActionLoading;
            return _buildButton(
              context,
              isLoading ? '处理中...' : '确认收货',
              isLoading ? null : () {
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
              },
              isPrimary: true,
              isLoading: isLoading,
            );
          },
        );
        break;

      case OrderStatus.awaitingEvaluation: // 待评价
        buttons.add(_buildButton(context, '查看物流', () {
          AppLogger.d('查看物流 for order ${order.id}');
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
          AppLogger.d('查看订单: ${order.id}');
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
    VoidCallback? onPressed,
    {bool isPrimary = false, bool isLoading = false}
  ) {
    return OrderActionButtonBuilder.buildButton(
      context,
      text,
      onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
    );
  }

  void _navigateToAfterSales(BuildContext context) {
    try {
      if (order.items.isNotEmpty) {
        final firstItem = order.items.first;
        final firstItemId = firstItem.id;
        Future.delayed(const Duration(milliseconds: 50), () {
          if (context.mounted) {
            try {
              context.push('/selectAfterSalesType/$firstItemId', extra: firstItem);
              AppLogger.d('Navigate to select after sales type for item ID: $firstItemId');
            } catch (e) {
              AppLogger.d('Error navigating to after sales: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('导航失败: $e')),
                );
              }
            }
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误：无法为没有商品的订单申请售后')),
        );
        AppLogger.d('Error: Cannot apply after sales for order ${order.id} with no items.');
      }
    } catch (e) {
      AppLogger.d('Error in _navigateToAfterSales: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _navigateToEvaluation(BuildContext context) async {
    try {
      final orderId = order.id;
      await Future.delayed(const Duration(milliseconds: 50));
      if (context.mounted) {
        try {
          final result = await context.push<bool>('/evaluation/$orderId', extra: order);
          AppLogger.d('Navigate to evaluation for order ID: $orderId, result: $result');
          // 如果评价成功，刷新订单详情
          if (result == true && context.mounted) {
            context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: orderId));
          }
        } catch (e) {
          AppLogger.d('Error navigating to evaluation: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('导航失败: $e')),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.d('Error in _navigateToEvaluation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  void _navigateToPlatformIntervention(BuildContext context) {
    try {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (context.mounted) {
          try {
            context.push('/platform-intervention/${order.id}', extra: {
              'orderSn': order.orderSn,
            });
            AppLogger.d('Navigate to platform intervention for order ID: ${order.id}');
          } catch (e) {
            AppLogger.d('Error navigating to platform intervention: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('导航失败: $e')),
              );
            }
          }
        }
      });
    } catch (e) {
      AppLogger.d('Error in _navigateToPlatformIntervention: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  /// 轻咨询模式：构建简化的操作按钮
  Widget _buildSimplifiedButtons(BuildContext context) {
    final dialogs = OrderActionDialogs(order: order);
    final buttons = <Widget>[];
    Widget? primaryButton;

    switch (order.state) {
      case OrderStatus.awaitingPayment:
        // 待付款：支付、取消
        buttons.add(_buildButton(context, '取消', () {
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
        primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final isLoading = state is OrderDetailPaymentLoading;
            return _buildButton(
              context,
              isLoading ? '处理中...' : '支付',
              isLoading ? null : () {
                context.read<OrderDetailBloc>().add(GoToPayment(orderId: order.id));
              },
              isPrimary: true,
              isLoading: isLoading,
            );
          },
        );
        break;

      // 待确认收货状态：单独处理，显示确认收货按钮
      case OrderStatus.awaitingConfirmation:
        // 待确认收货：显示确认收货主按钮
        primaryButton = BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final isLoading = state is OrderDetailActionLoading;
            return _buildButton(
              context,
              isLoading ? '处理中...' : '确认收货',
              isLoading ? null : () {
                dialogs.showConfirmationDialog(
                  context: context,
                  title: '确认收货',
                  content: '确认已收到满意的服务吗？',
                  onConfirm: () {
                    context.read<OrderDetailBloc>().add(
                      OrderActionRequested(
                        action: OrderAction.confirmReceipt,
                        orderId: order.id.toString()
                      )
                    );
                  },
                );
              },
              isPrimary: true,
              isLoading: isLoading,
            );
          },
        );
        // 次要按钮：联系顾问
        buttons.add(_buildButton(context, '联系顾问',
          (isCreatingChat || onContactSeller == null)
              ? null
              : () => onContactSeller!(order)));
        break;

      // 其他待交付状态组（服务进行中）
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
        // 咨询进行中：联系顾问
        primaryButton = _buildButton(
          context,
          isCreatingChat ? '连接中...' : '联系顾问',
          (isCreatingChat || onContactSeller == null)
              ? null
              : () => onContactSeller!(order),
          isPrimary: true,
          isLoading: isCreatingChat,
        );
        break;

      case OrderStatus.awaitingEvaluation:
        // 待评价：评价
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        primaryButton = _buildButton(context, '评价', () {
          _navigateToEvaluation(context);
        }, isPrimary: true);
        break;

      case OrderStatus.orderCompleted:
        buttons.add(_buildButton(context, '申请售后', () {
          _navigateToAfterSales(context);
        }));
        // 已完成：再次咨询（进入与卖家的聊天室）
        primaryButton = _buildButton(
          context,
          isCreatingChat ? '连接中...' : '再次咨询',
          (isCreatingChat || onContactSeller == null)
              ? null
              : () => onContactSeller!(order),
          isPrimary: true,
          isLoading: isCreatingChat,
        );
        break;

      case OrderStatus.applyingForMediation:
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
        // 平台介入：联系客服
        primaryButton = _buildButton(context, '联系客服', () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('正在连接客服...')),
          );
        }, isPrimary: true);
        break;

      case OrderStatus.canceled:
        // 已取消：删除订单
        primaryButton = _buildButton(context, '删除订单', () {
          dialogs.showConfirmationDialog(
            context: context,
            title: '删除订单',
            content: '您确定要删除这个订单吗？',
            onConfirm: () {
              context.read<OrderDetailBloc>().add(
                OrderActionRequested(
                  action: OrderAction.delete,
                  orderId: order.id.toString(),
                ),
              );
            },
          );
        }, isPrimary: true);
        break;

      default:
        break;
    }

    // 构建底部操作栏
    if (buttons.isEmpty && primaryButton == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...buttons.map((button) => Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
            child: button,
          )),
          if (primaryButton != null) Expanded(child: primaryButton),
        ],
      ),
    );
  }
}
