import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_widget.dart';
// Import the new seller buttons widget
import 'seller_order_item_card_action_buttons.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

/// 用于在**卖家**订单列表中显示单个订单摘要信息的卡片 Widget。
class SellerOrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap; // 点击卡片的回调 (导航到详情)
  final bool hasBuyerMaterials; // 是否有买家提供的材料

  const SellerOrderItemCard({super.key, required this.order, this.onTap, this.hasBuyerMaterials = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    // 调试日志
    print('[SellerOrderItemCard] Building card for order ${order.id}');
    print('[SellerOrderItemCard] Buyer info - id: ${order.buyer?.id}, nickname: ${order.buyer?.nickname}');
    print('[SellerOrderItemCard] Tenant info - id: ${order.tenant?.id}, nickname: ${order.tenant?.nickname}');

    // 假设 order.items 非空，并且我们显示第一个 item 的信息作为预览
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    // Define the callback for navigating to detail page (used by multiple buttons)
    VoidCallback navigateToDetail = () {
      if (onTap != null) {
        onTap!(); // Use the main onTap callback passed from the list page
      } else {
         // TODO: Define seller detail route and navigate
         // context.go('/seller/orders/${order.id}');
         print('[SellerOrderItemCard] Navigate to seller detail for order ${order.id}');
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
        onTap: onTap ?? navigateToDetail, // Default to navigate if onTap is null
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：**买家**信息和订单状态
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 显示买家信息
                  Expanded(
                    child: Row(
                      children: [
                        // 买家头像
                        if (order.buyer?.avatar != null && order.buyer!.avatar!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(order.buyer!.avatar!),
                              backgroundColor: Colors.grey[200],
                              onBackgroundImageError: (_, __) {},
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surfaceVariant,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                        // 买家昵称
                        if (order.buyer?.nickname != null && order.buyer!.nickname!.isNotEmpty)
                          Expanded(
                            child: Text(
                              order.buyer!.nickname!,
                              style: textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // 如果有买家材料且订单状态适合显示
                        if (hasBuyerMaterials && _shouldShowMaterials(order.state)) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 12,
                                  color: Colors.blue[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '含材料',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                           // 显示订单总价
                          '${RegionConfig.currencySymbol}${order.priceSummary.payPrice.toStringAsFixed(2)}',
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
              // 操作按钮区域 - 使用新的 SellerOrderItemCardActionButtons
              Align(
                 alignment: Alignment.centerRight,
                 child: SellerOrderItemCardActionButtons(
                   order: order,
                   // Pass callbacks if defined in SellerOrderItemCardActionButtons
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 判断是否应该显示买家材料标签
  bool _shouldShowMaterials(OrderStatus status) {
    return status == OrderStatus.awaitingStart ||
        status == OrderStatus.awaitingDelivery ||
        status == OrderStatus.awaitingConfirmation ||
        status == OrderStatus.awaitingEvaluation ||
        status == OrderStatus.orderCompleted ||
        status == OrderStatus.afterSale ||
        status == OrderStatus.applyForRefuse;
  }
} 