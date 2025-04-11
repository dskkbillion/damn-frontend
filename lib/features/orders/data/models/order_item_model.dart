import 'package:equatable/equatable.dart';

import '../../domain/entities/order_item.dart';

/// Data Transfer Object (DTO) for an order item, matching the API structure.
class OrderItemModel extends Equatable {
  final int id; // 假设 API 返回 id
  final int orderId; // 假设 API 返回 orderId
  final int spuId; // API 字段: spuId (映射到 productId)
  final String spuName; // API 字段: spuName (映射到 productName)
  final int skuId; // API 字段: skuId
  final String? properties; // API: properties (array of objects), mapped to skuName
  final String picUrl; // API 字段: picUrl (映射到 imageUrl)
  final int quantity; // API 字段: quantity
  final double price; // API 字段: price
  final double payPrice; // API: payPrice (mapped to totalPrice in entity)

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.spuId,
    required this.spuName,
    required this.skuId,
    this.properties,
    required this.picUrl,
    required this.quantity,
    required this.price,
    required this.payPrice,
  });

  /// Factory constructor to create an OrderItemModel from a JSON map.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // TODO: Handle complex 'properties' array from API if necessary
    String? parsedProperties = json['properties']?.toString(); // Simple toString for now
    // if (json['properties'] is List && (json['properties'] as List).isNotEmpty) {
      // Implement logic to extract/format relevant info from properties list
      // parsedProperties = (json['properties'] as List).map((p) => "${p['name']}:${p['value']}").join(' ');
    // }

    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      spuId: json['spuId'] as int? ?? 0,
      spuName: json['spuName'] as String? ?? 'Unknown Product',
      skuId: json['skuId'] as int? ?? 0,
      properties: parsedProperties, // Use parsed properties
      picUrl: json['picUrl'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      payPrice: (json['payPrice'] as num?)?.toDouble() ?? 0.0, // Use payPrice from JSON
    );
  }

  /// Converts this Data Transfer Object to a Domain [OrderItem] entity.
  OrderItem toEntity() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: spuId,
      productName: spuName,
      skuId: skuId,
      skuName: properties, // Map properties (as String for now) to skuName
      imageUrl: picUrl,
      quantity: quantity,
      price: price,
      totalPrice: payPrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        spuId,
        spuName,
        skuId,
        properties,
        picUrl,
        quantity,
        price,
        payPrice,
      ];
} 