import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/enhanced_order_status_widget.dart';
// Import the new item card buttons widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card_action_buttons.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// 用于在订单列表中显示单个订单摘要信息的卡片 Widget。
class OrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap; // 点击卡片的回调 (导航到详情)

  const OrderItemCard({super.key, required this.order, this.onTap});

  /// 显示取消订单确认对话框 (#325)
  Future<void> _showCancelConfirmationDialog(BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.order_confirm_cancel_title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(l10n.order_confirm_cancel_content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.order_dialog_cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(l10n.order_dialog_confirm),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performCancelOrder(context, order);
              },
            ),
          ],
        );
      },
    );
  }

  /// 执行取消订单操作 (#325) — 与 _performDeleteOrder 同款 OrderDetailBloc 链路
  Future<void> _performCancelOrder(BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context);
    try {
      final orderDetailBloc = getIt<OrderDetailBloc>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.order_card_canceling)),
      );

      late StreamSubscription streamSubscription;
      bool orderLoaded = false;

      streamSubscription = orderDetailBloc.stream.listen((state) {
        if (state is OrderDetailLoaded && !orderLoaded) {
          orderLoaded = true;
          orderDetailBloc.add(OrderActionRequested(
            action: OrderAction.cancel,
            orderId: order.id.toString(),
          ));
        } else if (state is OrderDetailActionSuccess) {
          streamSubscription.cancel();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_canceled),
            ),
          );
          if (context.mounted) {
            final orderListBloc = context.read<OrderListBloc>();
            context.read<OrderListBloc>().add(LoadOrders(status: orderListBloc.currentStatus));
          }
        } else if (state is OrderDetailActionFailure) {
          streamSubscription.cancel();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_cancel_failed(state.message)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is OrderDetailError) {
          streamSubscription.cancel();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_load_detail_failed(state.message)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });

      orderDetailBloc.add(LoadOrderDetail(orderId: order.id));
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.order_card_cancel_failed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// 显示删除订单确认对话框
  Future<void> _showDeleteConfirmationDialog(BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.order_confirm_delete_title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(l10n.order_confirm_delete_content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.order_dialog_cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(l10n.order_dialog_confirm),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performDeleteOrder(context, order);
              },
            ),
          ],
        );
      },
    );
  }

  /// 执行删除订单操作
  Future<void> _performDeleteOrder(BuildContext context, Order order) async {
    final l10n = AppLocalizations.of(context);
    try {
      // 创建一个临时的 OrderDetailBloc 来处理删除操作
      final orderDetailBloc = getIt<OrderDetailBloc>();

      print('[OrderItemCard] 准备删除订单: ${order.id}, 当前状态: ${order.state}');

      // 显示加载状态
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.order_card_deleting)),
      );

      // 创建一个 StreamSubscription 来监听结果
      late StreamSubscription streamSubscription;
      bool orderLoaded = false;
      
      streamSubscription = orderDetailBloc.stream.listen((state) {
        print('[OrderItemCard] 收到BLoC状态变化: ${state.runtimeType}');
        
        if (state is OrderDetailLoaded && !orderLoaded) {
          // 订单详情加载完成，现在可以执行删除操作
          print('[OrderItemCard] 订单详情加载完成，执行删除操作');
          orderLoaded = true;
          orderDetailBloc.add(OrderActionRequested(
            action: OrderAction.delete,
            orderId: order.id.toString(),
          ));
        } else if (state is OrderDetailActionSuccess) {
          print('[OrderItemCard] 删除成功');
          // 取消订阅
          streamSubscription.cancel();
          
          // 删除成功，隐藏加载提示并显示成功消息
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_deleted),
            ),
          );

          // 刷新订单列表，保持当前的筛选状态
          if (context.mounted) {
            final orderListBloc = context.read<OrderListBloc>();
            // 使用当前的状态筛选条件重新加载
            context.read<OrderListBloc>().add(LoadOrders(status: orderListBloc.currentStatus));
          }
        } else if (state is OrderDetailActionFailure) {
          print('[OrderItemCard] 删除失败: ${state.message}');
          // 取消订阅
          streamSubscription.cancel();

          // 删除失败
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_delete_failed(state.message)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is OrderDetailError) {
          print('[OrderItemCard] 加载订单详情失败: ${state.message}');
          // 取消订阅
          streamSubscription.cancel();

          // 加载失败
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.order_card_load_detail_failed(state.message)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });

      // 先加载订单详情
      print('[OrderItemCard] 先加载订单详情');
      orderDetailBloc.add(LoadOrderDetail(orderId: order.id));

    } catch (e) {
      print('[OrderItemCard] 删除操作异常: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.order_card_delete_failed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // 调试日志
    print('[OrderItemCard] Building card for order ${order.id}');
    print('[OrderItemCard] Tenant info - id: ${order.tenant?.id}, nickname: ${order.tenant?.nickname}, shopName: ${order.tenant?.shopName}');
    print('[OrderItemCard] Buyer info - id: ${order.buyer?.id}, nickname: ${order.buyer?.nickname}');

    // 假设 order.items 非空，并且我们显示第一个 item 的信息作为预览
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final displayState = order.displayState;

    // Define the callback for navigating to detail page (used by multiple buttons)
    void navigateToDetail() {
      if (onTap != null) {
        onTap!(); // Use the main onTap callback passed from the list page
      }
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12.0),
      tintOpacity: 0.62,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：卖家信息和订单状态（买家视角）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 显示卖家信息
                  Expanded(
                    child: Row(
                      children: [
                        // 卖家头像
                        if (order.tenant?.avatar != null && order.tenant!.avatar!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(order.tenant!.avatar!),
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              onBackgroundImageError: (_, __) {},
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.store,
                                size: 16,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                        // 卖家昵称
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (order.tenant?.nickname != null && order.tenant!.nickname!.isNotEmpty)
                                Text(
                                  order.tenant!.nickname!,
                                  style: textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (order.tenant?.shopName != null && order.tenant!.shopName!.isNotEmpty)
                                Text(
                                  order.tenant!.shopName!,
                                  style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 使用增强版状态标签，显示倒计时
                  EnhancedOrderStatusWidget(
                    status: displayState,
                    countdownEndTime: displayState == order.state
                        ? _getCountdownEndTime(order)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // 内容：商品图片和基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  if (firstItem?.imageUrl != null && firstItem!.imageUrl.isNotEmpty)
                    AppNetworkImage(
                      imageUrl: firstItem.imageUrl,
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(8.0),
                    )
                  else // 如果没有图片URL，显示占位符
                     Container(
                          width: 80, height: 80,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                        ),
                  const SizedBox(width: 12.0),
                  // 商品详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.productName ?? AppLocalizations.of(context).order_card_product_unknown, // 商品标题
                          style: textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        if (firstItem?.skuName != null && firstItem!.skuName!.isNotEmpty)
                          Text(
                             firstItem.skuName!, // 商品描述/规格
                             style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8.0),
                        Text(
                           // 显示订单总价还是商品单价？原型显示 {orderPrice}
                           // 假设显示订单总价
                          PriceFormatter.format(order.priceSummary.payPrice),
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // 关键信息提示区
              if (_hasImportantInfo(order))
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getInfoBackgroundColor(order, colorScheme),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getInfoIcon(order),
                        size: 14,
                        color: _getInfoColor(order, colorScheme),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getInfoText(order, l10n: AppLocalizations.of(context)),
                          style: textTheme.bodySmall?.copyWith(
                            color: _getInfoColor(order, colorScheme),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(height: 1, color: Theme.of(context).dividerColor), // 分隔线
              const SizedBox(height: 8.0), // Reduced spacing slightly
              // 时间戳单独一行，靠左
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, bottom: 4.0), // Adjust padding as needed
                  child: Text(
                    // TODO: 格式化时间
                    order.createdAt.toString(),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                  ),
                ),
              ),
              // 操作按钮区域 - 使用新的 Widget 和回调
              Align(
                 alignment: Alignment.centerRight,
                 // Use OrderItemCardActionButtons with callbacks
                 child: OrderItemCardActionButtons(
                   order: order,
                   // Navigation actions mostly point to detail for now
                   onPay: navigateToDetail, // Go to detail, which might handle payment trigger
                   onViewLogistics: navigateToDetail,
                   onEvaluate: () {
                     // 直接导航到评价页面
                     if (order.items.isNotEmpty) {
                       final firstItemId = order.items.first.id;
                       context.push('/evaluation/$firstItemId', extra: order.items.first);
                     }
                   },
                   onApplyAfterSale: navigateToDetail,
                   onViewDetails: navigateToDetail,
                   // Actions that modify state (might interact with OrderListBloc later)
                   onCancel: () {
                     _showCancelConfirmationDialog(context, order);
                   },
                   onConfirmReceipt: () {
                     // TODO: Connect to OrderListBloc if needed
                     print('[OrderItemCard] Confirm receipt: ${order.id}');
                   },
                    onRemindDelivery: () {
                     // Show a snackbar directly
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(AppLocalizations.of(context).order_snackbar_reminded_delivery), duration: const Duration(seconds: 2)),
                     );
                     print('[OrderItemCard] Remind delivery: ${order.id}');
                   },
                   onDelete: () {
                     _showDeleteConfirmationDialog(context, order);
                   },
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 判断是否有重要信息需要显示
  bool _hasImportantInfo(Order order) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
        return order.autoCancelTime != null;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return order.autoMaterialTime != null;
      case OrderStatus.awaitingStart:
        return order.autoOrderReceivinTime != null;
      case OrderStatus.awaitingDelivery:
        // 显示交付天数
        final firstItem = order.items.isNotEmpty ? order.items.first : null;
        return firstItem?.deliveryDay != null;
      case OrderStatus.awaitingConfirmation:
        return order.deliveryTimestamp != null;
      case OrderStatus.awaitingEvaluation:
        return order.evaluate == false;
      default:
        return false;
    }
  }
  
  /// 获取信息图标
  IconData _getInfoIcon(Order order) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingConfirmation:
        return Icons.access_time;
      case OrderStatus.awaitingDelivery:
        return Icons.local_shipping;
      case OrderStatus.awaitingEvaluation:
        return Icons.star_border;
      default:
        return Icons.info_outline;
    }
  }
  
  /// 获取信息文本
  String _getInfoText(Order order, {AppLocalizations? l10n}) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
        if (order.autoCancelTime != null) {
          final remaining = order.autoCancelTime!.difference(DateTime.now());
          if (remaining.isNegative) return l10n?.order_card_canceled ?? '';
          return l10n?.order_card_pay_in_time(_formatDuration(remaining)) ?? '';
        }
        break;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        if (order.autoMaterialTime != null) {
          final remaining = order.autoMaterialTime!.difference(DateTime.now());
          if (remaining.isNegative) return l10n?.order_card_timeout_submit ?? '';
          return l10n?.order_card_submit_in_time(_formatDuration(remaining)) ?? '';
        }
        break;
      case OrderStatus.awaitingStart:
        if (order.autoOrderReceivinTime != null) {
          final remaining = order.autoOrderReceivinTime!.difference(DateTime.now());
          if (remaining.isNegative) return l10n?.order_card_seller_timeout ?? '';
          return l10n?.order_card_seller_accept_in_time(_formatDuration(remaining)) ?? '';
        }
        break;
      case OrderStatus.awaitingDelivery:
        final firstItem = order.items.isNotEmpty ? order.items.first : null;
        if (firstItem?.deliveryDay != null) {
          return l10n?.order_card_delivery_days(firstItem!.deliveryDay!) ?? '';
        }
        break;
      case OrderStatus.awaitingConfirmation:
        if (order.deliveryTimestamp != null) {
          // 计算7天后自动确认
          final autoConfirmTime = order.deliveryTimestamp!.add(const Duration(days: 7));
          final remaining = autoConfirmTime.difference(DateTime.now());
          if (remaining.isNegative) return l10n?.order_card_auto_confirm_soon ?? '';
          return l10n?.order_card_auto_confirm_in(_formatDuration(remaining)) ?? '';
        }
        break;
      case OrderStatus.awaitingEvaluation:
        if (order.evaluate == false) {
          return l10n?.order_card_evaluate_for_points ?? '';
        }
        break;
      default:
        break;
    }
    return '';
  }
  
  /// 获取信息背景色
  Color _getInfoBackgroundColor(Order order, ColorScheme colorScheme) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        // 紧急状态使用错误色
        return colorScheme.errorContainer.withOpacity(0.3);
      case OrderStatus.awaitingStart:
        // 待接单使用主色
        return colorScheme.primaryContainer.withOpacity(0.3);
      case OrderStatus.awaitingConfirmation:
      case OrderStatus.awaitingDelivery:
        // 一般提示使用主色
        return colorScheme.primaryContainer.withOpacity(0.3);
      case OrderStatus.awaitingEvaluation:
        // 评价提示使用次要色
        return colorScheme.secondaryContainer.withOpacity(0.3);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
  
  /// 获取信息文字颜色
  Color _getInfoColor(Order order, ColorScheme colorScheme) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return colorScheme.error;
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingConfirmation:
      case OrderStatus.awaitingDelivery:
        return colorScheme.primary;
      case OrderStatus.awaitingEvaluation:
        return colorScheme.secondary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
  
  /// 格式化时间间隔
  String _formatDuration(Duration duration) {
    // Note: These are used as time strings passed into l10n placeholders,
    // so we keep them as simple formatted strings without l10n wrapping here.
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '<1m';
    }
  }
  
  /// 获取倒计时结束时间
  DateTime? _getCountdownEndTime(Order order) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
        return order.autoCancelTime;
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return order.autoMaterialTime;
      case OrderStatus.awaitingStart:
        return order.autoOrderReceivinTime;
      case OrderStatus.awaitingConfirmation:
        // 自动确认收货时间（7天后）
        return order.deliveryTimestamp?.add(const Duration(days: 7));
      default:
        return null;
    }
  }
}
