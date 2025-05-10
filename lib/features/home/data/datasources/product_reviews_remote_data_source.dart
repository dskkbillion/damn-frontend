import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/i_http_client.dart';
import '../models/product_review_model.dart';

abstract class ProductReviewsRemoteDataSource {
  /// 获取商品评论列表
  /// 
  /// [productId] 商品ID
  /// 成功返回评论列表响应，失败抛出异常
  Future<ProductReviewsResponseModel> getProductReviews(int productId);
}

@LazySingleton(as: ProductReviewsRemoteDataSource)
class ProductReviewsRemoteDataSourceImpl implements ProductReviewsRemoteDataSource {
  final IHttpClient _httpClient;

  ProductReviewsRemoteDataSourceImpl(this._httpClient);

  @override
  Future<ProductReviewsResponseModel> getProductReviews(int productId) async {
    try {
      final response = await _httpClient.post(
        '/api/shop/evaluate/list',
        body: {
          'productId': productId,
        },
      );

      if (response != null) {
        final responseData = response as Map<String, dynamic>;
        if (responseData['code'] == 200) {
          return ProductReviewsResponseModel.fromJson(responseData);
        } else {
          throw ServerException(message: responseData['msg'] ?? '获取评论失败');
        }
      } else {
        throw ServerException(message: '获取评论失败: 空响应');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: '未知错误: $e');
    }
  }
} 