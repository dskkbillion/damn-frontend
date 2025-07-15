import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 支付结果页面
class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String? orderId;
  final String? errorMessage;

  const PaymentResultPage({
    Key? key,
    required this.success,
    this.orderId,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(success ? '支付成功' : '支付失败'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         kToolbarHeight - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  size: 80, // 减小图标尺寸，避免溢出
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),
                
                // 结果标题
                Text(
                  success ? '支付成功' : '支付失败',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 结果详情
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        success
                            ? orderId != null
                                ? '订单 $orderId 已支付完成'
                                : '支付已完成'
                            : errorMessage ?? '支付过程中出现错误',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (success) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '提示：订单状态可能需要几分钟更新，请稍后查看',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (success) ...[
                      ElevatedButton(
                        onPressed: () {
                          // 跳转到订单详情页面
                          if (orderId != null) {
                            context.go('/orderDetail/$orderId');
                          } else {
                            context.go('/profile/orders');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('查看订单'),
                      ),
                      const SizedBox(width: 16),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        // 返回首页
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: success ? Colors.grey[200] : null,
                        foregroundColor: success ? Colors.black87 : null,
                      ),
                      child: const Text('返回首页'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 