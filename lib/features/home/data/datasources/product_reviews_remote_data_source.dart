import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_review_model.dart';

/// Token获取函数类型定义
typedef TokenProvider = Future<String> Function();

abstract class ProductReviewsRemoteDataSource {
  /// 获取商品评论列表
  /// 
  /// [productId] 商品ID
  /// 成功返回评论列表响应，失败抛出异常
  Future<ProductReviewsResponseModel> getProductReviews(int productId);
}

@LazySingleton(as: ProductReviewsRemoteDataSource)
class ProductReviewsRemoteDataSourceImpl implements ProductReviewsRemoteDataSource {
  final http.Client _client;
  final String _baseUrl;
  final TokenProvider _getToken;

  ProductReviewsRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
    required TokenProvider getToken,
  }) : _client = client,
       _baseUrl = baseUrl,
       _getToken = getToken;

  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token,
      'clienttype': '1',
      'client': 'android',
      'version': '100',
    };
  }

  @override
  Future<ProductReviewsResponseModel> getProductReviews(int productId) async {
    final url = Uri.parse('$_baseUrl/api/shop/evaluate/list');
    
    try {
      final headers = await _getHeaders();
      final requestBody = json.encode({'productId': productId});
      
      print('商品评论API请求URL: $url');
      print('商品评论API请求头: $headers');
      print('商品评论API请求体: $requestBody');
      
      final response = await _client.post(
        url,
        headers: headers,
        body: requestBody,
      );

      print('商品评论API响应状态码: ${response.statusCode}');
      print('商品评论API响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['code'] == 200) {
          return ProductReviewsResponseModel.fromJson(responseData);
        } else {
          throw ServerException(message: responseData['msg'] ?? '获取评论失败');
        }
      } else {
        throw ServerException(message: '获取评论失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('获取商品评论出错: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '未知错误: $e');
    }
  }
} 