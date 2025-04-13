import 'package:equatable/equatable.dart';

/// 表示订单的支付相关信息。
class OrderPaymentInfo extends Equatable {
  /// 是否已支付。
  final bool payStatus;

  /// 支付时间 (如果已支付)。
  final DateTime? payTime;

  /// 支付渠道代码 (例如 "wx_lite", "alipay_app")。
  final String? payChannelCode;

  /// 创建一个 [OrderPaymentInfo] 实例。
  const OrderPaymentInfo({
    required this.payStatus,
    this.payTime,
    this.payChannelCode,
  });

  // Add an empty factory constructor or static constant
  static final OrderPaymentInfo empty = OrderPaymentInfo(
    payStatus: false,
    payTime: null,
    payChannelCode: null,
  );

  @override
  List<Object?> get props => [payStatus, payTime, payChannelCode];
} 