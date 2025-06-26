import 'package:flutter/material.dart';

import '../models/payment_models.dart';
import '../services/payment_navigation_service.dart';

/// 支付导航演示页面
/// 用于测试不同支付结果类型的导航处理效果
class PaymentDemoPage extends StatelessWidget {
  const PaymentDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付导航演示'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '测试不同支付结果的导航处理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            _buildDemoButton(
              context,
              '支付成功',
              PaymentResultType.success,
              Colors.green,
              '跳转到订单详情页面',
            ),
            
            _buildDemoButton(
              context,
              '用户取消支付',
              PaymentResultType.userCancelled,
              Colors.orange,
              '跳转到待付款订单',
            ),
            
            _buildDemoButton(
              context,
              '网络连接错误',
              PaymentResultType.networkError,
              Colors.red,
              '显示重试对话框',
            ),
            
            _buildDemoButton(
              context,
              '支付结果未知',
              PaymentResultType.unknown,
              Colors.purple,
              '显示状态查询对话框',
            ),
            
            _buildDemoButton(
              context,
              '支付处理中',
              PaymentResultType.processing,
              Colors.blue,
              '跳转到待付款订单',
            ),
            
            _buildDemoButton(
              context,
              '支付失败',
              PaymentResultType.failed,
              Colors.grey,
              '跳转到支付失败页面',
            ),
            
            const SizedBox(height: 24),
            const Text(
              '注意：这是演示页面，实际导航会根据支付结果类型进行处理',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDemoButton(
    BuildContext context,
    String title,
    PaymentResultType resultType,
    Color color,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _simulatePaymentResult(context, resultType),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _simulatePaymentResult(BuildContext context, PaymentResultType resultType) {
    // 创建模拟的支付响应
    final paymentResponse = PaymentResponse(
      success: resultType == PaymentResultType.success,
      data: resultType == PaymentResultType.success ? 'mock_success_data' : null,
      orderId: '123456', // 模拟订单ID
      message: _getMessageForResultType(resultType),
      code: _getCodeForResultType(resultType),
      resultType: resultType,
    );
    
    // 使用支付导航服务处理结果
    PaymentNavigationService.handlePaymentResult(context, paymentResponse);
  }
  
  String _getMessageForResultType(PaymentResultType resultType) {
    switch (resultType) {
      case PaymentResultType.success:
        return '支付成功！';
      case PaymentResultType.userCancelled:
        return '您已取消支付';
      case PaymentResultType.networkError:
        return '网络连接出错，请重试';
      case PaymentResultType.unknown:
        return '支付结果未知，请查询订单状态';
      case PaymentResultType.processing:
        return '支付正在处理中，请稍后查看订单状态';
      case PaymentResultType.failed:
        return '支付失败，请重试';
    }
  }
  
  int _getCodeForResultType(PaymentResultType resultType) {
    switch (resultType) {
      case PaymentResultType.success:
        return 9000;
      case PaymentResultType.userCancelled:
        return 6001;
      case PaymentResultType.networkError:
        return 6002;
      case PaymentResultType.unknown:
        return 6004;
      case PaymentResultType.processing:
        return 8000;
      case PaymentResultType.failed:
        return 4000;
    }
  }
} 