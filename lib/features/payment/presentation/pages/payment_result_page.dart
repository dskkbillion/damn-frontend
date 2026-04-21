import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// 支付结果页面
class PaymentResultPage extends StatelessWidget {
  final bool success;
  final String? orderId;
  final String? errorMessage;

  const PaymentResultPage({
    super.key,
    required this.success,
    this.orderId,
    this.errorMessage,
  });

  void _exitPaymentFlow(BuildContext context) {
    context.go('/profile/orders');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitPaymentFlow(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(success ? '支付成功' : '支付失败'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _exitPaymentFlow(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    size: 80,
                    color: success ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),

                  // 结果标题
                  Text(
                    success ? '支付成功' : '支付失败',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

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
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (success) ...[
                          const SizedBox(height: AppDimensions.spacingLg),
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.spacingMd),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                                const SizedBox(width: AppDimensions.spacingSm),
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
                            if (orderId != null) {
                              context.push('/orderDetail/$orderId');
                            } else {
                              _exitPaymentFlow(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingXxl,
                              vertical: AppDimensions.spacingMd,
                            ),
                          ),
                          child: const Text('查看订单详情'),
                        ),
                        const SizedBox(width: AppDimensions.spacingLg),
                      ],
                      ElevatedButton(
                        onPressed: () => _exitPaymentFlow(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingXxl,
                            vertical: AppDimensions.spacingMd,
                          ),
                          backgroundColor: success ? AppColors.borderPrimary : null,
                          foregroundColor: success ? AppColors.textPrimary : null,
                        ),
                        child: const Text('返回订单列表'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
