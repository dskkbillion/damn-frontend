import 'package:equatable/equatable.dart';

import '../../domain/entities/order_item.dart';

/// Data Transfer Object (DTO) for an order item, matching the API structure from /api/shop/order/list.
class OrderItemModel extends Equatable {
  final int id;
  final int orderId;
  final int productId;       // Changed from spuId, matches API key
  final String productName;   // Changed from spuName, matches API key
  final int variantId;       // Changed from skuId, matches API key
  final String? variantName;  // Added, matches API key
  final String? imageUrl;     // Changed from picUrl, nullable as it might be missing in list API
  final int quantity;
  final double? unitPrice;    // Changed from price, matches API key (handling integer)
  final double? totalPrice;   // Added, matches API key (handling integer)
  final double? payPrice;     // Kept, matches API key (handling integer)

  // Removed: spuId, spuName, skuId, properties, picUrl, price

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.variantId,
    this.variantName,
    this.imageUrl,         // Nullable
    required this.quantity,
    this.unitPrice,
    this.totalPrice,
    required this.payPrice, // Assuming payPrice is most reliable?
  });

  /// Factory constructor to create an OrderItemModel from a JSON map.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Attempt to get image URL from common possible keys
    final imgUrl = json['productImage'] as String?      // From description text?
                ?? json['picUrl'] as String?           // From old model?
                ?? json['imageUrl'] as String?;         // Generic guess?
                // If none found, it remains null

    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      productName: json['productName'] as String? ?? 'Unknown Product',
      variantId: json['variantId'] as int? ?? 0,
      variantName: json['variantName'] as String?,
      imageUrl: imgUrl, // Use parsed image url
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(), // Use unitPrice key
      totalPrice: (json['totalPrice'] as num?)?.toDouble(), // Use totalPrice key
      payPrice: (json['payPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this Data Transfer Object to a Domain [OrderItem] entity.
  OrderItem toEntity() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      skuId: variantId,       // Map variantId to skuId
      skuName: variantName,   // Map variantName to skuName
      imageUrl: imageUrl ?? '', // Use imageUrl, provide default if null
      quantity: quantity,
      price: unitPrice ?? 0.0, // Map unitPrice to price
      totalPrice: payPrice ?? 0.0, // Map payPrice to totalPrice (common practice for final item price paid)
                                   // Alternatively, use totalPrice from API if it represents item total before discounts
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        variantId,
        variantName,
        imageUrl,
        quantity,
        unitPrice,
        totalPrice,
        payPrice,
      ];
} 