import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/cart.dart';

/// 购物车模块的数据访问接口
abstract class ICartRepository {
  /// 获取购物车状态 (可能结合本地缓存和远程API)
  Future<Either<Failure, Cart>> getCart();

  /// 调用API添加商品
  Future<Either<Failure, void>> addToCart(String productId, String? skuId, int quantity);

  /// 调用API更新数量
  Future<Either<Failure, void>> updateItemQuantity(String cartItemId, int newQuantity);

  /// 调用API移除单项
  Future<Either<Failure, void>> removeItem(String cartItemId);

  /// 调用API移除多项
  Future<Either<Failure, void>> removeItems(List<String> cartItemIds);

  /// 调用API清空购物车
  Future<Either<Failure, void>> clearCart();

  /// 调用API应用优惠券
  Future<Either<Failure, Cart>> applyCoupon(String couponCode);

  /// 调用API移除优惠券
  Future<Either<Failure, Cart>> removeCoupon(String couponCode);

  /// 调用API启动结算
  Future<Either<Failure, CheckoutPreview>> initiateCheckout(CheckoutRequestData data);
}

/// 结算预览信息
class CheckoutPreview {
  final String preOrderId;
  final double totalAmount;
  final int itemCount;
  final double shippingFee;
  final double tax;
  final double discount;
  final double finalAmount;

  CheckoutPreview({
    required this.preOrderId,
    required this.totalAmount,
    required this.itemCount,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.finalAmount,
  });
}

/// 结算请求数据
class CheckoutRequestData {
  final List<String>? cartItemIds; // 如果支持部分结算
  final String? selectedAddressId;
  final String? selectedShippingMethodId;
  final String? couponCode;
  final String? note;

  CheckoutRequestData({
    this.cartItemIds,
    this.selectedAddressId,
    this.selectedShippingMethodId,
    this.couponCode,
    this.note,
  });
}