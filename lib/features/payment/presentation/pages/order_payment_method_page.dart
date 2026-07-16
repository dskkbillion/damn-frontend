import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../../../core/config/region_config.dart';
import '../../../../core/payment/models/payment_models.dart' as payment_models;
import '../../../../core/payment/presentation/pages/stripe_payment_webview_page.dart';
import '../../../../core/widgets/custom_loading_dialog.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../../../../features/orders/domain/entities/order.dart';
import '../../../orders/presentation/bloc/order_detail_bloc.dart';

/// 订单支付方式选择页面
/// 用于为已创建的订单选择支付方式并完成支付
class OrderPaymentMethodPage extends StatefulWidget {
  final Order order;

  const OrderPaymentMethodPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderPaymentMethodPage> createState() => _OrderPaymentMethodPageState();
}

class _OrderPaymentMethodPageState extends State<OrderPaymentMethodPage> {
  late payment_models.PaymentMethod _selectedPaymentMethod;
  late List<payment_models.PaymentMethod> _availablePaymentMethods;
  bool _isProcessing = false;
  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    AppLogger.d('[OrderPaymentMethodPage] initState() - Order ID: ${widget.order.id}');

    // 根据区域配置获取可用的支付方式
    _availablePaymentMethods = RegionConfig.supportedPaymentMethods;
    // 设置默认选中的支付方式
    _selectedPaymentMethod = _availablePaymentMethods.isNotEmpty
        ? _availablePaymentMethods.first
        : payment_models.PaymentMethod.alipay;

    // 确保 BLoC 状态是 OrderDetailLoaded，以便支付功能正常工作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<OrderDetailBloc>();
      if (bloc.state is! OrderDetailLoaded) {
        AppLogger.d('[OrderPaymentMethodPage] State is not OrderDetailLoaded, reloading order...');
        bloc.add(LoadOrderDetail(orderId: widget.order.id));
      }
    });
  }

  @override
  void dispose() {
    AppLogger.d('[OrderPaymentMethodPage] dispose() called');
    // 如果有对话框显示，确保关闭它
    if (_isLoadingDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.order.priceSummary.payPrice;

    return BlocListener<OrderDetailBloc, OrderDetailState>(
      listener: (context, state) {
        if (state is OrderDetailPaymentLoading) {
          setState(() {
            _isProcessing = true;
          });
          _showLoadingDialog('支付中...');
        } else if (state is OrderDetailPaymentResult) {
          setState(() {
            _isProcessing = false;
          });
          _dismissLoadingDialog();

          final response = state.paymentResponse;

          // Stripe支付需要打开WebView完成实际支付
          if (response.success &&
              _selectedPaymentMethod == payment_models.PaymentMethod.stripe &&
              response.data != null &&
              response.data!.isNotEmpty) {
            // 打开Stripe WebView
            _openStripeWebView(response.data!, response.orderId ?? widget.order.id.toString());
            return;
          }

          // 其他支付方式：跳转到支付结果页面
          if (mounted) {
            final params = <String, String>{
              'success': response.success ? 'true' : 'false',
            };

            if (response.success) {
              params['orderId'] = response.orderId ?? widget.order.id.toString();
            } else {
              params['errorMessage'] = response.message ?? '支付失败';
              params['orderId'] = response.orderId ?? widget.order.id.toString();
            }

            context.pushNamed('paymentResult', queryParameters: params);
          }
        } else if (state is OrderDetailActionFailure) {
          setState(() {
            _isProcessing = false;
          });
          _dismissLoadingDialog();

          // 显示错误消息
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('选择支付方式'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单信息卡片
              GlassCard(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                tintOpacity: 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '订单编号: ${widget.order.orderSn}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      if (widget.order.items.isNotEmpty)
                        Text(
                          widget.order.items.first.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '应付金额',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            RegionConfig.formatPrice(totalAmount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // 支付方式标题
              Text(
                RegionConfig.currentRegion == RegionType.domestic ? '选择支付方式' : 'Select Payment Method',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // 动态生成支付方式选项
              ..._availablePaymentMethods.map((method) => Column(
                children: [
                  _buildPaymentMethodOption(method),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
              )),

              const SizedBox(height: 32),

              // 确认支付按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing
                        ? AppColors.textTertiary
                        : _getButtonColor(),
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
                            SizedBox(width: AppDimensions.spacingMd),
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
                          '${RegionConfig.currentRegion == RegionType.domestic ? "确认支付" : "Pay Now"} ${RegionConfig.formatPrice(totalAmount)}',
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
  Widget _buildPaymentMethodOption(payment_models.PaymentMethod method) {
    IconData iconData;
    Color iconColor;
    String? logoAsset;
    String subtitle;

    switch (method) {
      case payment_models.PaymentMethod.alipay:
        iconData = Icons.payment;
        iconColor = Colors.blue; // 支付宝品牌色
        logoAsset = 'assets/images/alipay_logo.png';
        subtitle = RegionConfig.currentRegion == RegionType.domestic ? '安全快捷支付' : 'Fast and secure payment';
        break;
      case payment_models.PaymentMethod.wechat:
        iconData = Icons.wechat;
        iconColor = Colors.green; // 微信品牌色
        logoAsset = null;
        subtitle = RegionConfig.currentRegion == RegionType.domestic ? '微信安全支付' : 'WeChat Pay';
        break;
      case payment_models.PaymentMethod.stripe:
        iconData = Icons.credit_card;
        iconColor = Colors.purple; // Stripe品牌色
        logoAsset = null;
        subtitle = RegionConfig.currentRegion == RegionType.domestic
            ? '支持Visa、MasterCard等（美元结算）'
            : 'Visa, MasterCard, etc.';
        break;
    }

    return _buildPaymentOption(
      method,
      method.displayName,
      logoAsset,
      iconData,
      iconColor,
      subtitle: subtitle,
    );
  }

  /// 构建支付方式选项UI
  Widget _buildPaymentOption(
    payment_models.PaymentMethod method,
    String name,
    String? logoAsset,
    IconData fallbackIcon,
    Color iconColor,
    {String? subtitle}
  ) {
    final isSelected = _selectedPaymentMethod == method;
    final effectiveIconColor = iconColor;
    final effectiveTextColor = isSelected ? Theme.of(context).primaryColor : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : AppColors.borderInput,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : null,
        ),
        child: Row(
          children: [
            // 选择指示器
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: AppDimensions.spacingLg),

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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
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
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(
                  fallbackIcon,
                  color: effectiveIconColor,
                  size: 20,
                ),
              ),

            const SizedBox(width: AppDimensions.spacingLg),

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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示加载对话框
  void _showLoadingDialog(String message) {
    if (!_isLoadingDialogShowing) {
      _isLoadingDialogShowing = true;
      showLoadingDialog(context, message: message);
    }
  }

  /// 关闭加载对话框
  void _dismissLoadingDialog() {
    if (_isLoadingDialogShowing && mounted) {
      _isLoadingDialogShowing = false;
      dismissLoadingDialog(context);
    }
  }

  /// 打开Stripe WebView进行支付
  Future<void> _openStripeWebView(String paymentUrl, String orderId) async {
    AppLogger.d('[OrderPaymentMethodPage] 打开Stripe WebView - URL: $paymentUrl');

    try {
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => StripePaymentWebViewPage(
            paymentUrl: paymentUrl,
            orderId: orderId,
            successUrlPattern: 'stripe/callback/success',
            cancelUrlPattern: 'stripe/callback/cancel',
            failureUrlPattern: 'stripe/callback/failure',
          ),
        ),
      );

      AppLogger.d('[OrderPaymentMethodPage] Stripe WebView结果: $result');

      // 根据WebView结果导航到支付结果页面
      if (mounted) {
        final params = <String, String>{
          'orderId': orderId,
        };

        if (result != null && result['result'] == PaymentWebViewResult.success) {
          // Stripe 的 success_url 只说明结账页已回跳；订单状态仍需以后端
          // webhook 的落库结果为准，避免超时关闭的订单被错误展示为“支付成功”。
          params['success'] = 'pending';
        } else if (result != null && result['result'] == PaymentWebViewResult.cancelled) {
          params['success'] = 'false';
          params['errorMessage'] = '用户取消支付';
        } else if (result != null && result['result'] == PaymentWebViewResult.pending) {
          // #326: 用户声明已支付但 success_url 没自动跳 — 让 paymentResult 页查后端
          params['success'] = 'pending';
          params['errorMessage'] = '正在确认支付结果...';
        } else {
          params['success'] = 'false';
          params['errorMessage'] = '支付失败';
        }

        context.pushNamed('paymentResult', queryParameters: params);
      }
    } catch (e) {
      AppLogger.d('[OrderPaymentMethodPage] 打开Stripe WebView失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开支付页面失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 确认支付
  void _confirmPayment() {
    // 防重复点击检查
    if (_isProcessing) {
      AppLogger.d('[OrderPaymentMethodPage] 正在处理中，忽略重复点击');
      return;
    }

    AppLogger.d('[OrderPaymentMethodPage] 开始支付 - 订单ID: ${widget.order.id}, 支付方式: $_selectedPaymentMethod');

    // 触发支付事件 - 传递选择的支付方式
    context.read<OrderDetailBloc>().add(
      ProcessPaymentWithMethod(
        orderId: widget.order.id,
        paymentMethod: _selectedPaymentMethod,
      ),
    );
  }

  Color _getButtonColor() {
    switch (_selectedPaymentMethod) {
      case payment_models.PaymentMethod.alipay:
        return Colors.blue; // 支付宝品牌色
      case payment_models.PaymentMethod.wechat:
        return Colors.green; // 微信品牌色
      case payment_models.PaymentMethod.stripe:
        return Colors.purple; // Stripe品牌色
    }
  }
}
