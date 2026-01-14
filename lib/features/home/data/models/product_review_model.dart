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
    super.content,
    super.images,
    required super.status,
    super.auditRemark,
    required super.anonymityFlag,
    required super.createTime,
    required super.buyer,
    super.sellerReply,
    super.sellerReplyTime,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] ?? json['orderId'] ?? 0,  // API 可能没有 id 字段，用 orderId 作为 fallback
      merchantId: json['merchantId'] ?? 0,  // merchantId 可能为 null
      orderId: json['orderId'] ?? 0,
      productId: json['productId'] ?? 0,
      optionId: json['optionId'] ?? 0,
      skuName: json['skuName'] ?? '',
      memberId: json['memberId'] ?? 0,
      score: json['score'] ?? 0,
      content: json['content'] ?? json['evaluateContent'] ?? json['remark'],  // 兼容不同的字段名
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      status: json['status'] ?? '',
      auditRemark: json['auditRemark'],
      anonymityFlag: json['anonymityFlag'] ?? false,
      createTime: json['createTime'] ?? '',
      buyer: ReviewBuyerModel.fromJson(json['buyer'] ?? {}),
      sellerReply: json['sellerReply'] ?? json['replyContent'],  // 卖家回复
      sellerReplyTime: json['sellerReplyTime'] ?? json['replyTime'],  // 卖家回复时间
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