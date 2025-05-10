import 'package:equatable/equatable.dart';

/// 表示首页的横幅广告或推广位
class Banner extends Equatable {
  /// 唯一标识
  final String id;
  
  /// 图片 URL
  final String imageUrl;
  
  /// 横幅标题
  final String title;
  
  /// 链接URL
  final String linkUrl;
  
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
    this.title = '',
    this.linkUrl = '',
    this.targetType = '',
    this.targetValue = '',
    this.createTime = '',
    this.updateTime = '',
  });

  @override
  List<Object?> get props => [id, imageUrl, title, linkUrl, targetType, targetValue, createTime, updateTime];
}