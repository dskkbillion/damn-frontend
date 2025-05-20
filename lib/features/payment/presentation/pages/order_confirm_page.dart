import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_loading_dialog.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// 订单确认页面
class OrderConfirmPage extends StatefulWidget {
  final int productId;
  final int variantId;
  final int quantity;
  final int sellerId;
  final double price;
  final String productName;
  final String? imageUrl;

  const OrderConfirmPage({
    Key? key,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.sellerId,
    required this.price,
    required this.productName,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(ResetPaymentEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is CreatingOrderState) {
          showLoadingDialog(context, message: '创建订单中...');
        } else if (state is PayingState) {
          dismissLoadingDialog(context);
          showLoadingDialog(context, message: '支付中...');
        } else if (state is PaymentCompletedState || state is PaymentFailedState) {
          dismissLoadingDialog(context);
          
          // 跳转到支付结果页面
          final params = <String, String>{
            'success': state is PaymentCompletedState ? 'true' : 'false',
          };
          
          if (state is PaymentCompletedState) {
            params['orderId'] = state.orderId;
          } else if (state is PaymentFailedState) {
            params['errorMessage'] = state.errorMessage;
            if (state.orderId != null) {
              params['orderId'] = state.orderId!;
            }
          }
          
          context.pushNamed('paymentResult', queryParameters: params);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('确认订单'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品信息卡片
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // 商品图片
                      if (widget.imageUrl != null)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      const SizedBox(width: 16),
                      // 商品名称和价格
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '￥${widget.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '数量: ${widget.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 订单总结
              const Text(
                '订单摘要',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // 订单摘要列表
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('商品金额'),
                        Text('￥${widget.price.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('数量'),
                        Text('${widget.quantity}'),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '订单总计',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '￥${(widget.price * widget.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 支付方式
              const Text(
                '支付方式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // 支付宝支付方式
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Image.asset(
                      'assets/images/alipay_logo.png',
                      width: 80,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 40,
                          color: Colors.blue[50],
                          alignment: Alignment.center,
                          child: const Text(
                            '支付宝',
                            style: TextStyle(color: Colors.blue),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text('支付宝'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 确认支付按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '确认支付',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 确认订单
  void _confirmOrder() {
    // 发起创建订单并支付事件
    context.read<PaymentBloc>().add(
      CreateOrderAndPayEvent(
        productId: widget.productId,
        variantId: widget.variantId,
        quantity: widget.quantity,
        sellerId: widget.sellerId,
        price: widget.price,
        productName: widget.productName,
        imageUrl: widget.imageUrl,
      ),
    );
  }
} 