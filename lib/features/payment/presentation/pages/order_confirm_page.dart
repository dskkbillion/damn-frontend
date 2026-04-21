import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // For launchUrl
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

import '../../../../core/config/region_config.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/payment/models/payment_models.dart' as payment_models;
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
  final int? chatRoomId;
  final String productName;
  final String? displayProductName;
  final String? imageUrl;

  const OrderConfirmPage({
    super.key,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.sellerId,
    required this.price,
    this.chatRoomId,
    required this.productName,
    this.displayProductName,
    this.imageUrl,
  });

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  late payment_models.PaymentMethod _selectedPaymentMethod;
  late List<payment_models.PaymentMethod> _availablePaymentMethods;
  bool _isProcessing = false; // 防重复提交标志
  bool _isLoadingDialogShowing = false; // 跟踪加载对话框状态

  @override
  void dispose() {
    AppLogger.d('[OrderConfirmPage] dispose() called');
    // 如果有对话框显示，确保关闭它
    if (_isLoadingDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppLogger.d('[OrderConfirmPage] initState() called');
    AppLogger.d('[OrderConfirmPage] productId: ${widget.productId}');
    AppLogger.d('[OrderConfirmPage] variantId: ${widget.variantId}');
    AppLogger.d('[OrderConfirmPage] quantity: ${widget.quantity}');
    AppLogger.d('[OrderConfirmPage] sellerId: ${widget.sellerId}');
    AppLogger.d('[OrderConfirmPage] price: ${widget.price}');
    AppLogger.d('[OrderConfirmPage] chatRoomId: ${widget.chatRoomId}');
    AppLogger.d('[OrderConfirmPage] productName: ${widget.productName}');

    // 根据区域配置获取可用的支付方式
    _availablePaymentMethods = RegionConfig.supportedPaymentMethods;
    // 设置默认选中的支付方式
    _selectedPaymentMethod = _availablePaymentMethods.isNotEmpty
        ? _availablePaymentMethods.first
        : payment_models.PaymentMethod.alipay;

    context.read<PaymentBloc>().add(ResetPaymentEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is CreatingOrderState) {
          setState(() {
            _isProcessing = true;
          });
          _showLoadingDialog('创建订单中...');
        } else if (state is PayingState) {
          setState(() {
            _isProcessing = true;
          });
          _dismissLoadingDialog();
          _showLoadingDialog('支付中...');
        } else if (state is PaymentCompletedState || state is PaymentFailedState) {
          setState(() {
            _isProcessing = false;
          });
          _dismissLoadingDialog();

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
          // 不需要调用 dismissLoadingDialog，因为可能没有对话框显示
        } else if (state is ExternalPaymentProcessingState) {
          // 外部支付处理中（如Stripe）
          setState(() {
            _isProcessing = false;
          });
          _dismissLoadingDialog(); // 关闭加载对话框

          AppLogger.d('[OrderConfirmPage] 收到ExternalPaymentProcessingState, URL: ${state.paymentUrl}');

          // 显示支付链接对话框
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('信用卡支付'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('支付链接已准备就绪'),
                    const SizedBox(height: AppDimensions.spacingSm),
                    // 只有国服版本才显示汇率提示
                    if (RegionConfig.currentRegion == RegionType.domestic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: Text(
                                '注意：信用卡支付将以美元结算，具体汇率以银行为准',
                                style: TextStyle(fontSize: 12, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (RegionConfig.currentRegion == RegionType.domestic)
                      const SizedBox(height: AppDimensions.spacingMd),
                    const Text('如果浏览器没有自动打开，请选择以下操作：', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: AppDimensions.spacingLg),
                    // 显示支付URL（截断显示）
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingSm),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        state.paymentUrl.length > 50
                          ? '${state.paymentUrl.substring(0, 50)}...'
                          : state.paymentUrl,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // 尝试再次打开URL
                      try {
                        final uri = Uri.parse(state.paymentUrl);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        AppLogger.d('[OrderConfirmPage] 手动打开URL失败: $e');
                      }
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('打开链接'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // 复制链接到剪贴板
                      Clipboard.setData(ClipboardData(text: state.paymentUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('支付链接已复制到剪贴板'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('复制链接'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // 跳转到订单列表（不指定状态，显示全部订单）
                      context.go('/orders');
                    },
                    child: const Text('查看订单'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('确认订单'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品信息卡片
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
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
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.borderInput,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(Icons.image, size: 40, color: AppColors.textTertiary),
                        ),
                      const SizedBox(width: AppDimensions.spacingLg),
                      // 商品名称和价格
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.displayProductName ?? widget.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              PriceFormatter.format(widget.price),
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
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXxl),

              // 订单总结
              const Text(
                '订单摘要',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // 订单摘要列表
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('商品金额'),
                        Text(PriceFormatter.format(widget.price)),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
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
                          PriceFormatter.format(widget.price * widget.quantity),
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
              Text(
                RegionConfig.currentRegion == RegionType.domestic ? '支付方式' : 'Payment Method',
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
                  onPressed: _isProcessing ? null : _confirmOrder, // 处理中时禁用按钮
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
                          '${RegionConfig.currentRegion == RegionType.domestic ? "确认支付" : "Pay Now"} ${RegionConfig.formatPrice(widget.price * widget.quantity)}',
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

  /// 构建支付方式选项（基于PaymentMethod枚举）
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

  /// 确认订单
  void _confirmOrder() {
    // 防重复点击检查
    if (_isProcessing) {
      AppLogger.d('[OrderConfirmPage] 正在处理中，忽略重复点击');
      return;
    }

    AppLogger.d('[OrderConfirmPage] 开始创建订单并支付 - 商品: ${widget.productName}, 支付方式: $_selectedPaymentMethod');

    // 设置BuildContext给PaymentBloc，用于Stripe支付的WebView
    context.read<PaymentBloc>().setContext(context);

    // 发起创建订单并支付事件
    context.read<PaymentBloc>().add(
      CreateOrderAndPayEvent(
        productId: widget.productId,
        variantId: widget.variantId,
        quantity: widget.quantity,
        sellerId: widget.sellerId,
        price: widget.price,
        chatRoomId: widget.chatRoomId,
        productName: widget.productName,
        imageUrl: widget.imageUrl,
        paymentMethod: _selectedPaymentMethod.code, // 传递选择的支付方式代码
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
