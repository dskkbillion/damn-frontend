import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
// Import GoRouter

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_widget.dart';
// Import the new seller buttons widget
import 'seller_order_item_card_action_buttons.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';

/// 用于在**卖家**订单列表中显示单个订单摘要信息的卡片 Widget。
class SellerOrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap; // 点击卡片的回调 (导航到详情)
  final bool hasBuyerMaterials; // 是否有买家提供的材料

  const SellerOrderItemCard(
      {super.key,
      required this.order,
      this.onTap,
      this.hasBuyerMaterials = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // 调试日志
    AppLogger.d('[SellerOrderItemCard] Building card for order ${order.id}');
    AppLogger.d(
        '[SellerOrderItemCard] Buyer info - id: ${order.buyer?.id}, nickname: ${order.buyer?.nickname}');
    AppLogger.d(
        '[SellerOrderItemCard] Tenant info - id: ${order.tenant?.id}, nickname: ${order.tenant?.nickname}');

    // 假设 order.items 非空，并且我们显示第一个 item 的信息作为预览
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    // Define the callback for navigating to detail page (used by multiple buttons)
    void navigateToDetail() {
      if (onTap != null) {
        onTap!(); // Use the main onTap callback passed from the list page
      } else {
        // TODO: Define seller detail route and navigate
        // context.go('/seller/orders/${order.id}');
        AppLogger.d(
            '[SellerOrderItemCard] Navigate to seller detail for order ${order.id}');
      }
    }

    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      tintOpacity: 0.62,
      child: InkWell(
        onTap:
            onTap ?? navigateToDetail, // Default to navigate if onTap is null
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
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
                        if (order.buyer?.avatar != null &&
                            order.buyer!.avatar!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  NetworkImage(order.buyer!.avatar!),
                              backgroundColor: AppColors.backgroundSecondary,
                              onBackgroundImageError: (_, __) {},
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                        // 买家昵称
                        if (order.buyer?.nickname != null &&
                            order.buyer!.nickname!.isNotEmpty)
                          Expanded(
                            child: Text(
                              order.buyer!.nickname!,
                              style: textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // 如果有买家材料且订单状态适合显示
                        if (hasBuyerMaterials &&
                            _shouldShowMaterials(order.state)) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '含材料',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                  OrderStatusWidget(
                    status: order.state,
                  ), // 显示订单状态
                ],
              ),
              const SizedBox(height: 12.0),
              // 内容：商品图片和基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品图片
                  if (firstItem?.imageUrl != null &&
                      firstItem!.imageUrl.isNotEmpty)
                    AppNetworkImage(
                      imageUrl: firstItem.imageUrl,
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(8.0),
                    )
                  else // 如果没有图片URL，显示占位符
                    Container(
                      width: 80,
                      height: 80,
                      color: AppColors.backgroundSecondary,
                      child: const Icon(Icons.image,
                          color: AppColors.textTertiary),
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
                        if (firstItem?.skuName != null &&
                            firstItem!.skuName!.isNotEmpty)
                          Text(
                            firstItem.skuName!, // 商品描述/规格
                            style: textTheme.bodySmall
                                ?.copyWith(color: colorScheme.secondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8.0),
                        Text(
                          // 显示订单总价
                          RegionConfig.formatPrice(order.priceSummary.payPrice),
                          style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              const Divider(height: 1, color: AppColors.borderPrimary), // 分隔线
              const SizedBox(height: 8.0), // Reduced spacing slightly
              // 时间戳单独一行，靠左
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 0, bottom: 4.0), // Adjust padding as needed
                  child: Text(
                    '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.secondary),
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
