import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'cart_summary.dart';
import 'cart_validation_result.dart';

/// 购物车整体状态实体
class Cart extends Equatable {
  /// 购物车唯一标识 (可能与用户ID关联)
  final String id;
  
  /// 购物车中的商品项列表
  final List<CartItem> items;
  
  /// 购物车摘要信息
  final CartSummary summary;
  
  /// 当前应用的优惠券 (可选)
  final Coupon? appliedCoupon;
  
  /// 可用的优惠券列表 (可选)
  final List<Coupon>? availableCoupons;
  
  /// 购物车校验结果 (可选)
  final CartValidationResult? validationResult;

  const Cart({
    required this.id,
    required this.items,
    required this.summary,
    this.appliedCoupon,
    this.availableCoupons,
    this.validationResult,
  });

  /// 创建一个空的购物车
  factory Cart.empty({required String userId}) {
    return Cart(
      id: userId,
      items: const [],
      summary: CartSummary.empty(),
      validationResult: CartValidationResult.valid(),
    );
  }

  /// 检查购物车是否为空
  bool get isEmpty => items.isEmpty;

  /// 检查购物车是否不为空
  bool get isNotEmpty => items.isNotEmpty;

  /// 获取购物车中的商品数量
  int get itemCount => items.length;

  /// 获取购物车中的商品总件数
  int get totalQuantity => summary.totalQuantity;

  /// 获取购物车中的商品总价
  double get totalPrice => summary.total;

  /// 检查购物车是否有效可以结算
  bool get isValidForCheckout => validationResult?.isValidForCheckout ?? true;

  /// 根据商品ID查找购物车项
  CartItem? findItemByProductId(String productId, {String? skuId}) {
    return items.firstWhere(
      (item) => item.productId == productId && item.skuId == skuId,
      orElse: () => null as CartItem, // 这里使用null作为默认值，但由于返回类型是CartItem?，所以需要强制转换
    );
  }

  /// 根据购物车项ID查找购物车项
  CartItem? findItemById(String cartItemId) {
    return items.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => null as CartItem, // 这里使用null作为默认值，但由于返回类型是CartItem?，所以需要强制转换
    );
  }

  @override
  List<Object?> get props => [
    id, 
    items, 
    summary, 
    appliedCoupon, 
    availableCoupons, 
    validationResult
  ];
}

/// 优惠券实体 (简化版，实际可能定义在Promotion或Core模块)
class Coupon extends Equatable {
  /// 优惠券ID
  final String id;
  
  /// 优惠券代码
  final String code;
  
  /// 优惠券描述
  final String description;
  
  /// 折扣值
  final double discountValue;
  
  /// 是否为百分比折扣
  final bool isPercentage;
  
  /// 最低消费要求
  final double? minimumPurchase;
  
  /// 有效期开始时间
  final DateTime? validFrom;
  
  /// 有效期结束时间
  final DateTime? validTo;

  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountValue,
    required this.isPercentage,
    this.minimumPurchase,
    this.validFrom,
    this.validTo,
  });

  @override
  List<Object?> get props => [
    id, 
    code, 
    description, 
    discountValue, 
    isPercentage, 
    minimumPurchase, 
    validFrom, 
    validTo
  ];
}