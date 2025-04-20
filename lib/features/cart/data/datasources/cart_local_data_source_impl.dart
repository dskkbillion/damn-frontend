import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/error/exceptions.dart';
import '../models/cart_model.dart';
import 'cart_local_data_source.dart';

const CACHED_CART = 'CACHED_CART';

/// 购物车本地数据源实现
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  final String Function() getUserId; // 获取用户ID的函数

  CartLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.getUserId,
  });

  @override
  Future<CartModel?> getCachedCart() async {
    final userId = getUserId();
    final jsonString = sharedPreferences.getString('$CACHED_CART-$userId');
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString);
        return CartModel.fromJson(jsonMap, userId);
      } catch (e) {
        // 如果解析失败，返回null而不是抛出异常
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> cacheCart(CartModel cart) async {
    final userId = getUserId();
    final jsonString = json.encode(cart.toJson());
    await sharedPreferences.setString('$CACHED_CART-$userId', jsonString);
  }

  @override
  Future<void> clearCache() async {
    final userId = getUserId();
    await sharedPreferences.remove('$CACHED_CART-$userId');
  }
}