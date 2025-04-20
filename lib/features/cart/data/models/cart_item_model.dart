import '../../domain/entities/cart_item.dart';
import 'cart_item_product_snapshot_model.dart';

/// 购物车中的单个商品项模型
class CartItemModel extends CartItem {
  const CartItemModel({
    required String id,
    required String productId,
    String? skuId,
    required int quantity,
    required CartItemProductSnapshotModel productSnapshot,
    double? currentPrice,
    double? lineTotal,
    bool? isAvailable,
    List<String>? validationMessages,
  }) : super(
          id: id,
          productId: productId,
          skuId: skuId,
          quantity: quantity,
          productSnapshot: productSnapshot,
          currentPrice: currentPrice,
          lineTotal: lineTotal,
          isAvailable: isAvailable,
          validationMessages: validationMessages,
        );

  /// 从JSON映射创建模型
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      productId: json['productId'].toString(),
      skuId: json['variantId'] != null ? json['variantId'].toString() : null,
      quantity: json['number'] as int,
      productSnapshot: CartItemProductSnapshotModel.fromJson({
        'name': json['product']['name'] as String,
        'imageUrl': json['product']['mainImage'] as String?,
        'skuDescription': json['variant'] != null ? json['variant']['name'] as String? : null,
        'priceAtAddition': double.tryParse(json['variant'] != null 
            ? json['variant']['sellingPrice'] as String 
            : json['product']['sellingPrice'] as String) ?? 0.0,
      }),
      currentPrice: json['variant'] != null 
          ? double.tryParse(json['variant']['sellingPrice'] as String) 
          : double.tryParse(json['product']['sellingPrice'] as String),
      isAvailable: json['state'] == 'NORMAL',
      validationMessages: json['state'] == 'INVALID' 
          ? ['商品已下架或库存不足'] 
          : null,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'variantId': skuId,
      'number': quantity,
      // 其他字段不需要发送到服务器，因为它们是从服务器获取的
    };
  }

  /// 从实体创建模型
  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      skuId: entity.skuId,
      quantity: entity.quantity,
      productSnapshot: CartItemProductSnapshotModel.fromEntity(entity.productSnapshot),
      currentPrice: entity.currentPrice,
      lineTotal: entity.lineTotal,
      isAvailable: entity.isAvailable,
      validationMessages: entity.validationMessages,
    );
  }
}