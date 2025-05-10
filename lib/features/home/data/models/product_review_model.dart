import '../../domain/entities/product_review.dart';

/// 商品评论数据模型类
class ProductReviewModel extends ProductReview {
  const ProductReviewModel({
    required super.id,
    required super.merchantId,
    required super.orderId,
    required super.productId,
    required super.optionId,
    required super.skuName,
    required super.memberId,
    required super.score,
    super.images,
    required super.status,
    super.auditRemark,
    required super.anonymityFlag,
    required super.createTime,
    required super.buyer,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'],
      merchantId: json['merchantId'],
      orderId: json['orderId'],
      productId: json['productId'],
      optionId: json['optionId'],
      skuName: json['skuName'] ?? '',
      memberId: json['memberId'],
      score: json['score'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      status: json['status'] ?? '',
      auditRemark: json['auditRemark'],
      anonymityFlag: json['anonymityFlag'] ?? false,
      createTime: json['createTime'] ?? '',
      buyer: ReviewBuyerModel.fromJson(json['buyer'] ?? {}),
    );
  }
}

/// 评论买家数据模型类
class ReviewBuyerModel extends ReviewBuyer {
  const ReviewBuyerModel({
    required super.id,
    required super.nickName,
    super.avatar,
  });

  factory ReviewBuyerModel.fromJson(Map<String, dynamic> json) {
    return ReviewBuyerModel(
      id: json['id'] ?? 0,
      nickName: json['nickName'] ?? '',
      avatar: json['avatar'],
    );
  }
}

/// 评论列表响应数据模型
class ProductReviewsResponseModel extends ProductReviewsResponse {
  const ProductReviewsResponseModel({
    required super.total,
    required super.reviews,
  });

  factory ProductReviewsResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rows = json['rows'] ?? [];
    
    return ProductReviewsResponseModel(
      total: json['total'] ?? 0,
      reviews: rows.map((row) => ProductReviewModel.fromJson(row)).toList(),
    );
  }
} 