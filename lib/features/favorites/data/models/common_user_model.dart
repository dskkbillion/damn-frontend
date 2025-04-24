import '../../domain/entities/common_user.dart';
import 'favorite_seller_model.dart';

/// 用户信息模型（用于关注卖家API）
class CommonUserModel extends CommonUser {
  /// 构造函数
  const CommonUserModel({
    int? id,
    required int referId,
    String? nickName,
    String? trueName,
    String? avatar,
    String? mobile,
    String? gender,
    required String type,
    String? status,
    int? tenantId,
  }) : super(
          id: id,
          referId: referId,
          nickName: nickName,
          trueName: trueName,
          avatar: avatar,
          mobile: mobile,
          gender: gender,
          type: type,
          status: status,
          tenantId: tenantId,
        );

  /// 从JSON创建模型
  factory CommonUserModel.fromJson(Map<String, dynamic> json) {
    return CommonUserModel(
      id: json['id'],
      referId: json['referId'],
      nickName: json['nickName'],
      trueName: json['trueName'],
      avatar: json['avatar'],
      mobile: json['mobile'],
      gender: json['gender'],
      type: json['type'],
      status: json['status'],
      tenantId: json['tenantId'],
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
      'tenantId': tenantId,
    };
  }

  /// 创建一个新的CommonUserModel实例，并更新指定的字段
  CommonUserModel copyWith({
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
    return CommonUserModel(
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

  /// 从FavoriteSellerModel创建CommonUserModel
  factory CommonUserModel.fromFavoriteSeller(FavoriteSellerModel seller) {
    return CommonUserModel(
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