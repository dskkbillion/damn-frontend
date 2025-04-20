import 'package:equatable/equatable.dart';

/// 加入购物车时的商品信息快照，用于展示，避免因商品信息变更导致混乱
class CartItemProductSnapshot extends Equatable {
  /// 商品名称
  final String name;
  
  /// 商品主图URL
  final String? imageUrl;
  
  /// 规格描述
  final String? skuDescription;
  
  /// 加入时的单价
  final double priceAtAddition;

  const CartItemProductSnapshot({
    required this.name,
    this.imageUrl,
    this.skuDescription,
    required this.priceAtAddition,
  });

  @override
  List<Object?> get props => [name, imageUrl, skuDescription, priceAtAddition];
}