import 'dart:convert';

import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

import '../../../../core/error/failures.dart';
import '../models/favorite_model.dart';
import '../models/favorite_service_model.dart';
import '../models/favorite_seller_model.dart';
import '../models/common_user_model.dart';
import 'favorites_remote_data_source.dart';

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final CoreDioClient coreDioClient;

  FavoritesRemoteDataSourceImpl({required this.coreDioClient});

  @override
  Future<List<FavoriteServiceModel>> getFavoriteServices({
    int? pageNum = 1,
    int? pageSize = 10,
  }) async {
    try {
      final response = await coreDioClient.get(
        '/api/collect/list',
        queryParameters: {
          'type': 'org_product',
          'pageNum': pageNum ?? 1,
          'pageSize': pageSize ?? 10,
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['code'] == 200) {
        final rows = response.data['rows'] as List<dynamic>? ?? [];
        final favorites = rows.map((r) => FavoriteModel.fromJson(r as Map<String, dynamic>)).toList();

        final List<FavoriteServiceModel> services = [];
        for (final fav in favorites) {
          try {
            services.add(await _getServiceDetail(fav.objectId));
          } catch (e) {
            AppLogger.d('[Favorites] 获取服务详情失败 objectId=${fav.objectId}: $e');
          }
        }
        return services;
      }
      throw ServerFailure(message: response.data?['msg'] ?? '获取收藏列表失败');
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(message: '获取收藏服务列表出错: $e');
    }
  }

  Future<FavoriteServiceModel> _getServiceDetail(int productId) async {
    final response = await coreDioClient.get(
      '/api/shop/product/get',
      queryParameters: {'id': productId},
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      final data = response.data['data'] as Map<String, dynamic>;

      String? imageUrl;
      final images = data['images'];
      if (images is List && images.isNotEmpty) {
        final raw = images[0].toString();
        if (raw.startsWith('[')) {
          try {
            final parsed = json.decode(raw) as List;
            if (parsed.isNotEmpty) imageUrl = parsed[0].toString();
          } catch (_) {}
        } else {
          imageUrl = raw;
        }
      }

      // 价格在 variants[0].sellingPrice，data 顶层无此字段
      double price = 0.0;
      final variants = data['variants'] as List<dynamic>?;
      if (variants != null && variants.isNotEmpty) {
        final rawPrice = (variants[0] as Map<String, dynamic>)['sellingPrice'];
        if (rawPrice != null) {
          price = rawPrice is int ? rawPrice.toDouble() : (rawPrice as num).toDouble();
        }
      }

      return FavoriteServiceModel(
        id: data['id'] as int,
        title: (data['name'] as String?) ?? '未知服务',
        description: data['description'] as String?,
        imageUrl: imageUrl,
        price: price,
        isFavorite: true,
      );
    }
    throw ServerFailure(message: response.data?['msg'] ?? '获取服务详情失败');
  }

  @override
  Future<List<FavoriteSellerModel>> getFavoriteSellers({
    int? pageNum = 1,
    int? pageSize = 10,
  }) async {
    try {
      final response = await coreDioClient.get(
        '/api/collect/list',
        queryParameters: {
          'type': 'attentionMember',
          'pageNum': pageNum ?? 1,
          'pageSize': pageSize ?? 10,
        },
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['code'] == 200) {
        final rows = response.data['rows'] as List<dynamic>? ?? [];
        final records = rows.map((r) => FavoriteModel.fromJson(r as Map<String, dynamic>)).toList();

        final List<FavoriteSellerModel> sellers = [];
        for (final rec in records) {
          try {
            sellers.add(await _getSellerDetail(rec.objectId));
          } catch (e) {
            AppLogger.d('[Favorites] 获取卖家详情失败 objectId=${rec.objectId}: $e');
          }
        }
        return sellers;
      }
      // API 成功但无数据时返回空列表
      return [];
    } catch (e) {
      AppLogger.d('[Favorites] 获取收藏卖家列表出错: $e');
      return [];
    }
  }

  Future<FavoriteSellerModel> _getSellerDetail(int memberId) async {
    final response = await coreDioClient.get(
      '/api/project/details',
      queryParameters: {'memberId': memberId},
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return FavoriteSellerModel(
        id: memberId,
        referId: memberId,
        nickName: data['nickName'] as String? ?? '未知卖家',
        trueName: data['trueName'] as String?,
        avatar: data['avatar'] as String?,
        mobile: data['mobile'] as String?,
        gender: data['gender'] as String?,
        type: data['type'] as String? ?? 'MEMBER',
        status: data['status'] as String?,
        isFavorite: true,
      );
    }
    throw ServerFailure(message: response.data?['msg'] ?? '获取卖家详情失败');
  }

  @override
  Future<void> addToFavorites(
    String type,
    int objectId,
    Map<String, dynamic>? feature,
  ) async {
    final response = await coreDioClient.post(
      '/api/collect/add',
      data: {'objectId': objectId, 'type': type, 'feature': feature},
    );
    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      return;
    }
    throw ServerFailure(message: response.data?['msg'] ?? '添加收藏失败');
  }

  @override
  Future<void> removeFromFavorites(List<int> favoriteIds) async {
    final response = await coreDioClient.post(
      '/api/collect/delete',
      data: favoriteIds,
    );
    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      return;
    }
    throw ServerFailure(message: response.data?['msg'] ?? '移除收藏失败');
  }

  @override
  Future<void> removeFromFavoritesByObjectId(String type, int objectId) async {
    final response = await coreDioClient.get(
      '/api/collect/list',
      queryParameters: {'type': type, 'pageNum': 1, 'pageSize': 100},
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      final rows = response.data['rows'] as List<dynamic>? ?? [];
      for (final row in rows) {
        if (row['objectId'] == objectId && row['type'] == type) {
          await removeFromFavorites([row['id'] as int]);
          return;
        }
      }
      // 未找到记录，视为已删除
      return;
    }
    throw ServerFailure(message: response.data?['msg'] ?? '查询收藏列表失败');
  }

  @override
  Future<Map<int, bool>> checkIsFavorite(
    String type,
    List<int> objectIds,
  ) async {
    final response = await coreDioClient.post(
      '/api/collect/isCollect',
      data: {'type': type, 'searchIds': objectIds},
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(int.parse(k), v as bool));
    }
    throw ServerFailure(message: response.data?['msg'] ?? '检查收藏状态失败');
  }

  @override
  Future<void> followSeller(CommonUserModel user) async {
    final response = await coreDioClient.post(
      '/api/collect/add',
      data: {
        'objectId': user.referId,
        'type': 'attentionMember',
        'feature': {
          'id': user.referId,
          'name': user.nickName ?? '未知用户',
          'avatar': user.avatar,
          'type': user.type,
        },
      },
    );
    if (response.statusCode == 200 &&
        response.data != null &&
        response.data['code'] == 200) {
      return;
    }
    throw ServerFailure(message: response.data?['msg'] ?? '关注卖家失败');
  }

  @override
  Future<void> unfollowSeller(CommonUserModel user) async {
    await removeFromFavoritesByObjectId('attentionMember', user.referId);
  }
}
