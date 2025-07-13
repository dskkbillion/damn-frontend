import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/payment_service_factory.dart';
import '../models/payment_models.dart';
import '../services/payment_navigation_service.dart';

/// 支付方式选择器
class PaymentMethodSelector extends StatefulWidget {
  final String orderId;
  final String amount;
  final String subject;
  final String description;

  const PaymentMethodSelector({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.subject,
    required this.description,
  }) : super(key: key);

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod _selectedMethod = PaymentMethod.alipay;
  bool _isProcessing = false;
  
  // 微信支付是否可用（上线前设置为false）
  static const bool _isWechatPaymentAvailable = false;

  Future<void> _handlePayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final factory = GetIt.instance<PaymentServiceFactory>();
      final service = await factory.getPaymentService(_selectedMethod.code);
      
      final request = PaymentRequest(
        orderId: widget.orderId,
        amount: widget.amount,
        subject: widget.subject,
        description: widget.description,
        method: _selectedMethod,
        scene: PaymentScene.order,
      );
      
      final result = await service.createPayment(request);
      
      if (mounted) {
        PaymentNavigationService.handlePaymentResult(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 支付金额显示
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '支付金额：',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '¥${widget.amount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // 支付方式选择
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '选择支付方式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // 支付宝选项
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payment,
              color: Colors.blue,
            ),
          ),
          title: const Text('支付宝'),
          subtitle: const Text('安全快捷支付'),
          trailing: Radio<PaymentMethod>(
            value: PaymentMethod.alipay,
            groupValue: _selectedMethod,
            onChanged: (value) => setState(() => _selectedMethod = value!),
          ),
          onTap: () => setState(() => _selectedMethod = PaymentMethod.alipay),
        ),
        
        // 微信支付选项
        ListTile(
          enabled: _isWechatPaymentAvailable,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isWechatPaymentAvailable 
                  ? Colors.green.shade50 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.wechat,
              color: _isWechatPaymentAvailable 
                  ? Colors.green 
                  : Colors.grey,
            ),
          ),
          title: Text(
            '微信支付',
            style: TextStyle(
              color: _isWechatPaymentAvailable 
                  ? null 
                  : Colors.grey,
            ),
          ),
          subtitle: Text(
            _isWechatPaymentAvailable 
                ? '便捷的移动支付' 
                : '🚧 施工中，敬请期待',
            style: TextStyle(
              color: _isWechatPaymentAvailable 
                  ? null 
                  : Colors.orange,
              fontWeight: _isWechatPaymentAvailable 
                  ? FontWeight.normal 
                  : FontWeight.bold,
            ),
          ),
          trailing: Radio<PaymentMethod>(
            value: PaymentMethod.wechat,
            groupValue: _selectedMethod,
            onChanged: _isWechatPaymentAvailable 
                ? (value) => setState(() => _selectedMethod = value!) 
                : null,
          ),
          onTap: _isWechatPaymentAvailable 
              ? () => setState(() => _selectedMethod = PaymentMethod.wechat)
              : null,
        ),
        
        const SizedBox(height: 20),
        
        // 支付按钮
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMethod == PaymentMethod.wechat 
                    ? Colors.green 
                    : Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '确认支付 ¥${widget.amount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        
        // 支付说明
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '点击"确认支付"即表示您同意并接受相关服务条款',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
} 