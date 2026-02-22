import '../../domain/entities/member.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

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
    AppLogger.d('[MemberModel] Parsing member from JSON: $json');
    final model = MemberModel(
      id: json['id'] ?? 0,
      nickname: json['nickName'] as String?, // API返回的是nickName
      avatar: json['avatar'] as String?,
      shopName: json['shopName'] as String?,
      mobile: json['mobile'] as String?,
    );
    AppLogger.d('[MemberModel] Parsed member - id: ${model.id}, nickname: ${model.nickname}');
    return model;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickName': nickname, // 发送给API时使用nickName
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