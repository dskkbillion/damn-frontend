import 'package:equatable/equatable.dart';

/// 购物车摘要信息
class CartSummary extends Equatable {
  /// 商品总数 (种类数)
  final int itemCount;
  
  /// 商品总件数
  final int totalQuantity;
  
  /// 商品金额小计
  final double subtotal;
  
  /// 折扣金额
  final double discountAmount;
  
  /// 运费估算 (可选)
  final double? shippingEstimate;
  
  /// 税费估算 (可选)
  final double? taxEstimate;
  
  /// 最终合计金额
  final double total;

  const CartSummary({
    required this.itemCount,
    required this.totalQuantity,
    required this.subtotal,
    required this.discountAmount,
    this.shippingEstimate,
    this.taxEstimate,
    required this.total,
  });

  /// 创建一个空的购物车摘要
  factory CartSummary.empty() {
    return const CartSummary(
      itemCount: 0,
      totalQuantity: 0,
      subtotal: 0.0,
      discountAmount: 0.0,
      total: 0.0,
    );
  }

  @override
  List<Object?> get props => [
    itemCount, 
    totalQuantity, 
    subtotal, 
    discountAmount, 
    shippingEstimate, 
    taxEstimate, 
    total
  ];
}