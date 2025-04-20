import 'package:equatable/equatable.dart';

/// 购物车事件基类
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// 加载购物车事件
class LoadCart extends CartEvent {
  const LoadCart();
}

/// 添加商品到购物车事件
class AddItemToCart extends CartEvent {
  final String productId;
  final String? skuId;
  final int quantity;

  const AddItemToCart({
    required this.productId,
    this.skuId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, skuId, quantity];
}

/// 更新购物车项数量事件
class UpdateCartItemQuantity extends CartEvent {
  final String cartItemId;
  final int newQuantity;

  const UpdateCartItemQuantity({
    required this.cartItemId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [cartItemId, newQuantity];
}

/// 移除购物车项事件
class RemoveCartItem extends CartEvent {
  final String cartItemId;

  const RemoveCartItem({
    required this.cartItemId,
  });

  @override
  List<Object> get props => [cartItemId];
}

/// 批量移除购物车项事件
class RemoveCartItems extends CartEvent {
  final List<String> cartItemIds;

  const RemoveCartItems({
    required this.cartItemIds,
  });

  @override
  List<Object> get props => [cartItemIds];
}

/// 清空购物车事件
class ClearCart extends CartEvent {
  const ClearCart();
}

/// 应用优惠券事件
class ApplyCoupon extends CartEvent {
  final String couponCode;

  const ApplyCoupon({
    required this.couponCode,
  });

  @override
  List<Object> get props => [couponCode];
}

/// 移除优惠券事件
class RemoveCoupon extends CartEvent {
  final String couponCode;

  const RemoveCoupon({
    required this.couponCode,
  });

  @override
  List<Object> get props => [couponCode];
}

/// 启动结算事件
class ProceedToCheckout extends CartEvent {
  final List<String>? cartItemIds;
  final String? selectedAddressId;
  final String? selectedShippingMethodId;
  final String? couponCode;
  final String? note;

  const ProceedToCheckout({
    this.cartItemIds,
    this.selectedAddressId,
    this.selectedShippingMethodId,
    this.couponCode,
    this.note,
  });

  @override
  List<Object?> get props => [
    cartItemIds,
    selectedAddressId,
    selectedShippingMethodId,
    couponCode,
    note,
  ];
}