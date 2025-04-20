import '../../domain/entities/user_profile.dart';

/// 用户个人资料数据传输对象
class UserProfileDto {
  final String userId;
  final String nickName;
  final String? avatarUrl;
  final bool? onlineFlag;

  const UserProfileDto({
    required this.userId,
    required this.nickName,
    this.avatarUrl,
    this.onlineFlag,
  });

  /// 从 JSON 映射创建 UserProfileDto 实例
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userId: json['userId'] ?? json['id'] ?? '',
      nickName: json['nickName'] ?? json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['avatar'] ?? json['avatarUrl'],
      onlineFlag: json['onlineFlag'] ?? json['online_flag'],
    );
  }

  /// 转换为 UserProfile 实体
  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      nickName: nickName,
      avatarUrl: avatarUrl,
      onlineFlag: onlineFlag,
    );
  }

  /// 将 UserProfileDto 转换为 JSON 映射
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickName': nickName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (onlineFlag != null) 'onlineFlag': onlineFlag,
    };
  }
}
