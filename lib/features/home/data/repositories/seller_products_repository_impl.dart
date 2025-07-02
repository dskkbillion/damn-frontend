import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/home/data/datasources/seller_products_data_source.dart';
import 'package:dskk_flutter_refactor/features/home/domain/entities/seller_product.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/seller_products_repository.dart';

class SellerProductsRepositoryImpl implements SellerProductsRepository {
  final SellerProductsDataSource dataSource;

  SellerProductsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<SellerProduct>>> getSellerProducts(int sellerId) async {
    try {
      final response = await dataSource.getSellerProducts(sellerId);
      return Right(response.products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? '获取商家商品失败'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> followSeller(int sellerId) async {
    try {
      final result = await dataSource.followSeller(sellerId);
      return Right(result);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message ?? '关注卖家失败'));
      }
      return Left(NetworkFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> unfollowSeller(int sellerId) async {
    try {
      final result = await dataSource.unfollowSeller(sellerId);
      return Right(result);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message ?? '取消关注卖家失败'));
      }
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerInfo?>> getSellerInfo(int sellerId) async {
    try {
      final result = await dataSource.getSellerInfo(sellerId);
      return Right(result);
    } catch (e) {
      if (e is ServerException) {
        return Left(ServerFailure(message: e.message ?? '获取卖家信息失败'));
      }
      return Left(NetworkFailure(message: e.toString()));
    }
  }
} 