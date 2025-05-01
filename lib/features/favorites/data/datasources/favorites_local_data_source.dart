import '../models/favorite_service_model.dart';
import '../models/favorite_seller_model.dart';

/// 收藏本地数据源接口
abstract class FavoritesLocalDataSource {
  /// 缓存收藏的服务列表
  /// 
  /// [services] 要缓存的服务列表
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> cacheFavoriteServices(List<FavoriteServiceModel> services);

  /// 获取缓存的收藏服务列表
  /// 
  /// 成功返回 List<FavoriteServiceModel>
  /// 失败抛出异常
  Future<List<FavoriteServiceModel>> getCachedFavoriteServices();

  /// 缓存收藏的卖家列表
  /// 
  /// [sellers] 要缓存的卖家列表
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> cacheFavoriteSellers(List<FavoriteSellerModel> sellers);

  /// 获取缓存的收藏卖家列表
  /// 
  /// 成功返回 List<FavoriteSellerModel>
  /// 失败抛出异常
  Future<List<FavoriteSellerModel>> getCachedFavoriteSellers();

  /// 清除所有缓存的收藏数据
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> clearCache();
}