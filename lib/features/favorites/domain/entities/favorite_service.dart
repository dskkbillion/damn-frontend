import 'package:equatable/equatable.dart';

/// 收藏的服务项目实体
class FavoriteService extends Equatable {
  /// 服务ID
  final int id;
  
  /// 服务标题
  final String title;
  
  /// 服务描述（可选）
  final String? description;
  
  /// 服务图片URL（可选）
  final String? imageUrl;
  
  /// 服务价格
  final double price;
  
  /// 是否已收藏
  final bool isFavorite;

  /// 构造函数
  const FavoriteService({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.price,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    price,
    isFavorite,
  ];

  /// 创建一个新的FavoriteService实例，并更新指定的字段
  FavoriteService copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    bool? isFavorite,
  }) {
    return FavoriteService(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// 切换收藏状态
  FavoriteService toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }
}