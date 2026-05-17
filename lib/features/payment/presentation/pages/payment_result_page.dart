import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';

enum PaymentResultStatus { success, failure, pending }

class PaymentResultPage extends StatefulWidget {
  final PaymentResultStatus initialStatus;
  final String? orderId;
  final String? errorMessage;

  const PaymentResultPage({
    super.key,
    required this.initialStatus,
    this.orderId,
    this.errorMessage,
  });

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  late PaymentResultStatus _status;
  Timer? _pollTimer;
  int _pollAttempt = 0;
  static const int _maxPolls = 6;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    if (_status == PaymentResultStatus.pending) {
      _startPolling();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // #326: pending 时轮询后端订单状态,如果已支付就转 success
  // 给 Stripe webhook 留足时间(每 3s 一次,最多 6 次 = 18s)
  void _startPolling() {
    final orderIdInt = int.tryParse(widget.orderId ?? '');
    if (orderIdInt == null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollAttempt++;
      if (_pollAttempt > _maxPolls) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _status = PaymentResultStatus.failure;
          });
        }
        return;
      }
      try {
        final bloc = context.read<OrderDetailBloc>();
        bloc.add(LoadOrderDetail(orderId: orderIdInt));
        await bloc.stream.firstWhere(
          (state) => state is OrderDetailLoaded || state is OrderDetailError,
        );
        if (!mounted) return;
        final state = bloc.state;
        if (state is OrderDetailLoaded) {
          if (state.order.state != OrderStatus.awaitingPayment &&
              state.order.state != OrderStatus.canceled) {
            timer.cancel();
            setState(() {
              _status = PaymentResultStatus.success;
            });
          }
        }
      } catch (_) {
        // 网络异常静默重试
      }
    });
  }

  void _exitPaymentFlow(BuildContext context) {
    context.go('/profile/orders');
  }

  String get _title => switch (_status) {
        PaymentResultStatus.success => '支付成功',
        PaymentResultStatus.failure => '支付失败',
        PaymentResultStatus.pending => '正在确认支付',
      };

  IconData get _icon => switch (_status) {
        PaymentResultStatus.success => Icons.check_circle,
        PaymentResultStatus.failure => Icons.error,
        PaymentResultStatus.pending => Icons.hourglass_top,
      };

  Color get _iconColor => switch (_status) {
        PaymentResultStatus.success => AppColors.success,
        PaymentResultStatus.failure => AppColors.error,
        PaymentResultStatus.pending => Colors.orange,
      };

  String get _detailText {
    switch (_status) {
      case PaymentResultStatus.success:
        return widget.orderId != null ? '订单 ${widget.orderId} 已支付完成' : '支付已完成';
      case PaymentResultStatus.pending:
        return '正在向后端确认订单状态(第 $_pollAttempt/$_maxPolls 次),稍后将自动跳转';
      case PaymentResultStatus.failure:
        return widget.errorMessage ?? '支付过程中出现错误';
    }
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
          title: Text(_title),
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
                  Icon(_icon, size: 80, color: _iconColor),
                  const SizedBox(height: AppDimensions.spacingXxl),
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  if (_status == PaymentResultStatus.pending) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _detailText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (_status == PaymentResultStatus.success) ...[
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
                              '提示:订单状态可能需要几分钟更新,请稍后查看',
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
                  const SizedBox(height: 32),
                  if (_status != PaymentResultStatus.pending)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_status == PaymentResultStatus.success) ...[
                          ElevatedButton(
                            onPressed: () {
                              if (widget.orderId != null) {
                                context.push('/orderDetail/${widget.orderId}');
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
                            backgroundColor: _status == PaymentResultStatus.success
                                ? AppColors.borderPrimary
                                : null,
                            foregroundColor: _status == PaymentResultStatus.success
                                ? AppColors.textPrimary
                                : null,
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
