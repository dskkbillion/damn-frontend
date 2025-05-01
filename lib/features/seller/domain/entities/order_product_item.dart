import 'package:equatable/equatable.dart';

/// 订单商品项实体
/// 表示售后退款申请中的商品项
class OrderProductItem extends Equatable {
  /// 商品项ID
  final int id;
  
  /// 订单ID
  final int orderId;
  
  /// 商品ID
  final int productId;
  
  /// 商品名称
  final String productName;
  
  /// 商品SKU ID
  final int variantId;
  
  /// 商品规格名称
  final String? variantName;
  
  /// 商品规格值
  final List<String>? variantValues;
  
  /// 商品图片URL
  final String imageUrl;
  
  /// 购买数量
  final int quantity;
  
  /// 单价（分）
  final int unitPrice;
  
  /// 总价（分）
  final int totalPrice;
  
  /// 支付价格（分）
  final int payPrice;

  /// 构造函数
  const OrderProductItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.variantId,
    this.variantName,
    this.variantValues,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.payPrice,
  });

  /// 获取格式化的单价（元）
  double get formattedUnitPrice => unitPrice / 100;
  
  /// 获取格式化的总价（元）
  double get formattedTotalPrice => totalPrice / 100;
  
  /// 获取格式化的支付价格（元）
  double get formattedPayPrice => payPrice / 100;

  /// 获取商品规格描述
  String get variantDescription {
    if (variantValues != null && variantValues!.isNotEmpty) {
      return variantValues!.join(' ');
    } else if (variantName != null && variantName!.isNotEmpty) {
      return variantName!;
    } else {
      return '';
    }
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    productName,
    variantId,
    variantName,
    variantValues,
    imageUrl,
    quantity,
    unitPrice,
    totalPrice,
    payPrice,
  ];
} 