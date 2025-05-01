import '../../domain/entities/favorite_service.dart';

/// 收藏的服务项目模型
class FavoriteServiceModel extends FavoriteService {
  /// 构造函数
  const FavoriteServiceModel({
    required int id,
    required String title,
    String? description,
    String? imageUrl,
    required double price,
    required bool isFavorite,
  }) : super(
          id: id,
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          isFavorite: isFavorite,
        );

  /// 从JSON创建模型
  factory FavoriteServiceModel.fromJson(Map<String, dynamic> json) {
    return FavoriteServiceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] is int)
          ? json['price'].toDouble()
          : json['price'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  /// 创建一个新的FavoriteServiceModel实例，并更新指定的字段
  FavoriteServiceModel copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    bool? isFavorite,
  }) {
    return FavoriteServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}