import 'package:equatable/equatable.dart';

/// 表示首页信息流中的单个项目，主要是商品/服务项目
class HomeFeedItem extends Equatable {
  /// 项目唯一标识
  final String id;
  
  /// 项目类型，主要是商品/服务
  /// 可能的值: product
  final String type;
  
  /// 标题/名称
  final String name;
  
  /// 标题（兼容旧代码）
  final String title;
  
  /// 描述信息
  final String description;
  
  /// 图片 URL 列表，第一张作为封面
  final List<String> images;
  
  /// 单张图片链接（兼容旧代码）
  final String imageUrl;
  
  /// 售价
  final double sellingPrice;
  
  /// 价格（兼容旧代码）
  final double price;
  
  /// 评分，默认为 5.0
  final double score;
  
  /// 评价数量
  final int evaluateNum;

  HomeFeedItem({
    required this.id,
    this.type = 'product',
    required this.name,
    String? title,
    this.description = '',
    required this.images,
    String? imageUrl,
    required this.sellingPrice,
    double? price,
    this.score = 5.0,
    this.evaluateNum = 0,
  }) : 
    this.title = title ?? name,
    this.imageUrl = imageUrl ?? (images.isNotEmpty ? images[0] : ''),
    this.price = price ?? sellingPrice;

  @override
  List<Object?> get props => [id, type, name, title, description, images, imageUrl, sellingPrice, price, score, evaluateNum];
}