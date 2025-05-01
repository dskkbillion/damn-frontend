import 'package:dskk_flutter_refactor/features/seller/domain/entities/order_product_item.dart';

/// 订单商品项数据传输对象
/// 用于处理API响应中的商品项数据
class OrderProductItemDto {
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
  
  /// 商品图片URL
  final String imageUrl;
  
  /// 购买数量
  final int quantity;
  
  /// 单价
  final int unitPrice;
  
  /// 总价
  final int totalPrice;
  
  /// 支付价格
  final int payPrice;

  /// 构造函数
  const OrderProductItemDto({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.variantId,
    this.variantName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.payPrice,
  });

  /// 从JSON映射创建DTO实例
  factory OrderProductItemDto.fromJson(Map<String, dynamic> json) {
    return OrderProductItemDto(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      variantId: json['variantId'] as int,
      variantName: json['variantName'] as String?,
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toInt(),
      payPrice: (json['payPrice'] as num).toInt(),
    );
  }

  /// 转换为领域实体
  OrderProductItem toEntity() {
    return OrderProductItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      variantId: variantId,
      variantName: variantName,
      imageUrl: imageUrl,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      payPrice: payPrice,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'variantId': variantId,
      'variantName': variantName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'payPrice': payPrice,
    };
  }
} 