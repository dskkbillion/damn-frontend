import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../config/region_config.dart';
import '../services/payment_service_factory.dart';
import '../models/payment_models.dart';
import '../services/payment_navigation_service.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 支付功能演示页面
class PaymentDemoPage extends StatefulWidget {
  const PaymentDemoPage({Key? key}) : super(key: key);

  @override
  State<PaymentDemoPage> createState() => _PaymentDemoPageState();
}

class _PaymentDemoPageState extends State<PaymentDemoPage> {
  late PaymentMethod _selectedMethod;
  late List<PaymentMethod> _availablePaymentMethods;
  bool _isProcessing = false;
  
  final _amountController = TextEditingController(text: '0.01');
  final _subjectController = TextEditingController(text: 'Test Product');
  final _orderIdController = TextEditingController(text: 'TEST${DateTime.now().millisecondsSinceEpoch}');

  @override
  void initState() {
    super.initState();
    // 根据区域配置获取可用的支付方式
    _availablePaymentMethods = RegionConfig.supportedPaymentMethods;
    // 设置默认选中的支付方式
    _selectedMethod = _availablePaymentMethods.isNotEmpty 
        ? _availablePaymentMethods.first 
        : PaymentMethod.wallet;
  }
  
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

    final l10n = AppLocalizations.of(context)!;

    try {
      final factory = GetIt.instance<PaymentServiceFactory>();
      final service = await factory.getPaymentService(_selectedMethod.code);

      final request = PaymentRequest(
        orderId: _orderIdController.text,
        amount: _amountController.text,
        subject: _subjectController.text,
        description: l10n.payment_test_description(_subjectController.text),
        method: _selectedMethod,
        scene: PaymentScene.order,
      );

      final result = await service.createPayment(request);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.payment_initiated_success(result.message ?? '')),
              backgroundColor: Colors.green,
            ),
          );
          // 可以在这里处理支付结果导航
          // PaymentNavigationService.handlePaymentResult(context, result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.payment_failed_message(result.message ?? '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.payment_exception(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final factory = GetIt.instance<PaymentServiceFactory>();

      final alipayAvailable = await factory.isPaymentMethodAvailable('alipay');
      final wechatAvailable = await factory.isPaymentMethodAvailable('wechat');
      final stripeAvailable = await factory.isPaymentMethodAvailable('stripe');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.payment_availability_title),
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
                    Text(l10n.payment_alipay),
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
                    Text(l10n.payment_wechat),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      stripeAvailable ? Icons.check_circle : Icons.cancel,
                      color: stripeAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.payment_credit_card),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.payment_confirm),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.payment_check_failed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.payment_test_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _checkPaymentAvailability,
            tooltip: l10n.payment_check_availability,
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
            Text(
                      l10n.payment_test_params,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _orderIdController,
                      decoration: InputDecoration(
                        labelText: l10n.payment_order_number,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: l10n.payment_amount_yuan,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: l10n.payment_product_name,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 支付方式选择
            Text(
              l10n.payment_select_method,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 动态生成支付方式选项
            ..._availablePaymentMethods.map((method) => Column(
              children: [
                _buildPaymentMethodOption(method),
                const SizedBox(height: 12),
              ],
            )),

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
                        l10n.payment_test_button(_selectedMethod.displayName, _amountController.text),
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
                  children: [
                    Text(
                      l10n.payment_usage_instructions,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.payment_instruction_1),
                    Text(l10n.payment_instruction_2),
                    Text(l10n.payment_instruction_3),
                    Text(l10n.payment_instruction_4),
                    const SizedBox(height: 8),
                    Text(
                      l10n.payment_test_warning,
                      style: const TextStyle(
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
  
  Widget _buildPaymentMethodOption(PaymentMethod method) {
    final l10n = AppLocalizations.of(context)!;
    IconData iconData;
    Color iconColor;
    String name;

    switch (method) {
      case PaymentMethod.alipay:
        iconData = Icons.payment;
        iconColor = Colors.blue;
        name = l10n.payment_alipay;
        break;
      case PaymentMethod.wechat:
        iconData = Icons.wechat;
        iconColor = Colors.green;
        name = l10n.payment_wechat;
        break;
      case PaymentMethod.stripe:
        iconData = Icons.credit_card;
        iconColor = Colors.purple;
        name = l10n.payment_credit_card;
        break;
      case PaymentMethod.wallet:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.orange;
        name = l10n.payment_wallet_balance;
        break;
    }

    return _buildPaymentOption(method, name, iconData, iconColor);
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
      case PaymentMethod.stripe:
        return Colors.purple;
      case PaymentMethod.alipay:
      default:
        return Colors.blue;
    }
  }
} 