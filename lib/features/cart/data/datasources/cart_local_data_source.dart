import '../models/cart_model.dart';

/// 购物车本地数据源接口
abstract class CartLocalDataSource {
  /// 获取缓存的购物车数据
  Future<CartModel?> getCachedCart();

  /// 缓存购物车数据
  Future<void> cacheCart(CartModel cart);

  /// 清除缓存的购物车数据
  Future<void> clearCache();
}