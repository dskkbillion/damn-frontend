import 'dart:ui' show PlatformDispatcher;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/features/home/data/models/seller_products_response.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';

abstract class SellerProductsDataSource {
  Future<SellerProductsResponse> getSellerProducts(int sellerId);
  Future<bool> followSeller(int sellerId);
  Future<bool> unfollowSeller(int sellerId);
  Future<SellerInfo?> getSellerInfo(int sellerId);
}

class SellerProductsDataSourceImpl implements SellerProductsDataSource {
  final Dio dio;

  SellerProductsDataSourceImpl({required this.dio});

  @override
  Future<SellerProductsResponse> getSellerProducts(int sellerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appLanguage = prefs.getString('app_language');
      final language = appLanguage ?? PlatformDispatcher.instance.locale.languageCode;
      final response = await dio.post(
        '/api/shop/product/list',
        data: {'tenantId': sellerId},
        options: Options(headers: {
          'Accept-Language': language,
        }),
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
          'type': 'attentionMember',
          'feature': {
            'id': sellerId,
            'name': '卖家信息',
          },
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        await Future.delayed(Duration(milliseconds: 500));
        return true;
      } else {
        throw ServerException(
          message: response.data['msg'] ?? '关注卖家失败',
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
      // 🔥 统一使用collect接口：需要先查询收藏记录ID，然后删除
      // 这里简化处理，直接调用删除接口（假设后端支持按条件删除）
      final listResponse = await dio.get(
        '/api/collect/list',
        queryParameters: {
          'type': 'attentionMember',
        },
      );
      
      if (listResponse.statusCode == 200 && listResponse.data['code'] == 200) {
        final rows = listResponse.data['rows'] as List?;
        if (rows != null) {
          // 查找对应的收藏记录
          final collectRecord = rows.firstWhere(
            (record) => record['objectId'] == sellerId,
            orElse: () => null,
          );
          
          if (collectRecord != null) {
            final collectId = collectRecord['id'];
            final deleteResponse = await dio.post(
              '/api/collect/delete',
              data: [collectId],
            );
            
            if (deleteResponse.statusCode == 200 && deleteResponse.data['code'] == 200) {
              await Future.delayed(Duration(milliseconds: 500));
              return true;
            }
          }
        }
      }
      
      throw ServerException(
        message: '取消关注卖家失败',
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<SellerInfo?> getSellerInfo(int sellerId) async {
    try {
      final response = await dio.get(
        '/api/project/details',
        queryParameters: {'memberId': sellerId},
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = response.data['data'];
        if (data != null) {
          bool isFollowing = false;
          int realFansCount = 0;
          
          try {
            // 检查关注状态
            final followStatusResponse = await dio.post(
              '/api/collect/isCollect',
              data: {
                'searchIds': [sellerId],
                'type': 'attentionMember',
              },
            );
            
            if (followStatusResponse.statusCode == 200 && 
                followStatusResponse.data['code'] == 200) {
              final followData = followStatusResponse.data['data'];
              isFollowing = followData[sellerId.toString()] ?? false;
            }
          } catch (e) {
            AppLogger.d('查询关注状态失败: $e');
          }
          
          try {
            // 🔥 获取真实粉丝数：查询所有关注记录，然后筛选出关注该卖家的记录
            AppLogger.d('[getSellerInfo] 开始获取卖家 $sellerId 的真实粉丝数...');
            final fansResponse = await dio.get(
              '/api/collect/list',
              queryParameters: {
                'type': 'attentionMember',
              },
            );
            
            if (fansResponse.statusCode == 200 && fansResponse.data['code'] == 200) {
              final List<dynamic> allFollowRecords = fansResponse.data['rows'] ?? [];
              AppLogger.d('[getSellerInfo] 获取到全部关注记录数: ${allFollowRecords.length}');
              
              // 筛选出关注该卖家的记录
              final fansRecords = allFollowRecords.where((record) {
                if (record is Map<String, dynamic>) {
                  final objectId = record['objectId'];
                  // 支持多种数据类型的比较
                  return objectId == sellerId || objectId == sellerId.toString();
                }
                return false;
              }).toList();
              
              realFansCount = fansRecords.length;
              AppLogger.d('[getSellerInfo] 筛选得到关注卖家 $sellerId 的粉丝数: $realFansCount');
            } else {
              AppLogger.d('[getSellerInfo] 获取关注记录失败: ${fansResponse.data['msg']}');
              realFansCount = data['collectNum'] ?? 0;
            }
          } catch (e) {
            AppLogger.d('[getSellerInfo] 获取粉丝数出错: $e');
            // 如果获取失败，使用collectNum作为备选
            realFansCount = data['collectNum'] ?? 0;
            AppLogger.d('[getSellerInfo] 使用备选方案，粉丝数: $realFansCount');
          }
          
          return SellerInfo(
            id: sellerId,
            nickName: data['nickName'] ?? '未知卖家',
            trueName: null,
            avatar: data['avatar'],
            remarks: null,
            memberAttention: isFollowing,
            fansCount: realFansCount, // 🔥 使用真实统计的粉丝数
          );
        }
      } else {
        AppLogger.d('获取卖家信息失败: ${response.data['msg']}');
      }
      return null;
    } catch (e) {
      AppLogger.d('获取卖家信息出错: $e');
      return null;
    }
  }
} 