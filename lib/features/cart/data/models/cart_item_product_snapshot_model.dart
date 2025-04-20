import '../../domain/entities/cart_item_product_snapshot.dart';

/// 加入购物车时的商品信息快照模型
class CartItemProductSnapshotModel extends CartItemProductSnapshot {
  const CartItemProductSnapshotModel({
    required String name,
    String? imageUrl,
    String? skuDescription,
    required double priceAtAddition,
  }) : super(
          name: name,
          imageUrl: imageUrl,
          skuDescription: skuDescription,
          priceAtAddition: priceAtAddition,
        );

  /// 从JSON映射创建模型
  factory CartItemProductSnapshotModel.fromJson(Map<String, dynamic> json) {
    return CartItemProductSnapshotModel(
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      skuDescription: json['skuDescription'] as String?,
      priceAtAddition: (json['priceAtAddition'] is int)
          ? (json['priceAtAddition'] as int).toDouble()
          : json['priceAtAddition'] as double,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'skuDescription': skuDescription,
      'priceAtAddition': priceAtAddition,
    };
  }

  /// 从实体创建模型
  factory CartItemProductSnapshotModel.fromEntity(CartItemProductSnapshot entity) {
    return CartItemProductSnapshotModel(
      name: entity.name,
      imageUrl: entity.imageUrl,
      skuDescription: entity.skuDescription,
      priceAtAddition: entity.priceAtAddition,
    );
  }
}