import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_review.dart';

/// 商品评论仓库接口
abstract class ProductReviewsRepository {
  /// 获取商品评论列表
  /// 
  /// [productId] 商品ID
  /// 返回评论列表响应或失败信息
  Future<Either<Failure, ProductReviewsResponse>> getProductReviews(int productId);
} 