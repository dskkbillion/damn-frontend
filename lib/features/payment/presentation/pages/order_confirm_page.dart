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
  String _selectedPaymentMethod = 'alipay'; // 默认选择支付宝
  bool _isProcessing = false; // 防重复提交标志
  
  // 微信支付是否可用（上线前设置为false）
  static const bool _isWechatPaymentAvailable = false;
  // Stripe支付是否可用
  static const bool _isStripePaymentAvailable = true;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(ResetPaymentEvent());
    
    // 如果微信支付不可用且当前选择的是微信支付，自动切换到支付宝
    if (!_isWechatPaymentAvailable && _selectedPaymentMethod == 'wechat') {
      _selectedPaymentMethod = 'alipay';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is CreatingOrderState) {
          setState(() {
            _isProcessing = true;
          });
          showLoadingDialog(context, message: '创建订单中...');
        } else if (state is PayingState) {
          setState(() {
            _isProcessing = true;
          });
          dismissLoadingDialog(context);
          showLoadingDialog(context, message: '支付中...');
        } else if (state is PaymentCompletedState || state is PaymentFailedState) {
          setState(() {
            _isProcessing = false;
          });
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
        } else if (state is PaymentInitial) {
          // 重置状态时也重置处理标志
          setState(() {
            _isProcessing = false;
          });
          dismissLoadingDialog(context); // 关闭加载对话框
        } else if (state is ExternalPaymentProcessingState) {
          // 外部支付处理中（如Stripe）
          setState(() {
            _isProcessing = false;
          });
          dismissLoadingDialog(context); // 关闭加载对话框
          
          // 显示提示信息
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('正在跳转到支付页面，请在浏览器中完成支付'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: '查看订单',
                onPressed: () {
                  // 跳转到订单详情页
                  context.go('/orders?status=awaitingPayment');
                },
              ),
            ),
          );
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
              const SizedBox(height: 16),
              
              // 支付宝选项
              _buildPaymentOption(
                'alipay',
                '支付宝',
                'assets/images/alipay_logo.png',
                Icons.payment,
                Colors.blue,
              ),
              
              const SizedBox(height: 12),
              
              // 微信支付选项
              _buildPaymentOption(
                'wechat',
                '微信支付',
                null, // 没有微信logo图片，使用图标
                Icons.wechat,
                Colors.green,
                enabled: _isWechatPaymentAvailable,
                subtitle: _isWechatPaymentAvailable ? null : '🚧 施工中，敬请期待',
              ),
              
              const SizedBox(height: 12),
              
              // 信用卡支付选项（Stripe）
              _buildPaymentOption(
                'stripe',
                '信用卡支付',
                null, // 没有Stripe logo图片，使用图标
                Icons.credit_card,
                Colors.purple,
                enabled: _isStripePaymentAvailable,
                subtitle: _isStripePaymentAvailable ? '支持Visa、MasterCard等' : '🚧 施工中，敬请期待',
              ),
              
              const SizedBox(height: 32),
              
              // 确认支付按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmOrder, // 处理中时禁用按钮
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing 
                        ? Colors.grey 
                        : (_selectedPaymentMethod == 'wechat' 
                            ? Colors.green 
                            : _selectedPaymentMethod == 'stripe'
                                ? Colors.purple
                                : Colors.blue),
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '处理中...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '确认支付 ￥${(widget.price * widget.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
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

  /// 构建支付方式选项
  Widget _buildPaymentOption(
    String method,
    String name,
    String? logoAsset,
    IconData fallbackIcon,
    Color iconColor,
    {bool enabled = true, String? subtitle}
  ) {
    final isSelected = _selectedPaymentMethod == method;
    final effectiveIconColor = enabled ? iconColor : Colors.grey;
    final effectiveTextColor = enabled 
        ? (isSelected ? Theme.of(context).primaryColor : null)
        : Colors.grey;
    
    return Opacity(
      opacity: enabled ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: enabled ? () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        } : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled && isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: enabled && isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.05) 
                : null,
          ),
          child: Row(
            children: [
              // 选择指示器
              Icon(
                enabled && isSelected 
                    ? Icons.radio_button_checked 
                    : Icons.radio_button_unchecked,
                color: enabled && isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
              ),
              const SizedBox(width: 16),
              
              // 支付方式图标/Logo
              if (logoAsset != null)
                Image.asset(
                  logoAsset,
                  width: 60,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                        color: effectiveIconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        fallbackIcon,
                        color: effectiveIconColor,
                        size: 20,
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    fallbackIcon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
              
              const SizedBox(width: 16),
              
              // 支付方式名称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: effectiveTextColor,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: enabled ? Colors.orange : Colors.grey,
                          fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
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
    // 防重复点击检查
    if (_isProcessing) {
      print('[OrderConfirmPage] 正在处理中，忽略重复点击');
      return;
    }
    
    print('[OrderConfirmPage] 开始创建订单并支付 - 商品: ${widget.productName}, 支付方式: $_selectedPaymentMethod');
    
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
        paymentMethod: _selectedPaymentMethod, // 传递选择的支付方式
      ),
    );
  }
} 