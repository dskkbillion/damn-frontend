import '../../domain/entities/order_delivery.dart';

/// 订单交付数据模型
class OrderDeliveryModel extends OrderDelivery {
  const OrderDeliveryModel({
    required super.id,
    required super.orderId,
    required super.content,
    required super.files,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderDeliveryModel.fromJson(Map<String, dynamic> json) {
    // 解析files - 后端返回的是List<String>格式
    List<String> files = [];
    if (json['files'] != null) {
      final filesList = json['files'] as List<dynamic>;
      files = filesList.map((item) => item.toString()).toList();
    }

    return OrderDeliveryModel(
      id: json['id'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      files: files,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'content': content,
      'files': files,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OrderDelivery toEntity() {
    return OrderDelivery(
      id: id,
      orderId: orderId,
      content: content,
      files: files,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}