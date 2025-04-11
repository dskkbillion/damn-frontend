import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_widget.dart';
// Import the new item card buttons widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card_action_buttons.dart';

/// 用于在订单列表中显示单个订单摘要信息的卡片 Widget。
class OrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap; // 点击卡片的回调 (导航到详情)

  const OrderItemCard({super.key, required this.order, this.onTap});

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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1, // 对应 CSS 的 shadow-sm
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                     // TODO: Connect to OrderListBloc if needed
                     print('[OrderItemCard] Delete order: ${order.id}');
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