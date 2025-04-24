import 'package:equatable/equatable.dart';
import 'favorite_seller.dart';

/// 用户信息实体（用于关注卖家API）
class CommonUser extends Equatable {
  /// 用户ID（可选）
  final int? id;
  
  /// 关联ID（必填）
  final int referId;
  
  /// 昵称（可选）
  final String? nickName;
  
  /// 真实姓名（可选）
  final String? trueName;
  
  /// 头像URL（可选）
  final String? avatar;
  
  /// 手机号（可选）
  final String? mobile;
  
  /// 性别（可选）
  final String? gender;
  
  /// 用户类型（必填）
  final String type;
  
  /// 用户状态（可选）
  final String? status;
  
  /// 租户ID（可选）
  final int? tenantId;

  /// 构造函数
  const CommonUser({
    this.id,
    required this.referId,
    this.nickName,
    this.trueName,
    this.avatar,
    this.mobile,
    this.gender,
    required this.type,
    this.status,
    this.tenantId,
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
    tenantId,
  ];

  /// 创建一个新的CommonUser实例，并更新指定的字段
  CommonUser copyWith({
    int? id,
    int? referId,
    String? nickName,
    String? trueName,
    String? avatar,
    String? mobile,
    String? gender,
    String? type,
    String? status,
    int? tenantId,
  }) {
    return CommonUser(
      id: id ?? this.id,
      referId: referId ?? this.referId,
      nickName: nickName ?? this.nickName,
      trueName: trueName ?? this.trueName,
      avatar: avatar ?? this.avatar,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      type: type ?? this.type,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  /// 从FavoriteSeller创建CommonUser
  factory CommonUser.fromFavoriteSeller(FavoriteSeller seller) {
    return CommonUser(
      id: seller.id,
      referId: seller.referId,
      nickName: seller.nickName,
      trueName: seller.trueName,
      avatar: seller.avatar,
      mobile: seller.mobile,
      gender: seller.gender,
      type: seller.type,
      status: seller.status,
    );
  }
}