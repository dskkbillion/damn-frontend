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
  
  /// 图片 URL 列表，第一张作为封面
  final List<String> images;
  
  /// 售价
  final double sellingPrice;
  
  /// 评分，默认为 5.0
  final double score;
  
  /// 评价数量
  final int evaluateNum;

  const HomeFeedItem({
    required this.id,
    required this.type,
    required this.name,
    required this.images,
    required this.sellingPrice,
    required this.score,
    required this.evaluateNum,
  });

  @override
  List<Object?> get props => [id, type, name, images, sellingPrice, score, evaluateNum];
}