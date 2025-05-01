import 'package:dartz/dartz.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/home_feed_item.dart';
import '../../domain/entities/home_page_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements IHomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource? localDataSource;
  final NetworkInfo? networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  });

  @override
  Future<Either<Failure, HomePageData>> getHomePageData() async {
    // 简化版：如果 networkInfo 为 null，则假设网络已连接
    if (networkInfo == null || await networkInfo!.isConnected) {
      try {
        final remoteHomePageData = await remoteDataSource.getHomePageData();
        // 如果 localDataSource 不为 null，则缓存数据
        if (localDataSource != null) {
          await localDataSource!.cacheHomePageData(remoteHomePageData);
        }
        return Right(remoteHomePageData);
      } on ServerException catch (e) {
        // Provide a default message if e.message is null
        return Left(ServerFailure(message: e.message ?? '获取首页数据时发生服务器错误'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // 如果 localDataSource 为 null，则返回服务器错误
      if (localDataSource == null) {
        return Left(ServerFailure(message: '网络未连接且没有本地缓存'));
      }
      
      try {
        final localHomePageData = await localDataSource!.getLastHomePageData();
        return Right(localHomePageData);
      } on CacheException {
        // Add a message for CacheFailure
        return Left(const CacheFailure(message: '未能从本地缓存加载首页数据'));
      } catch (e) {
        // Add a message for other cache-related errors
        return Left(CacheFailure(message: '加载本地首页数据时发生错误: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, List<HomeFeedItem>>> getHomeFeed(int page, int limit) async {
    // 简化版：如果 networkInfo 为 null，则假设网络已连接
    if (networkInfo == null || await networkInfo!.isConnected) {
      try {
        final remoteHomeFeed = await remoteDataSource.getHomeFeed(page, limit);
        // 如果 localDataSource 不为 null，则缓存数据
        if (localDataSource != null) {
          await localDataSource!.cacheHomeFeed(page, remoteHomeFeed);
        }
        return Right(remoteHomeFeed);
      } on ServerException catch (e) {
        // Provide a default message if e.message is null
        return Left(ServerFailure(message: e.message ?? '获取首页Feed时发生服务器错误'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // 如果 localDataSource 为 null，则返回服务器错误
      if (localDataSource == null) {
        return Left(ServerFailure(message: '网络未连接且没有本地缓存'));
      }
      
      try {
        final localHomeFeed = await localDataSource!.getLastHomeFeed(page);
        return Right(localHomeFeed);
      } on CacheException {
        // Add a message for CacheFailure
        return Left(const CacheFailure(message: '未能从本地缓存加载首页Feed'));
      } catch (e) {
        // Add a message for other cache-related errors
        return Left(CacheFailure(message: '加载本地首页Feed时发生错误: ${e.toString()}'));
      }
    }
  }
}