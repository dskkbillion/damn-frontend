import '../../domain/entities/cart_summary.dart';

/// 购物车摘要信息模型
class CartSummaryModel extends CartSummary {
  const CartSummaryModel({
    required int itemCount,
    required int totalQuantity,
    required double subtotal,
    required double discountAmount,
    double? shippingEstimate,
    double? taxEstimate,
    required double total,
  }) : super(
          itemCount: itemCount,
          totalQuantity: totalQuantity,
          subtotal: subtotal,
          discountAmount: discountAmount,
          shippingEstimate: shippingEstimate,
          taxEstimate: taxEstimate,
          total: total,
        );

  /// 从JSON映射创建模型
  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    // 这里假设后端不直接提供摘要信息，需要从购物车项列表计算
    // 实际实现可能需要根据后端API调整
    return CartSummaryModel(
      itemCount: json['itemCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      subtotal: json['subtotal'] != null 
          ? (json['subtotal'] is int 
              ? (json['subtotal'] as int).toDouble() 
              : json['subtotal'] as double)
          : 0.0,
      discountAmount: json['discountAmount'] != null 
          ? (json['discountAmount'] is int 
              ? (json['discountAmount'] as int).toDouble() 
              : json['discountAmount'] as double)
          : 0.0,
      shippingEstimate: json['shippingEstimate'] != null 
          ? (json['shippingEstimate'] is int 
              ? (json['shippingEstimate'] as int).toDouble() 
              : json['shippingEstimate'] as double)
          : null,
      taxEstimate: json['taxEstimate'] != null 
          ? (json['taxEstimate'] is int 
              ? (json['taxEstimate'] as int).toDouble() 
              : json['taxEstimate'] as double)
          : null,
      total: json['total'] != null 
          ? (json['total'] is int 
              ? (json['total'] as int).toDouble() 
              : json['total'] as double)
          : 0.0,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'shippingEstimate': shippingEstimate,
      'taxEstimate': taxEstimate,
      'total': total,
    };
  }

  /// 从实体创建模型
  factory CartSummaryModel.fromEntity(CartSummary entity) {
    return CartSummaryModel(
      itemCount: entity.itemCount,
      totalQuantity: entity.totalQuantity,
      subtotal: entity.subtotal,
      discountAmount: entity.discountAmount,
      shippingEstimate: entity.shippingEstimate,
      taxEstimate: entity.taxEstimate,
      total: entity.total,
    );
  }

  /// 从购物车项列表计算摘要信息
  factory CartSummaryModel.calculate(List<dynamic> cartItems) {
    int itemCount = cartItems.length;
    int totalQuantity = 0;
    double subtotal = 0.0;
    
    for (var item in cartItems) {
      totalQuantity += item['number'] as int;
      
      // 计算小计，优先使用variant价格，如果没有则使用product价格
      double price = 0.0;
      if (item['variant'] != null && item['variant']['sellingPrice'] != null) {
        price = double.tryParse(item['variant']['sellingPrice'] as String) ?? 0.0;
      } else if (item['product'] != null && item['product']['sellingPrice'] != null) {
        price = double.tryParse(item['product']['sellingPrice'] as String) ?? 0.0;
      }
      
      subtotal += price * (item['number'] as int);
    }
    
    // 这里简化处理，实际可能需要考虑优惠券等因素
    double discountAmount = 0.0;
    double total = subtotal - discountAmount;
    
    return CartSummaryModel(
      itemCount: itemCount,
      totalQuantity: totalQuantity,
      subtotal: subtotal,
      discountAmount: discountAmount,
      total: total,
    );
  }
}