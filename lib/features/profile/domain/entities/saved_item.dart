import 'package:equatable/equatable.dart';

/// 用户收藏的服务或项目
class SavedItem extends Equatable {
  /// 项目唯一标识
  final String itemId;

  /// 项目标题
  final String title;

  /// 项目图片 URL
  final String? imageUrl;

  /// 价格
  final double? price;

  /// 卖家名称
  final String? sellerName;

  /// 收藏时间
  final DateTime? savedAt;

  /// 创建 SavedItem 实例
  const SavedItem({
    required this.itemId,
    required this.title,
    this.imageUrl,
    this.price,
    this.sellerName,
    this.savedAt,
  });

  @override
  List<Object?> get props => [
    itemId,
    title,
    imageUrl,
    price,
    sellerName,
    savedAt,
  ];
}
