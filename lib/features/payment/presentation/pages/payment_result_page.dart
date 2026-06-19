import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';

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

  // success 分支专用计数器/上限，与 pending 的 _pollAttempt 隔离，避免串到 pending 的进度文案。
  int _successPollAttempt = 0;
  static const int _maxSuccessPolls = 3;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    if (_status == PaymentResultStatus.pending) {
      _startPolling();
    } else if (_status == PaymentResultStatus.success) {
      // success 直跳时 Stripe webhook 可能尚未把订单落库，#373 在返回详情页时会拉一次，
      // 但那一拉可能早于 webhook。这里用一次短轮询「预热」后端状态（≤9s），
      // 待订单流转出 awaitingPayment 后用户再点「查看订单详情」，详情页便能拿到新状态。
      // TODO(中期): 迁移到 OrderDetailPage 的 RouteAware didPopNext 自刷新，届时可删除本预热轮询。
      _startSuccessPolling();
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
    final getOrderDetail = getIt<GetOrderDetailUseCase>();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollAttempt++;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
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
        final result = await getOrderDetail(orderIdInt);
        if (!mounted) return;
        result.fold(
          (failure) => AppLogger.d('[PaymentResult] poll #$_pollAttempt failed: $failure'),
          (order) {
            AppLogger.d('[PaymentResult] poll #$_pollAttempt state=${order.state}');
            if (order.state != OrderStatus.awaitingPayment &&
                order.state != OrderStatus.canceled) {
              timer.cancel();
              setState(() {
                _status = PaymentResultStatus.success;
              });
            }
          },
        );
      } catch (e) {
        AppLogger.d('[PaymentResult] poll #$_pollAttempt exception: $e');
      }
    });
  }

  // success 直跳场景：后台静默轮询订单状态，等 Stripe webhook 落库（每 3s 一次，最多 3 次 = 9s）。
  // 命中即停，不修改 _status（页面已是 success），仅用于让后端状态先于「查看订单详情」翻转，
  // 这样返回详情页时 #373 的 LoadOrderDetail 能拉到新状态而非 awaitingPayment。
  void _startSuccessPolling() {
    final orderIdInt = int.tryParse(widget.orderId ?? '');
    if (orderIdInt == null) return;
    final getOrderDetail = getIt<GetOrderDetailUseCase>();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _successPollAttempt++;
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_successPollAttempt > _maxSuccessPolls) {
        timer.cancel();
        return;
      }
      try {
        final result = await getOrderDetail(orderIdInt);
        if (!mounted) return;
        result.fold(
          (failure) => AppLogger.d(
              '[PaymentResult] success-poll #$_successPollAttempt failed: $failure'),
          (order) {
            AppLogger.d(
                '[PaymentResult] success-poll #$_successPollAttempt state=${order.state}');
            if (order.state != OrderStatus.awaitingPayment &&
                order.state != OrderStatus.canceled) {
              timer.cancel();
            }
          },
        );
      } catch (e) {
        AppLogger.d(
            '[PaymentResult] success-poll #$_successPollAttempt exception: $e');
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
                              final orderId = widget.orderId;
                              if (orderId == null) {
                                _exitPaymentFlow(context);
                                return;
                              }
                              // #390: 回到已存在的原始 OrderDetailPage（name=='orderDetail'），
                              // 而非 push 第二个详情页；found 标志 + route.isFirst 双重防穿。
                              final navigator =
                                  Navigator.of(context, rootNavigator: true);
                              var found = false;
                              navigator.popUntil((route) {
                                if (route.settings.name == 'orderDetail') {
                                  found = true;
                                  return true;
                                }
                                return route.isFirst;
                              });
                              if (!found) {
                                AppLogger.w(
                                    '[#390] 原始 OrderDetailPage 不在栈中，走兜底 go 导航');
                                context.go('/orderDetail/$orderId');
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
