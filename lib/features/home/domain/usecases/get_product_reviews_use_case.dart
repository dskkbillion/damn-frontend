import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_review.dart';
import '../repositories/product_reviews_repository.dart';

/// 获取商品评论的用例参数
class GetProductReviewsParams {
  final int productId;

  GetProductReviewsParams({required this.productId});
}

/// 获取商品评论的用例
@injectable
class GetProductReviewsUseCase extends UseCase<ProductReviewsResponse, GetProductReviewsParams> {
  final ProductReviewsRepository _repository;

  GetProductReviewsUseCase(this._repository);

  @override
  Future<Either<Failure, ProductReviewsResponse>> call(GetProductReviewsParams params) {
    return _repository.getProductReviews(params.productId);
  }
} 