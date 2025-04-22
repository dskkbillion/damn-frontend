import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/favorite_model.dart';
import '../models/favorite_service_model.dart';
import '../models/favorite_seller_model.dart';
import '../models/common_user_model.dart';
import 'favorites_remote_data_source.dart';

/// 收藏远程数据源实现
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String authToken;
  final String userId;

  /// 构造函数
  FavoritesRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authToken,
    required this.userId,
  });

  /// 获取收藏的服务列表
  @override
  Future<List<FavoriteServiceModel>> getFavoriteServices({
    int? pageNum,
    int? pageSize,
  }) async {
    final queryParams = {
      'type': 'org_product',
      'memberId': userId,
      if (pageNum != null) 'pageNum': pageNum.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/collect/list').replace(
      queryParameters: queryParams,
    );

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] == 200) {
        final List<dynamic> rows = jsonResponse['rows'];
        
        // 将收藏记录转换为服务模型
        // 注意：这里需要根据实际API响应结构进行调整
        // 假设API返回的是收藏记录，需要进一步获取服务详情
        return rows.map((row) {
          final favorite = FavoriteModel.fromJson(row);
          
          // 这里应该根据favorite.objectId获取服务详情
          // 简化处理，直接构造服务模型
          return FavoriteServiceModel(
            id: favorite.objectId,
            title: 'Service ${favorite.objectId}', // 实际应从服务详情API获取
            description: 'Description for service ${favorite.objectId}', // 同上
            imageUrl: 'https://example.com/image${favorite.objectId}.jpg', // 同上
            price: 100.0, // 同上
            isFavorite: true,
          );
        }).toList();
      } else {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to get favorite services');
      }
    } else {
      throw ServerException(message: 'Failed to get favorite services');
    }
  }

  /// 获取收藏的卖家列表
  @override
  Future<List<FavoriteSellerModel>> getFavoriteSellers({
    int? pageNum,
    int? pageSize,
  }) async {
    final queryParams = {
      'type': 'org',
      'memberId': userId,
      if (pageNum != null) 'pageNum': pageNum.toString(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/collect/list').replace(
      queryParameters: queryParams,
    );

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] == 200) {
        final List<dynamic> rows = jsonResponse['rows'];
        
        // 将收藏记录转换为卖家模型
        // 注意：这里需要根据实际API响应结构进行调整
        // 假设API返回的是收藏记录，需要进一步获取卖家详情
        return rows.map((row) {
          final favorite = FavoriteModel.fromJson(row);
          
          // 这里应该根据favorite.objectId获取卖家详情
          // 简化处理，直接构造卖家模型
          return FavoriteSellerModel(
            id: favorite.objectId,
            referId: favorite.objectId,
            nickName: 'Seller ${favorite.objectId}', // 实际应从卖家详情API获取
            trueName: 'True Name ${favorite.objectId}', // 同上
            avatar: 'https://example.com/avatar${favorite.objectId}.jpg', // 同上
            type: 'MEMBER', // 同上
            isFavorite: true,
          );
        }).toList();
      } else {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to get favorite sellers');
      }
    } else {
      throw ServerException(message: 'Failed to get favorite sellers');
    }
  }

  /// 添加收藏
  @override
  Future<void> addToFavorites(
    String type,
    int objectId,
    Map<String, dynamic>? feature,
  ) async {
    final uri = Uri.parse('$baseUrl/api/collect/add');

    final body = json.encode({
      'memberId': int.parse(userId),
      'objectId': objectId,
      'type': type,
      'feature': feature,
    });

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] != 200) {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to add to favorites');
      }
    } else {
      throw ServerException(message: 'Failed to add to favorites');
    }
  }

  /// 从收藏中移除
  @override
  Future<void> removeFromFavorites(List<int> favoriteIds) async {
    final uri = Uri.parse('$baseUrl/api/collect/delete');

    final body = json.encode(favoriteIds);

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] != 200) {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to remove from favorites');
      }
    } else {
      throw ServerException(message: 'Failed to remove from favorites');
    }
  }

  /// 检查对象是否已收藏
  @override
  Future<Map<int, bool>> checkIsFavorite(
    String type,
    List<int> objectIds,
  ) async {
    final uri = Uri.parse('$baseUrl/api/collect/isCollect');

    final body = json.encode({
      'type': type,
      'searchIds': objectIds,
    });

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] == 200) {
        final Map<String, dynamic> data = jsonResponse['data'];
        
        // 将字符串键转换为整数键
        final Map<int, bool> result = {};
        data.forEach((key, value) {
          result[int.parse(key)] = value;
        });
        
        return result;
      } else {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to check if favorite');
      }
    } else {
      throw ServerException(message: 'Failed to check if favorite');
    }
  }

  /// 关注卖家
  @override
  Future<void> followSeller(CommonUserModel user) async {
    final uri = Uri.parse('$baseUrl/api/invitation/collectionMember');

    final body = json.encode(user.toJson());

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] != 200) {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to follow seller');
      }
    } else {
      throw ServerException(message: 'Failed to follow seller');
    }
  }

  /// 取消关注卖家
  @override
  Future<void> unfollowSeller(CommonUserModel user) async {
    final uri = Uri.parse('$baseUrl/api/invitation/cancelCollectionMember');

    final body = json.encode({
      'referId': user.referId,
      'type': user.type,
    });

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['code'] != 200) {
        throw ServerException(message: jsonResponse['msg'] ?? 'Failed to unfollow seller');
      }
    } else {
      throw ServerException(message: 'Failed to unfollow seller');
    }
  }
}