import 'package:equatable/equatable.dart';

/// 表示首页的横幅广告或推广位
class Banner extends Equatable {
  /// 唯一标识
  final String id;
  
  /// 图片 URL
  final String imageUrl;
  
  /// 点击后的目标类型
  /// 可能的值: post, product, category, url, none
  final String targetType;
  
  /// 目标的具体值（如帖子 ID、商品 ID、分类 ID、外部链接 URL）
  final String targetValue;
  
  /// 创建时间
  final String createTime;
  
  /// 更新时间
  final String updateTime;

  const Banner({
    required this.id,
    required this.imageUrl,
    required this.targetType,
    required this.targetValue,
    required this.createTime,
    required this.updateTime,
  });

  @override
  List<Object?> get props => [id, imageUrl, targetType, targetValue, createTime, updateTime];
}