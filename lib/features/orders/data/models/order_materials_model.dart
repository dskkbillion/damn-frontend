import '../../domain/entities/order_materials.dart';

/// 订单材料数据模型
class OrderMaterialsModel extends OrderMaterials {
  const OrderMaterialsModel({
    required super.id,
    required super.productId,
    required super.orderId,
    required super.features,
    required super.files,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderMaterialsModel.fromJson(Map<String, dynamic> json) {
    // 解析features - 后端返回的是List<JSONObject>格式
    List<MaterialFeature> features = [];
    if (json['feature'] != null) {
      final featureList = json['feature'] as List<dynamic>;
      features = featureList.map((item) {
        if (item is Map<String, dynamic>) {
          return MaterialFeature.fromJson(item);
        }
        return const MaterialFeature(question: '', answer: '');
      }).toList();
    }

    // 解析files - 后端返回的是List<String>格式
    List<String> files = [];
    if (json['files'] != null) {
      final filesList = json['files'] as List<dynamic>;
      files = filesList.map((item) => item.toString()).toList();
    }

    return OrderMaterialsModel(
      id: json['id'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      features: features,
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
      'productId': productId,
      'orderId': orderId,
      'feature': features.map((f) => f.toJson()).toList(),
      'files': files,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OrderMaterials toEntity() {
    return OrderMaterials(
      id: id,
      productId: productId,
      orderId: orderId,
      features: features,
      files: files,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}