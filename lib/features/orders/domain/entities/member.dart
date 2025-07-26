import 'package:equatable/equatable.dart';

/// 表示会员（买家或卖家）信息的实体
class Member extends Equatable {
  /// 会员ID
  final int id;
  
  /// 会员昵称
  final String? nickname;
  
  /// 会员头像
  final String? avatar;
  
  /// 店铺名称（卖家专有）
  final String? shopName;
  
  /// 手机号
  final String? mobile;
  
  const Member({
    required this.id,
    this.nickname,
    this.avatar,
    this.shopName,
    this.mobile,
  });
  
  @override
  List<Object?> get props => [id, nickname, avatar, shopName, mobile];
}