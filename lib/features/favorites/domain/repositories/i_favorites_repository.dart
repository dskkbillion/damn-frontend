import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/common_user.dart';
import '../entities/favorite_service.dart';
import '../entities/favorite_seller.dart';

/// 收藏模块的数据访问接口
abstract class IFavoritesRepository {
  /// 获取收藏的服务列表
  /// 
  /// [pageNum] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  /// 
  /// 返回 Either<Failure, List<FavoriteService>>
  Future<Either<Failure, List<FavoriteService>>> getFavoriteServices({
    int? pageNum,
    int? pageSize,
  });

  /// 获取收藏的卖家列表
  /// 
  /// [pageNum] 页码，默认为1
  /// [pageSize] 每页数量，默认为10
  /// 
  /// 返回 Either<Failure, List<FavoriteSeller>>
  Future<Either<Failure, List<FavoriteSeller>>> getFavoriteSellers({
    int? pageNum,
    int? pageSize,
  });

  /// 添加收藏
  /// 
  /// [type] 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  /// [objectId] 收藏对象ID
  /// [feature] 收藏对象的特征信息（可选）
  /// 
  /// 返回 Either<Failure, void>
  Future<Either<Failure, void>> addToFavorites(
    String type,
    int objectId,
    Map<String, dynamic>? feature,
  );

  /// 从收藏中移除
  /// 
  /// [favoriteIds] 收藏记录ID列表
  /// 
  /// 返回 Either<Failure, void>
  Future<Either<Failure, void>> removeFromFavorites(List<int> favoriteIds);

  /// 检查对象是否已收藏
  /// 
  /// [type] 收藏类型，如"org_product"（服务项目）、"org"（服务机构/卖家）等
  /// [objectIds] 收藏对象ID列表
  /// 
  /// 返回 Either<Failure, Map<int, bool>>，键为对象ID，值为是否已收藏
  Future<Either<Failure, Map<int, bool>>> checkIsFavorite(
    String type,
    List<int> objectIds,
  );

  /// 关注卖家
  /// 
  /// [user] 卖家用户信息
  /// 
  /// 返回 Either<Failure, void>
  Future<Either<Failure, void>> followSeller(CommonUser user);

  /// 取消关注卖家
  /// 
  /// [user] 卖家用户信息
  /// 
  /// 返回 Either<Failure, void>
  Future<Either<Failure, void>> unfollowSeller(CommonUser user);
}