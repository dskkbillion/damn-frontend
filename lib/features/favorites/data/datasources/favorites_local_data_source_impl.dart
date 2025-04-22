import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/favorite_service_model.dart';
import '../models/favorite_seller_model.dart';
import 'favorites_local_data_source.dart';

/// 收藏本地数据源实现
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;

  /// 缓存键
  static const String cachedFavoriteServicesKey = 'CACHED_FAVORITE_SERVICES';
  static const String cachedFavoriteSellersKey = 'CACHED_FAVORITE_SELLERS';

  /// 构造函数
  FavoritesLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  /// 缓存收藏的服务列表
  @override
  Future<void> cacheFavoriteServices(List<FavoriteServiceModel> services) async {
    try {
      final List<Map<String, dynamic>> jsonList = services
          .map((service) => service.toJson())
          .toList();
      
      await sharedPreferences.setString(
        cachedFavoriteServicesKey,
        json.encode(jsonList),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  /// 获取缓存的收藏服务列表
  @override
  Future<List<FavoriteServiceModel>> getCachedFavoriteServices() async {
    try {
      final jsonString = sharedPreferences.getString(cachedFavoriteServicesKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((jsonItem) => FavoriteServiceModel.fromJson(jsonItem))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }

  /// 缓存收藏的卖家列表
  @override
  Future<void> cacheFavoriteSellers(List<FavoriteSellerModel> sellers) async {
    try {
      final List<Map<String, dynamic>> jsonList = sellers
          .map((seller) => seller.toJson())
          .toList();
      
      await sharedPreferences.setString(
        cachedFavoriteSellersKey,
        json.encode(jsonList),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  /// 获取缓存的收藏卖家列表
  @override
  Future<List<FavoriteSellerModel>> getCachedFavoriteSellers() async {
    try {
      final jsonString = sharedPreferences.getString(cachedFavoriteSellersKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList
          .map((jsonItem) => FavoriteSellerModel.fromJson(jsonItem))
          .toList();
    } catch (e) {
      throw CacheException();
    }
  }

  /// 清除所有缓存的收藏数据
  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedFavoriteServicesKey);
      await sharedPreferences.remove(cachedFavoriteSellersKey);
    } catch (e) {
      throw CacheException();
    }
  }
}