import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/error/exceptions.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import 'cart_remote_data_source.dart';

/// 购物车远程数据源实现
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String Function() getToken; // 获取认证令牌的函数
  final String Function() getUserId; // 获取用户ID的函数

  CartRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.getToken,
    required this.getUserId,
  });

  /// 获取请求头
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': getToken(),
    };
  }

  @override
  Future<CartModel> getCart() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/shop/cart/list'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] == 200) {
        return CartModel.fromJson(jsonData['data'], getUserId());
      } else {
        throw ServerException(message: jsonData['msg'] ?? '获取购物车失败');
      }
    } else {
      throw ServerException(message: '获取购物车失败: ${response.statusCode}');
    }
  }

  @override
  Future<void> addToCart(String productId, String? skuId, int quantity) async {
    final body = json.encode({
      'productId': int.parse(productId),
      'variantId': skuId != null ? int.parse(skuId) : null,
      'number': quantity,
    });

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/modify-number'),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] != 200) {
        throw ServerException(message: jsonData['msg'] ?? '添加到购物车失败');
      }
    } else {
      throw ServerException(message: '添加到购物车失败: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateItemQuantity(String cartItemId, int newQuantity) async {
    final body = json.encode({
      'id': int.parse(cartItemId),
      'number': newQuantity,
    });

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/modify-number'),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] != 200) {
        throw ServerException(message: jsonData['msg'] ?? '更新购物车数量失败');
      }
    } else {
      throw ServerException(message: '更新购物车数量失败: ${response.statusCode}');
    }
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    final body = json.encode({
      'id': int.parse(cartItemId),
    });

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/deleteOne'),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] != 200) {
        throw ServerException(message: jsonData['msg'] ?? '移除购物车商品失败');
      }
    } else {
      throw ServerException(message: '移除购物车商品失败: ${response.statusCode}');
    }
  }

  @override
  Future<void> removeItems(List<String> cartItemIds) async {
    final body = json.encode(
      cartItemIds.map((id) => int.parse(id)).toList(),
    );

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/delete'),
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] != 200) {
        throw ServerException(message: jsonData['msg'] ?? '批量移除购物车商品失败');
      }
    } else {
      throw ServerException(message: '批量移除购物车商品失败: ${response.statusCode}');
    }
  }

  @override
  Future<void> clearCart() async {
    // 获取购物车列表
    final cart = await getCart();
    
    // 如果购物车为空，直接返回
    if (cart.items.isEmpty) {
      return;
    }
    
    // 获取所有购物车项的ID
    final cartItemIds = cart.items.map((item) => item.id).toList();
    
    // 调用批量删除接口
    await removeItems(cartItemIds);
  }

  @override
  Future<CartModel> applyCoupon(String couponCode) async {
    // 注意：API文档中没有明确的优惠券接口，这里是一个假设的实现
    // 实际项目中需要根据真实API调整
    final body = json.encode({
      'couponCode': couponCode,
    });

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/apply-coupon'), // 假设的API端点
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] == 200) {
        return CartModel.fromJson(jsonData['data'], getUserId());
      } else {
        throw ServerException(message: jsonData['msg'] ?? '应用优惠券失败');
      }
    } else {
      throw ServerException(message: '应用优惠券失败: ${response.statusCode}');
    }
  }

  @override
  Future<CartModel> removeCoupon(String couponCode) async {
    // 注意：API文档中没有明确的优惠券接口，这里是一个假设的实现
    // 实际项目中需要根据真实API调整
    final body = json.encode({
      'couponCode': couponCode,
    });

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/cart/remove-coupon'), // 假设的API端点
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] == 200) {
        return CartModel.fromJson(jsonData['data'], getUserId());
      } else {
        throw ServerException(message: jsonData['msg'] ?? '移除优惠券失败');
      }
    } else {
      throw ServerException(message: '移除优惠券失败: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> initiateCheckout(Map<String, dynamic> checkoutData) async {
    // 注意：API文档中没有明确的结算接口，这里是一个假设的实现
    // 实际项目中需要根据真实API调整
    final body = json.encode(checkoutData);

    final response = await client.post(
      Uri.parse('$baseUrl/api/shop/order/create'), // 假设的API端点
      headers: _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['code'] == 200) {
        return jsonData['data'];
      } else {
        throw ServerException(message: jsonData['msg'] ?? '启动结算失败');
      }
    } else {
      throw ServerException(message: '启动结算失败: ${response.statusCode}');
    }
  }
}