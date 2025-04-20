import '../../domain/entities/cart.dart';
import 'cart_item_model.dart';
import 'cart_summary_model.dart';
import 'cart_validation_result_model.dart';
import 'coupon_model.dart';

/// 购物车整体状态模型
class CartModel extends Cart {
  const CartModel({
    required String id,
    required List<CartItemModel> items,
    required CartSummaryModel summary,
    CouponModel? appliedCoupon,
    List<CouponModel>? availableCoupons,
    CartValidationResultModel? validationResult,
  }) : super(
          id: id,
          items: items,
          summary: summary,
          appliedCoupon: appliedCoupon,
          availableCoupons: availableCoupons,
          validationResult: validationResult,
        );

  /// 从JSON映射创建模型
  factory CartModel.fromJson(Map<String, dynamic> json, String userId) {
    // 解析购物车项
    List<CartItemModel> cartItems = [];
    if (json.containsKey('normalList') && json['normalList'] is List) {
      cartItems = (json['normalList'] as List)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // 计算摘要信息
    CartSummaryModel summary = CartSummaryModel.calculate(
        json.containsKey('normalList') ? json['normalList'] as List : []);

    // 生成校验结果
    CartValidationResultModel validationResult = CartValidationResultModel.validate(json);

    // 解析优惠券信息（如果有）
    CouponModel? appliedCoupon;
    List<CouponModel>? availableCoupons;

    if (json.containsKey('appliedCoupon') && json['appliedCoupon'] != null) {
      appliedCoupon = CouponModel.fromJson(json['appliedCoupon'] as Map<String, dynamic>);
    }

    if (json.containsKey('availableCoupons') && json['availableCoupons'] is List) {
      availableCoupons = (json['availableCoupons'] as List)
          .map((coupon) => CouponModel.fromJson(coupon as Map<String, dynamic>))
          .toList();
    }

    return CartModel(
      id: userId, // 使用用户ID作为购物车ID
      items: cartItems,
      summary: summary,
      appliedCoupon: appliedCoupon,
      availableCoupons: availableCoupons,
      validationResult: validationResult,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': (items as List<CartItemModel>).map((item) => item.toJson()).toList(),
      'summary': (summary as CartSummaryModel).toJson(),
      'appliedCoupon': appliedCoupon != null ? (appliedCoupon as CouponModel).toJson() : null,
      'availableCoupons': availableCoupons != null
          ? (availableCoupons as List<CouponModel>).map((coupon) => coupon.toJson()).toList()
          : null,
    };
  }

  /// 从实体创建模型
  factory CartModel.fromEntity(Cart entity) {
    return CartModel(
      id: entity.id,
      items: entity.items.map((item) => CartItemModel.fromEntity(item)).toList(),
      summary: CartSummaryModel.fromEntity(entity.summary),
      appliedCoupon: entity.appliedCoupon != null ? CouponModel.fromEntity(entity.appliedCoupon!) : null,
      availableCoupons: entity.availableCoupons != null
          ? entity.availableCoupons!.map((coupon) => CouponModel.fromEntity(coupon)).toList()
          : null,
      validationResult: entity.validationResult != null
          ? CartValidationResultModel.fromEntity(entity.validationResult!)
          : null,
    );
  }
}