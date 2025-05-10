import 'package:equatable/equatable.dart';
import '../../domain/entities/product_review.dart';

/// 商品评论状态
abstract class ProductReviewsState extends Equatable {
  const ProductReviewsState();

  @override
  List<Object> get props => [];
}

/// 商品评论初始状态
class ProductReviewsInitial extends ProductReviewsState {}

/// 商品评论加载中状态
class ProductReviewsLoading extends ProductReviewsState {}

/// 商品评论加载成功状态
class ProductReviewsLoaded extends ProductReviewsState {
  final int total;
  final List<ProductReview> reviews;

  const ProductReviewsLoaded({
    required this.total,
    required this.reviews,
  });

  @override
  List<Object> get props => [total, reviews];
}

/// 商品评论加载失败状态
class ProductReviewsError extends ProductReviewsState {
  final String message;

  const ProductReviewsError({required this.message});

  @override
  List<Object> get props => [message];
} 