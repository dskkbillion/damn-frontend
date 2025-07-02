import '../models/favorite_model.dart';
import '../models/favorite_service_model.dart';
import '../models/favorite_seller_model.dart';
import '../models/common_user_model.dart';

/// 收藏远程数据源接口
abstract class FavoritesRemoteDataSource {
  /// 获取收藏的服务列表
  /// 
  /// [pageNum] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  /// 
  /// 成功返回 List<FavoriteServiceModel>
  /// 失败抛出异常
  Future<List<FavoriteServiceModel>> getFavoriteServices({
    int? pageNum,
    int? pageSize,
  });

  /// 获取收藏的卖家列表
  /// 
  /// [pageNum] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  /// 
  /// 成功返回 List<FavoriteSellerModel>
  /// 失败抛出异常
  Future<List<FavoriteSellerModel>> getFavoriteSellers({
    int? pageNum,
    int? pageSize,
  });

  /// 添加收藏
  /// 
  /// [type] 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  /// [objectId] 收藏对象ID
  /// [feature] 收藏对象的特征信息（可选）
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> addToFavorites(
    String type,
    int objectId,
    Map<String, dynamic>? feature,
  );

  /// 从收藏中移除
  /// 
  /// [favoriteIds] 收藏记录ID列表
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> removeFromFavorites(List<int> favoriteIds);

  /// 按对象ID从收藏中移除
  /// 
  /// [type] 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  /// [objectId] 要移除的对象ID
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> removeFromFavoritesByObjectId(String type, int objectId);

  /// 检查对象是否已收藏
  /// 
  /// [type] 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  /// [objectIds] 收藏对象ID列表
  /// 
  /// 成功返回 Map<int, bool>，键为对象ID，值为是否已收藏
  /// 失败抛出异常
  Future<Map<int, bool>> checkIsFavorite(
    String type,
    List<int> objectIds,
  );

  /// 关注卖家
  /// 
  /// [user] 卖家用户信息
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> followSeller(CommonUserModel user);

  /// 取消关注卖家
  /// 
  /// [user] 卖家用户信息
  /// 
  /// 成功返回 void
  /// 失败抛出异常
  Future<void> unfollowSeller(CommonUserModel user);
}