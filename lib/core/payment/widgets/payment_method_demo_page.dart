import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../config/region_config.dart';
import '../models/payment_models.dart';
import '../services/payment_service_factory.dart';
import '../services/i_payment_service.dart';

class PaymentMethodDemoPage extends StatefulWidget {
  const PaymentMethodDemoPage({super.key});

  @override
  State<PaymentMethodDemoPage> createState() => _PaymentMethodDemoPageState();
}

class _PaymentMethodDemoPageState extends State<PaymentMethodDemoPage> {
  final PaymentServiceFactory _paymentFactory = GetIt.instance<PaymentServiceFactory>();
  String _lastResult = '';
  bool _isLoading = false;
  
  // 缓存支付方式信息
  Map<String, Map<String, dynamic>> _paymentMethodInfos = {};
  Map<String, bool> _serviceAvailability = {};
  bool _infoLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    try {
      // 根据区域配置动态加载支付方式信息
      final supportedMethods = RegionConfig.supportedPaymentMethods;
      
      for (final method in supportedMethods) {
        final methodCode = method.code;
        final info = await _paymentFactory.getPaymentMethodInfo(methodCode);
        _paymentMethodInfos[methodCode] = info;
        _serviceAvailability[methodCode] = info['available'] ?? false;
      }

      setState(() {
        _infoLoaded = true;
      });
    } catch (e) {
      print('加载支付信息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付方式测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _infoLoaded ? _buildContent() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    final supportedMethods = RegionConfig.supportedPaymentMethods;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 动态生成支付方式状态卡片
          ...supportedMethods.map((method) {
            IconData icon;
            Color color;
            String title;
            
            switch (method) {
              case PaymentMethod.alipay:
                icon = Icons.payment;
                color = Colors.blue;
                title = '支付宝支付';
                break;
              case PaymentMethod.wechat:
                icon = Icons.wechat;
                color = Colors.green;
                title = '微信支付';
                break;
              case PaymentMethod.stripe:
                icon = Icons.credit_card;
                color = Colors.purple;
                title = '信用卡支付';
                break;
            }
            
            return Column(
              children: [
                _buildPaymentMethodCard(
                  icon: icon,
                  title: title,
                  method: method.code,
                  color: color,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          
          const SizedBox(height: 8),
          
          // 测试按钮区域
          const Text(
            '测试功能',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // 动态生成测试按钮
          ...supportedMethods.map((method) {
            IconData icon;
            Color color;
            String label;
            
            switch (method) {
              case PaymentMethod.alipay:
                icon = Icons.payment;
                color = Colors.blue;
                label = '测试支付宝支付';
                break;
              case PaymentMethod.wechat:
                icon = Icons.wechat;
                color = Colors.green;
                label = '测试微信支付';
                break;
              case PaymentMethod.stripe:
                icon = Icons.credit_card;
                color = Colors.purple;
                label = '测试信用卡支付';
                break;
            }
            
            return Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _testPayment(method.code),
                  icon: Icon(icon),
                  label: Text(_isLoading ? '处理中...' : label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          
          const SizedBox(height: 24),
          
          // 结果显示区域
          const Text(
            '最近测试结果',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _lastResult.isEmpty ? '暂无测试结果' : _lastResult,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String method,
    required Color color,
  }) {
    final methodInfo = _paymentMethodInfos[method] ?? {};
    final isAvailable = _serviceAvailability[method] ?? false;
    final displayName = methodInfo['name'] ?? title;
    final isMock = methodInfo['mock'] ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? '可用' : '不可用',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '支付方式：$displayName',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            if (isMock) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mock模式',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (methodInfo['error'] != null) ...[
              const SizedBox(height: 8),
              Text(
                '错误: ${methodInfo['error']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testPayment(String method) async {
    setState(() {
      _isLoading = true;
      _lastResult = '开始测试 $method...\n';
    });

    try {
      final service = await _paymentFactory.getPaymentService(method);
      
      _updateResult('✓ 获取到${method}服务\n');
      _updateResult('状态：${service.isAvailable ? "可用" : "不可用"}\n');

      if (!service.isAvailable) {
        _updateResult('⚠️ 服务不可用，可能在Mock模式下仍可测试\n');
      }

      // 创建测试支付请求 - 动态获取支付方式
      final paymentMethod = PaymentMethod.values.firstWhere(
        (pm) => pm.code == method,
        orElse: () => PaymentMethod.alipay,
      );
      final request = PaymentRequest(
        orderId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        amount: '0.01',
        subject: '测试商品',
        description: '${method}测试支付',
        method: paymentMethod,
        scene: PaymentScene.order,
      );

      _updateResult('创建支付请求：\n');
      _updateResult('  订单ID: ${request.orderId}\n');
      _updateResult('  金额: ¥${request.amount}\n');
      _updateResult('  商品: ${request.subject}\n');

      _updateResult('\n正在发起支付...\n');

      // 调用支付
      final response = await service.createPayment(request);

      _updateResult('\n支付响应：\n');
      _updateResult('  成功: ${response.success}\n');
      _updateResult('  消息: ${response.message ?? "无"}\n');
      _updateResult('  订单ID: ${response.orderId ?? "无"}\n');
      _updateResult('  支付ID: ${response.paymentId ?? "无"}\n');
      _updateResult('  结果类型: ${response.resultType.displayName}\n');

      if (response.success) {
        _updateResult('\n✅ 支付成功！\n');
        
        // 根据结果类型给出导航建议
        if (response.resultType.shouldNavigateToOrders) {
          _updateResult('💡 建议：跳转到待付款订单页面\n');
        }
        if (response.resultType.shouldOfferRetry) {
          _updateResult('💡 建议：提供重试选项\n');
        }
        if (response.resultType.shouldOfferStatusQuery) {
          _updateResult('💡 建议：提供状态查询功能\n');
        }
      } else {
        _updateResult('\n❌ 支付失败\n');
        _updateResult('错误代码: ${response.code ?? "无"}\n');
      }

    } catch (e) {
      _updateResult('\n💥 异常: $e\n');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _updateResult('\n测试完成 ${DateTime.now()}\n');
      _updateResult('${"=" * 50}\n');
    }
  }

  void _updateResult(String message) {
    setState(() {
      _lastResult += message;
    });
  }
} 