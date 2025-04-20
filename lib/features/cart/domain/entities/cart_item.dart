import 'package:equatable/equatable.dart';
import 'cart_item_product_snapshot.dart';

/// 购物车中的单个商品项
class CartItem extends Equatable {
  /// 购物车项唯一标识
  final String id;
  
  /// 商品ID
  final String productId;
  
  /// 商品规格ID (如果适用)
  final String? skuId;
  
  /// 数量
  final int quantity;
  
  /// 加入购物车时的商品信息快照
  final CartItemProductSnapshot productSnapshot;
  
  /// 当前实时单价 (可选，可能从后端获取)
  final double? currentPrice;
  
  /// 当前实时行总价 (可选)
  final double? lineTotal;
  
  /// 当前是否可购买/有库存 (可选)
  final bool? isAvailable;
  
  /// 针对此项的验证信息 (如"库存不足", "价格已变更")
  final List<String>? validationMessages;

  const CartItem({
    required this.id,
    required this.productId,
    this.skuId,
    required this.quantity,
    required this.productSnapshot,
    this.currentPrice,
    this.lineTotal,
    this.isAvailable,
    this.validationMessages,
  });

  /// 获取行总价，如果有实时价格则使用实时价格，否则使用快照价格
  double get total => lineTotal ?? (currentPrice ?? productSnapshot.priceAtAddition) * quantity;

  /// 创建一个新的CartItem实例，但更新数量
  CartItem copyWithNewQuantity(int newQuantity) {
    return CartItem(
      id: id,
      productId: productId,
      skuId: skuId,
      quantity: newQuantity,
      productSnapshot: productSnapshot,
      currentPrice: currentPrice,
      lineTotal: lineTotal,
      isAvailable: isAvailable,
      validationMessages: validationMessages,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    productId, 
    skuId, 
    quantity, 
    productSnapshot, 
    currentPrice, 
    lineTotal, 
    isAvailable, 
    validationMessages
  ];
}