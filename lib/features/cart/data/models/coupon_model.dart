import '../../domain/entities/cart.dart';

/// 优惠券模型
class CouponModel extends Coupon {
  const CouponModel({
    required String id,
    required String code,
    required String description,
    required double discountValue,
    required bool isPercentage,
    double? minimumPurchase,
    DateTime? validFrom,
    DateTime? validTo,
  }) : super(
          id: id,
          code: code,
          description: description,
          discountValue: discountValue,
          isPercentage: isPercentage,
          minimumPurchase: minimumPurchase,
          validFrom: validFrom,
          validTo: validTo,
        );

  /// 从JSON映射创建模型
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'].toString(),
      code: json['code'] as String,
      description: json['description'] as String,
      discountValue: json['discountValue'] is int
          ? (json['discountValue'] as int).toDouble()
          : json['discountValue'] as double,
      isPercentage: json['isPercentage'] as bool? ?? false,
      minimumPurchase: json['minimumPurchase'] != null
          ? (json['minimumPurchase'] is int
              ? (json['minimumPurchase'] as int).toDouble()
              : json['minimumPurchase'] as double)
          : null,
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validTo: json['validTo'] != null
          ? DateTime.parse(json['validTo'] as String)
          : null,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountValue': discountValue,
      'isPercentage': isPercentage,
      'minimumPurchase': minimumPurchase,
      'validFrom': validFrom?.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
    };
  }

  /// 从实体创建模型
  factory CouponModel.fromEntity(Coupon entity) {
    return CouponModel(
      id: entity.id,
      code: entity.code,
      description: entity.description,
      discountValue: entity.discountValue,
      isPercentage: entity.isPercentage,
      minimumPurchase: entity.minimumPurchase,
      validFrom: entity.validFrom,
      validTo: entity.validTo,
    );
  }
}