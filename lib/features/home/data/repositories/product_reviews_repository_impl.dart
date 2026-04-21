import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/platform/network_info.dart';
import '../../domain/entities/product_review.dart';
import '../../domain/repositories/product_reviews_repository.dart';
import '../datasources/product_reviews_remote_data_source.dart';

@LazySingleton(as: ProductReviewsRepository)
class ProductReviewsRepositoryImpl implements ProductReviewsRepository {
  final ProductReviewsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProductReviewsRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, ProductReviewsResponse>> getProductReviews(int productId) async {
    if (await _networkInfo.isConnected) {
      try {
        final reviews = await _remoteDataSource.getProductReviews(productId);
        return Right(reviews);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message ?? '未知服务器错误'));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: '网络连接失败'));
    }
  }
} 