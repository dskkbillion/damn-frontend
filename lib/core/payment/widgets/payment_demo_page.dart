import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/payment_service_factory.dart';
import '../models/payment_models.dart';
import '../services/payment_navigation_service.dart';

/// 支付功能演示页面
class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({Key? key}) : super(key: key);

  @override
  State<PaymentDemoPage> createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends State<PaymentDemoPage> {
  PaymentMethod _selectedMethod = PaymentMethod.alipay;
  bool _isProcessing = false;
  
  final _amountController = TextEditingController(text: '0.01');
  final _subjectController = TextEditingController(text: '测试商品');
  final _orderIdController = TextEditingController(text: 'TEST${DateTime.now().millisecondsSinceEpoch}');

  @override
  void dispose() {
    _amountController.dispose();
    _subjectController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _testPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final factory = GetIt.instance<PaymentServiceFactory>();
      final service = await factory.getPaymentService(_selectedMethod.code);
      
      final request = PaymentRequest(
        orderId: _orderIdController.text,
        amount: _amountController.text,
        subject: _subjectController.text,
        description: '${_subjectController.text} - 支付测试',
        method: _selectedMethod,
        scene: PaymentScene.order,
      );
      
      final result = await service.createPayment(request);
      
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('支付发起成功：${result.message}'),
              backgroundColor: Colors.green,
            ),
          );
          // 可以在这里处理支付结果导航
          // PaymentNavigationService.handlePaymentResult(context, result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('支付失败：${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付异常: ${e.toString()}'),
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

  Future<void> _checkPaymentAvailability() async {
    try {
      final factory = GetIt.instance<PaymentServiceFactory>();
      
      final alipayAvailable = await factory.isPaymentMethodAvailable('alipay');
      final wechatAvailable = await factory.isPaymentMethodAvailable('wechat');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('支付方式可用性'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      alipayAvailable ? Icons.check_circle : Icons.cancel,
                      color: alipayAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text('支付宝'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      wechatAvailable ? Icons.check_circle : Icons.cancel,
                      color: wechatAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text('微信支付'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付功能测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _checkPaymentAvailability,
            tooltip: '检查支付方式可用性',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测试参数输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                      '测试参数',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _orderIdController,
                      decoration: const InputDecoration(
                        labelText: '订单号',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: '金额 (元)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: '商品名称',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 支付方式选择
            const Text(
              '选择支付方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 支付宝选项
            _buildPaymentOption(
              PaymentMethod.alipay,
              '支付宝',
              Icons.payment,
              Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            // 微信支付选项
            _buildPaymentOption(
              PaymentMethod.wechat,
              '微信支付',
              Icons.wechat,
              Colors.green,
            ),
            
            const SizedBox(height: 12),
            
            // 余额支付选项
            _buildPaymentOption(
              PaymentMethod.wallet,
              '余额支付',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            
            const SizedBox(height: 32),
            
            // 测试按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _testPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPaymentColor(),
                  foregroundColor: Colors.white,
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
                        '测试${_selectedMethod.displayName} ¥${_amountController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 说明文字
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '💡 使用说明',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. 修改上方测试参数'),
                    Text('2. 选择要测试的支付方式'),
                    Text('3. 点击测试按钮发起支付'),
                    Text('4. 点击右上角信息按钮检查支付方式可用性'),
                    SizedBox(height: 8),
                    Text(
                      '⚠️ 注意：测试环境建议使用0.01元进行测试',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentOption(
    PaymentMethod method,
    String name,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.05) : null,
        ),
        child: Row(
        children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getPaymentColor() {
    switch (_selectedMethod) {
      case PaymentMethod.wechat:
        return Colors.green;
      case PaymentMethod.wallet:
        return Colors.orange;
      case PaymentMethod.alipay:
      default:
        return Colors.blue;
    }
  }
} 