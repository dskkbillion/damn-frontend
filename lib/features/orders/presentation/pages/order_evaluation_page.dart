import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

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
                  if (widget.order != null && widget.order!.items.isNotEmpty)
                    _buildOrderItemCard(),
                  const SizedBox(height: 16),

                  // 评价表单
                  _buildEvaluationForm(),
                  const SizedBox(height: 32), // 底部留白
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
                  '商品信息',
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
                    color: Colors.grey[200],
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, color: Colors.grey[500]),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2)
                                      ),
                          ),
                        )
                      : Icon(Icons.image, color: Colors.grey[500], size: 40),
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
                            color: Colors.grey[600],
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
    if (widget.order != null) {
      // 使用传入的完整订单对象
      return OrderEvaluationForm(order: widget.order!);
    } else {
      // 如果没有传入订单对象，显示错误提示
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '无法加载订单信息，请返回重试',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }
}
