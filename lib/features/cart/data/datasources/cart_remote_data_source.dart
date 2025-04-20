import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

/// 购物车远程数据源接口
abstract class CartRemoteDataSource {
  /// 获取购物车数据
  Future<CartModel> getCart();

  /// 添加商品到购物车
  Future<void> addToCart(String productId, String? skuId, int quantity);

  /// 更新购物车项数量
  Future<void> updateItemQuantity(String cartItemId, int newQuantity);

  /// 移除单个购物车项
  Future<void> removeItem(String cartItemId);

  /// 移除多个购物车项
  Future<void> removeItems(List<String> cartItemIds);

  /// 清空购物车
  Future<void> clearCart();

  /// 应用优惠券
  Future<CartModel> applyCoupon(String couponCode);

  /// 移除优惠券
  Future<CartModel> removeCoupon(String couponCode);

  /// 启动结算流程
  Future<Map<String, dynamic>> initiateCheckout(Map<String, dynamic> checkoutData);
}