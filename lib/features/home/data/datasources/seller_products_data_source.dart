import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/home/data/models/seller_products_response.dart';

abstract class SellerProductsDataSource {
  Future<SellerProductsResponse> getSellerProducts(int sellerId);
  Future<bool> followSeller(int sellerId);
  Future<bool> unfollowSeller(int sellerId);
}

class SellerProductsDataSourceImpl implements SellerProductsDataSource {
  final Dio dio;

  SellerProductsDataSourceImpl({required this.dio});

  @override
  Future<SellerProductsResponse> getSellerProducts(int sellerId) async {
    try {
      final response = await dio.post(
        '/api/shop/product/list',
        data: {'tenantId': sellerId},
      );

      if (response.statusCode == 200 && response.data['code'] == 200) {
        return SellerProductsResponse.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '获取商家商品失败',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络错误: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  @override
  Future<bool> followSeller(int sellerId) async {
    try {
      final response = await dio.post(
        '/api/collect/add',
        data: {
          'objectId': sellerId,
          'type': 'tenant',
          'feature': {
            'id': sellerId,
            'name': '卖家信息'
          }
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return true;
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '收藏卖家失败',
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }
  
  @override
  Future<bool> unfollowSeller(int sellerId) async {
    try {
      // 假设取消收藏的API是'/api/collect/delete'
      // 如果API不同，需要修改为正确的API
      final response = await dio.post(
        '/api/collect/delete',
        data: {
          'ids': [sellerId],
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        return true;
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '取消收藏卖家失败',
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }
} 