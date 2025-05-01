import 'package:equatable/equatable.dart';

/// 收藏的卖家/服务机构实体
class FavoriteSeller extends Equatable {
  /// 卖家ID
  final int id;
  
  /// 关联ID
  final int referId;
  
  /// 卖家昵称
  final String nickName;
  
  /// 卖家真实姓名（可选）
  final String? trueName;
  
  /// 卖家头像URL（可选）
  final String? avatar;
  
  /// 卖家手机号（可选）
  final String? mobile;
  
  /// 性别（MALE, FEMALE, NONE）（可选）
  final String? gender;
  
  /// 用户类型（MEMBER, TENANT, ANONYMOUS, ADMIN）
  final String type;
  
  /// 用户状态（NORMAL, FORBIDDEN, DELETE）（可选）
  final String? status;
  
  /// 是否已关注
  final bool isFavorite;

  /// 构造函数
  const FavoriteSeller({
    required this.id,
    required this.referId,
    required this.nickName,
    this.trueName,
    this.avatar,
    this.mobile,
    this.gender,
    required this.type,
    this.status,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [
    id,
    referId,
    nickName,
    trueName,
    avatar,
    mobile,
    gender,
    type,
    status,
    isFavorite,
  ];

  /// 创建一个新的FavoriteSeller实例，并更新指定的字段
  FavoriteSeller copyWith({
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
    return FavoriteSeller(
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

  /// 切换关注状态
  FavoriteSeller toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }
}