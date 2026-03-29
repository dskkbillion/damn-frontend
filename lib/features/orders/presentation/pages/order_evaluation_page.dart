import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../bloc/order_detail_bloc.dart';
import '../widgets/order_evaluation_form.dart';
import '../../domain/entities/order.dart';

/// 订单评价页面
class OrderEvaluationPage extends StatefulWidget {
  final int orderId;
  final Order? order;

  const OrderEvaluationPage({
    super.key,
    required this.orderId,
    this.order,
  });

  @override
  State<OrderEvaluationPage> createState() => _OrderEvaluationPageState();
}

class _OrderEvaluationPageState extends State<OrderEvaluationPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('评价订单'),
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
                    backgroundColor: AppColors.success,
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
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spacingLg),
                  // 商品信息卡片
                  if (widget.order != null && widget.order!.items.isNotEmpty)
                    _buildOrderItemCard(),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // 评价表单
                  _buildEvaluationForm(),
                  const SizedBox(height: AppDimensions.spacingXxxl), // 底部留白
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建订单商品信息卡片
  Widget _buildOrderItemCard() {
    final item = widget.order!.items.first;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderSecondary,
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
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  '商品信息',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 商品内容
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Row(
              children: [
                // 商品图片
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    color: AppColors.backgroundSecondary,
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, color: AppColors.textTertiary),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                      ),
                          ),
                        )
                      : Icon(Icons.image, color: AppColors.textTertiary, size: 40),
                ),
                const SizedBox(width: AppDimensions.spacingLg),

                // 商品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      if (item.skuName != null && item.skuName!.isNotEmpty)
                        Text(
                          item.skuName!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        '¥${item.price.toStringAsFixed(2)}',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
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
    if (widget.order != null) {
      // 使用传入的完整订单对象
      return OrderEvaluationForm(order: widget.order!);
    } else {
      // 如果没有传入订单对象，显示错误提示
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          '无法加载订单信息，请返回重试',
          style: TextStyle(color: AppColors.error),
        ),
      );
    }
  }
}
