import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/home_feed_item.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/home_page_data.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/product_detail.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/product_translation.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/banner.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

@Injectable(as: IHomeRepository)
class HomeRepositoryImpl implements IHomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HomePageData>> getHomePageData({int? seed}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getHomePageData(seed: seed);
        localDataSource.cacheHomePageData(remoteData);
        // 临时解决方案：直接转换为同类型数据
        final homePageData = HomePageData(
          banners: remoteData.banners.map((b) => Banner(
            id: b.id, 
            imageUrl: b.imageUrl,
            title: b.title ?? '',
            linkUrl: b.linkUrl ?? '',
          )).toList(),
          categories: const [], // 暂时返回空列表
          feedItems: remoteData.feedItems.map((item) => HomeFeedItem(
            id: item.id.toString(),
            name: item.name,
            images: item.images,
            sellingPrice: item.sellingPrice,
            description: '',
            translatedName: item.translatedName,
            translatedDescription: item.translatedDescription,
            translationSourceLang: item.translationSourceLang,
          )).toList(),
        );
        return Right(homePageData);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "服务器错误"));
      }
    } else {
      try {
        final localData = await localDataSource.getLastHomePageData();
        // 临时解决方案：直接转换为同类型数据
        final homePageData = HomePageData(
          banners: localData.banners.map((b) => Banner(
            id: b.id,
            imageUrl: b.imageUrl,
            title: b.title ?? '',
            linkUrl: b.linkUrl ?? '',
          )).toList(),
          categories: const [], // 暂时返回空列表
          feedItems: localData.feedItems.map((item) => HomeFeedItem(
            id: item.id.toString(),
            name: item.name,
            images: item.images,
            sellingPrice: item.sellingPrice,
            description: '',
            translatedName: item.translatedName,
            translatedDescription: item.translatedDescription,
            translationSourceLang: item.translationSourceLang,
          )).toList(),
        );
        return Right(homePageData);
      } on CacheException {
        return const Left(CacheFailure(message: '缓存获取Banner失败'));
      }
    }
  }

  @override
  Future<Either<Failure, List<HomeFeedItem>>> getHomeFeed(int page, int limit, {int? seed}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getHomeFeed(page, limit, seed: seed);
        // 转换为领域实体
        final feedItems = remoteData.map((item) => HomeFeedItem(
          id: item.id.toString(),
          name: item.name,
          images: item.images,
          sellingPrice: item.sellingPrice,
          description: '',
          translatedName: item.translatedName,
          translatedDescription: item.translatedDescription,
          translationSourceLang: item.translationSourceLang,
        )).toList();
        return Right(feedItems);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "服务器错误"));
      }
    } else {
      try {
        final localData = await localDataSource.getLastHomeFeed(page);
        // 转换为领域实体
        final feedItems = localData.map((item) => HomeFeedItem(
          id: item.id.toString(),
          name: item.name,
          images: item.images,
          sellingPrice: item.sellingPrice,
          description: '',
          translatedName: item.translatedName,
          translatedDescription: item.translatedDescription,
          translationSourceLang: item.translationSourceLang,
        )).toList();
        return Right(feedItems);
      } on CacheException {
        return const Left(CacheFailure(message: '缓存获取热门服务失败'));
      }
    }
  }

  @override
  Future<Either<Failure, (ProductDetail, ProductTranslation?)>> getProductDetail(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getProductDetail(productId);
        // 可以添加缓存逻辑，这里暂时不实现
        return Right((remoteData.toEntity(), remoteData.translation));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "服务器错误"));
      }
    } else {
      // 离线状态暂时不支持获取商品详情
      return const Left(NetworkFailure(message: '网络连接失败，无法获取卖家信息'));
    }
  }

  @override
  Future<Either<Failure, List<HomeFeedItem>>> searchProducts(
    String keyword, 
    {int page = 1, int pageSize = 20}
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final searchResults = await remoteDataSource.searchProducts(
          keyword, 
          page: page,
          pageSize: pageSize,
        );
        return Right(searchResults);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? "搜索失败"));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接失败，无法获取更多卖家信息'));
    }
  }
}