import 'package:equatable/equatable.dart';

/// 商品评论实体类
class ProductReview extends Equatable {
  final int id;
  final int merchantId;
  final int orderId;
  final int productId;
  final int optionId;
  final String skuName;
  final int memberId;
  final int score;
  final String? content;  // 评论内容
  final List<String>? images;
  final String status;
  final String? auditRemark;
  final bool anonymityFlag;
  final String createTime;
  final ReviewBuyer buyer;
  final String? sellerReply;  // 卖家回复
  final String? sellerReplyTime;  // 卖家回复时间

  const ProductReview({
    required this.id,
    required this.merchantId,
    required this.orderId,
    required this.productId,
    required this.optionId,
    required this.skuName,
    required this.memberId,
    required this.score,
    this.content,
    this.images,
    required this.status,
    this.auditRemark,
    required this.anonymityFlag,
    required this.createTime,
    required this.buyer,
    this.sellerReply,
    this.sellerReplyTime,
  });

  @override
  List<Object?> get props => [
    id,
    merchantId,
    orderId,
    productId,
    optionId,
    skuName,
    memberId,
    score,
    content,
    images,
    status,
    auditRemark,
    anonymityFlag,
    createTime,
    buyer,
    sellerReply,
    sellerReplyTime,
  ];
}

/// 评论买家信息实体类
class ReviewBuyer extends Equatable {
  final int id;
  final String nickName;
  final String? avatar;

  const ReviewBuyer({
    required this.id,
    required this.nickName,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, nickName, avatar];
}

/// 评论列表响应实体类
class ProductReviewsResponse extends Equatable {
  final int total;
  final List<ProductReview> reviews;

  const ProductReviewsResponse({
    required this.total,
    required this.reviews,
  });

  @override
  List<Object> get props => [total, reviews];
} 