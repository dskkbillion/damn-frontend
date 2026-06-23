import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/app_network_image.dart';
import '../bloc/order_detail_bloc.dart';
import '../widgets/order_evaluation_form.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_price_summary.dart';
import '../../domain/entities/order_payment_info.dart';
import '../../domain/entities/order_shipping_info.dart';
import '../../domain/entities/address.dart';

/// 订单评价页面
class OrderEvaluationPage extends StatefulWidget {
  final int itemId;
  final OrderItem? orderItem;

  const OrderEvaluationPage({
    super.key,
    required this.itemId,
    this.orderItem,
  });

  @override
  State<OrderEvaluationPage> createState() => _OrderEvaluationPageState();
}

class _OrderEvaluationPageState extends State<OrderEvaluationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).order_evaluation_page_title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (_) => GetIt.instance<OrderDetailBloc>(),
        child: BlocListener<OrderDetailBloc, OrderDetailState>(
          listener: (context, state) {
            if (state is OrderDetailActionSuccess) {
              // 评价提交成功
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // 延迟返回，让用户看到成功消息
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted && context.canPop()) {
                  context.pop(true); // 返回true表示评价成功，需要刷新
                }
              });
            } else if (state is OrderDetailActionFailure) {
              // 评价提交失败
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // 商品信息卡片
                if (widget.orderItem != null) _buildOrderItemCard(),
                const SizedBox(height: 16),
                
                // 评价表单
                _buildEvaluationForm(),
                const SizedBox(height: 32), // 底部留白
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建订单商品信息卡片
  Widget _buildOrderItemCard() {
    final item = widget.orderItem!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_evaluation_product_info,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 商品内容
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 商品图片
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.backgroundSecondary,
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
                        )
                      : Icon(Icons.image, color: AppColors.textTertiary, size: 40),
                ),
                const SizedBox(width: 16),
                
                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (item.skuName != null && item.skuName!.isNotEmpty)
                        Text(
                          item.skuName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '¥${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评价表单
  Widget _buildEvaluationForm() {
    final itemPrice = widget.orderItem?.price ?? 0.0;
    
    // 创建一个模拟的Order对象，只包含当前商品项
    final mockOrder = Order(
      id: widget.itemId,
      orderSn: '',
      state: OrderStatus.awaitingEvaluation,
      items: widget.orderItem != null ? [widget.orderItem!] : [],
      shippingAddress: Address.empty,
      priceSummary: OrderPriceSummary(
        totalPrice: itemPrice,
        discountPrice: 0.0,
        deliveryPrice: 0.0,
        payPrice: itemPrice,
      ),
      paymentInfo: OrderPaymentInfo.empty,
      shippingInfo: OrderShippingInfo.empty,
      createdAt: DateTime.now(),
    );

    return OrderEvaluationForm(order: mockOrder);
  }
}