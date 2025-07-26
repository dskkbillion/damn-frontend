import '../../domain/entities/member.dart';

/// Member的数据传输对象，用于与API交互
class MemberModel {
  final int id;
  final String? nickname;
  final String? avatar;
  final String? shopName;
  final String? mobile;
  
  const MemberModel({
    required this.id,
    this.nickname,
    this.avatar,
    this.shopName,
    this.mobile,
  });
  
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      shopName: json['shopName'] as String?,
      mobile: json['mobile'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'shopName': shopName,
      'mobile': mobile,
    };
  }
  
  Member toEntity() {
    return Member(
      id: id,
      nickname: nickname,
      avatar: avatar,
      shopName: shopName,
      mobile: mobile,
    );
  }
}