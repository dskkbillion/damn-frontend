import '../../domain/entities/favorite_seller.dart';

/// 收藏的卖家/服务机构模型
class FavoriteSellerModel extends FavoriteSeller {
  /// 构造函数
  const FavoriteSellerModel({
    required super.id,
    required super.referId,
    required super.nickName,
    super.trueName,
    super.avatar,
    super.mobile,
    super.gender,
    required super.type,
    super.status,
    required super.isFavorite,
  });

  /// 从JSON创建模型
  factory FavoriteSellerModel.fromJson(Map<String, dynamic> json) {
    return FavoriteSellerModel(
      id: json['id'],
      referId: json['referId'],
      nickName: json['nickName'],
      trueName: json['trueName'],
      avatar: json['avatar'],
      mobile: json['mobile'],
      gender: json['gender'],
      type: json['type'],
      status: json['status'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referId': referId,
      'nickName': nickName,
      'trueName': trueName,
      'avatar': avatar,
      'mobile': mobile,
      'gender': gender,
      'type': type,
      'status': status,
      'isFavorite': isFavorite,
    };
  }

  /// 创建一个新的FavoriteSellerModel实例，并更新指定的字段
  @override
  FavoriteSellerModel copyWith({
    int? id,
    int? referId,
    String? nickName,
    String? trueName,
    String? avatar,
    String? mobile,
    String? gender,
    String? type,
    String? status,
    bool? isFavorite,
  }) {
    return FavoriteSellerModel(
      id: id ?? this.id,
      referId: referId ?? this.referId,
      nickName: nickName ?? this.nickName,
      trueName: trueName ?? this.trueName,
      avatar: avatar ?? this.avatar,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      type: type ?? this.type,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}