import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_widget.dart';
// Import the new item card buttons widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card_action_buttons.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';

/// 用于在订单列表中显示单个订单摘要信息的卡片 Widget。
class OrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap; // 点击卡片的回调 (导航到详情)

  const OrderItemCard({super.key, required this.order, this.onTap});

  /// 显示删除订单确认对话框
  Future<void> _showDeleteConfirmationDialog(BuildContext context, Order order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('删除订单'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('您确定要删除这个订单吗？删除后将无法恢复。'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('确定'),
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
    try {
      // 创建一个临时的 OrderDetailBloc 来处理删除操作
      final orderDetailBloc = getIt<OrderDetailBloc>();
      
      print('[OrderItemCard] 准备删除订单: ${order.id}, 当前状态: ${order.state}');
      
      // 显示加载状态
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在删除订单...')),
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
            const SnackBar(
              content: Text('订单已删除'),
              backgroundColor: Colors.green,
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
              content: Text('删除失败：${state.message}'),
              backgroundColor: Colors.red,
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
              content: Text('加载订单详情失败：${state.message}'),
              backgroundColor: Colors.red,
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
          content: Text('删除失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // 假设 order.items 非空，并且我们显示第一个 item 的信息作为预览
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    // Define the callback for navigating to detail page (used by multiple buttons)
    VoidCallback navigateToDetail = () {
      if (onTap != null) {
        onTap!(); // Use the main onTap callback passed from the list page
      }
    };

    return Card(
      // 使用 Card 来获得圆角、阴影和白色背景，符合原型风格
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0, // 无阴影，更简洁
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.3), // 淡边框
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：卖家信息和订单状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TODO: 显示卖家信息 (原型中有 sellerName, sellerId, 需要确认 Order 实体是否有相应字段)
                  Text(
                    '卖家: 店铺名称', // 占位符
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                  ),
                  OrderStatusWidget(status: order.state), // 显示订单状态
                ],
              ),
              const SizedBox(height: 12.0),
              // 内容：商品图片和基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  if (firstItem?.imageUrl != null && firstItem!.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        firstItem.imageUrl,
                        width: 80, height: 80,
                        fit: BoxFit.cover,
                        // 可以添加加载和错误处理
                        loadingBuilder: (context, child, loadingProgress) {
                           if (loadingProgress == null) return child;
                           return Container(
                             width: 80, height: 80,
                             color: Colors.grey[200],
                             child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                           );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80, height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, color: Colors.grey[400]),
                        ),
                      ),
                    )
                  else // 如果没有图片URL，显示占位符
                     Container(
                          width: 80, height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                  const SizedBox(width: 12.0),
                  // 商品详情
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.productName ?? '商品名称未知', // 商品标题
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
                          '¥${order.priceSummary.payPrice.toStringAsFixed(2)}',
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Divider(height: 1, color: Colors.grey[200]), // 分隔线
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
                   onEvaluate: navigateToDetail,
                   onApplyAfterSale: navigateToDetail,
                   onViewDetails: navigateToDetail,
                   // Actions that modify state (might interact with OrderListBloc later)
                   onCancel: () {
                     // TODO: Connect to OrderListBloc if needed for immediate UI update
                     print('[OrderItemCard] Cancel order: ${order.id}');
                   },
                   onConfirmReceipt: () {
                     // TODO: Connect to OrderListBloc if needed
                     print('[OrderItemCard] Confirm receipt: ${order.id}');
                   },
                    onRemindDelivery: () {
                     // Show a snackbar directly
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('已提醒卖家发货'), duration: Duration(seconds: 2)),
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
} 