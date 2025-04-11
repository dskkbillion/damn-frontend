import 'package:equatable/equatable.dart';

/// 表示订单的价格汇总信息。
class OrderPriceSummary extends Equatable {
  /// 商品总金额。
  final double totalPrice;

  /// 优惠金额。
  final double discountPrice;

  /// 运费。
  final double deliveryPrice;

  /// 实际支付金额。
  final double payPrice;

  /// 创建一个 [OrderPriceSummary] 实例。
  ///
  /// 注意：价格使用 double 类型存储，对于高精度计算，
  /// 可以考虑引入 decimal 或类似的库。
  const OrderPriceSummary({
    required this.totalPrice,
    required this.discountPrice,
    required this.deliveryPrice,
    required this.payPrice,
  });

  @override
  List<Object?> get props => [
        totalPrice,
        discountPrice,
        deliveryPrice,
        payPrice,
      ];
} 