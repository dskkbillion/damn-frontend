import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import '../services/payment_service_factory.dart';
import '../models/payment_models.dart' as models;
import '../services/payment_navigation_service.dart';
import '../../config/region_config.dart';

/// 支付方式选择器
class PaymentMethodSelector extends StatefulWidget {
  final String orderId;
  final String amount;
  final String subject;
  final String description;

  const PaymentMethodSelector({
    super.key,
    required this.orderId,
    required this.amount,
    required this.subject,
    required this.description,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late models.PaymentMethod _selectedMethod;
  bool _isProcessing = false;
  late List<models.PaymentMethod> _availablePaymentMethods;

  @override
  void initState() {
    super.initState();
    // 根据区域配置获取可用的支付方式
    _availablePaymentMethods = RegionConfig.supportedPaymentMethods;
    // 设置默认选中的支付方式
    _selectedMethod = _availablePaymentMethods.isNotEmpty
        ? _availablePaymentMethods.first
        : models.PaymentMethod.credits;
  }

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final factory = GetIt.instance<PaymentServiceFactory>();
      final service = await factory.getPaymentService(_selectedMethod.code);

      final request = models.PaymentRequest(
        orderId: widget.orderId,
        amount: widget.amount,
        subject: widget.subject,
        description: widget.description,
        method: _selectedMethod,
        scene: models.PaymentScene.order,
      );

      // 创建支付订单
      final response = await service.createPayment(request);

      if (response.success && response.data != null) {
        // 发起支付
        final result = await service.pay(response.data!);

        // 导航到相应页面
        final navigationService = GetIt.instance<PaymentNavigationService>();
        if (mounted) {
          // 将PaymentResult转换为PaymentResponse以便导航处理
          final navResponse = models.PaymentResponse(
            success: result.isSuccess,
            message: result.message,
            orderId: result.orderId,
            resultType: result.isSuccess
                ? models.PaymentResultType.success
                : models.PaymentResultType.failed,
          );
          PaymentNavigationService.handlePaymentResult(context, navResponse);
        }
      } else {
        throw Exception(response.message ??
            AppLocalizations.of(context).payment_create_order_failed);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .payment_failed_message(e.toString())),
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

  Widget _buildPaymentMethodTile(models.PaymentMethod method) {
    final l10n = AppLocalizations.of(context);
    IconData iconData;
    Color iconColor;
    Color bgColor;
    String subtitle;

    switch (method) {
      case models.PaymentMethod.credits:
        iconData = Icons.stars_rounded;
        iconColor = Colors.amber;
        bgColor = Colors.amber.shade50;
        subtitle = '使用 DeepStream 积分';
        break;
      case models.PaymentMethod.alipay:
        iconData = Icons.payment;
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        subtitle = l10n.payment_alipay_subtitle;
        break;
      case models.PaymentMethod.wechat:
        iconData = Icons.wechat;
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        subtitle = l10n.payment_wechat_subtitle;
        break;
      case models.PaymentMethod.stripe:
        iconData = Icons.credit_card;
        iconColor = Colors.purple;
        bgColor = Colors.purple.shade50;
        subtitle = 'Credit/Debit Card';
        break;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
      title: Text(method.displayName),
      subtitle: Text(subtitle),
      trailing: Radio<models.PaymentMethod>(
        value: method,
        groupValue: _selectedMethod,
        onChanged: (value) => setState(() => _selectedMethod = value!),
      ),
      onTap: () => setState(() => _selectedMethod = method),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // 支付金额显示
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.payment_amount_label,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '${RegionConfig.currencySymbol}${widget.amount}',
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.payment_select_method,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // 动态生成支付方式选项
        ..._availablePaymentMethods
            .map((method) => _buildPaymentMethodTile(method)),

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
                backgroundColor: _getButtonColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      l10n.payment_confirm_pay,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 支付说明
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.payment_terms_agreement,
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

  Color _getButtonColor() {
    switch (_selectedMethod) {
      case models.PaymentMethod.credits:
        return Colors.amber;
      case models.PaymentMethod.alipay:
        return Colors.blue;
      case models.PaymentMethod.wechat:
        return Colors.green;
      case models.PaymentMethod.stripe:
        return Colors.purple;
    }
  }
}
