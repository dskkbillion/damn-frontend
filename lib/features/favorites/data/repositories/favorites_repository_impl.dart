import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/common_user.dart';
import '../../domain/entities/favorite_service.dart';
import '../../domain/entities/favorite_seller.dart';
import '../../domain/repositories/i_favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../models/common_user_model.dart';

/// 收藏仓库实现
class FavoritesRepositoryImpl implements IFavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;
  final FavoritesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  /// 构造函数
  FavoritesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// 获取收藏的服务列表
  @override
  Future<Either<Failure, List<FavoriteService>>> getFavoriteServices({
    int? pageNum,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteServices = await remoteDataSource.getFavoriteServices(
          pageNum: pageNum,
          pageSize: pageSize,
        );
        
        // 缓存数据
        await localDataSource.cacheFavoriteServices(remoteServices);
        
        return Right(remoteServices);
      } on ServerException {
        return Left(ServerFailure(message: '获取收藏服务失败，服务器错误'));
      }
    } else {
      try {
        final localServices = await localDataSource.getCachedFavoriteServices();
        return Right(localServices);
      } on CacheException {
        return Left(CacheFailure(message: '读取本地收藏服务缓存失败'));
      }
    }
  }

  /// 获取收藏的卖家列表
  @override
  Future<Either<Failure, List<FavoriteSeller>>> getFavoriteSellers({
    int? pageNum,
    int? pageSize,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSellers = await remoteDataSource.getFavoriteSellers(
          pageNum: pageNum,
          pageSize: pageSize,
        );
        
        // 缓存数据
        await localDataSource.cacheFavoriteSellers(remoteSellers);
        
        return Right(remoteSellers);
      } on ServerException {
        return Left(ServerFailure(message: '获取收藏卖家失败，服务器错误'));
      }
    } else {
      try {
        final localSellers = await localDataSource.getCachedFavoriteSellers();
        return Right(localSellers);
      } on CacheException {
        return Left(CacheFailure(message: '读取本地收藏卖家缓存失败'));
      }
    }
  }

  /// 添加收藏
  @override
  Future<Either<Failure, void>> addToFavorites(
    String type,
    int objectId,
    Map<String, dynamic>? feature,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addToFavorites(type, objectId, feature);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(message: '添加收藏失败，服务器错误'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  /// 从收藏中移除
  @override
  Future<Either<Failure, void>> removeFromFavorites(List<int> favoriteIds) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeFromFavorites(favoriteIds);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(message: '移除收藏失败，服务器错误'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  /// 检查对象是否已收藏
  @override
  Future<Either<Failure, Map<int, bool>>> checkIsFavorite(
    String type,
    List<int> objectIds,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkIsFavorite(type, objectIds);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure(message: '检查收藏状态失败，服务器错误'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  /// 关注卖家
  @override
  Future<Either<Failure, void>> followSeller(CommonUser user) async {
    if (await networkInfo.isConnected) {
      try {
        // 将领域实体转换为数据模型
        final userModel = CommonUserModel(
          id: user.id,
          referId: user.referId,
          nickName: user.nickName,
          trueName: user.trueName,
          avatar: user.avatar,
          mobile: user.mobile,
          gender: user.gender,
          type: user.type,
          status: user.status,
          tenantId: user.tenantId,
        );
        
        await remoteDataSource.followSeller(userModel);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(message: '关注卖家失败，服务器错误'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  /// 取消关注卖家
  @override
  Future<Either<Failure, void>> unfollowSeller(CommonUser user) async {
    if (await networkInfo.isConnected) {
      try {
        // 将领域实体转换为数据模型
        final userModel = CommonUserModel(
          id: user.id,
          referId: user.referId,
          nickName: user.nickName,
          trueName: user.trueName,
          avatar: user.avatar,
          mobile: user.mobile,
          gender: user.gender,
          type: user.type,
          status: user.status,
          tenantId: user.tenantId,
        );
        
        await remoteDataSource.unfollowSeller(userModel);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(message: '取消关注卖家失败，服务器错误'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}