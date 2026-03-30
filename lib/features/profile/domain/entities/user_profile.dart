import 'package:equatable/equatable.dart';

/// 用户的核心档案信息
class UserProfile extends Equatable {
  /// 用户唯一标识 (关联 Auth 模块)
  final String userId;

  /// 用户昵称
  final String nickName;

  /// 头像 URL，可能为空
  final String? avatarUrl;

  /// 卖家在线状态 (用于卖家模式显示)
  final bool? onlineFlag;

  /// 用户手机号
  final String? mobile;

  /// 用户邮箱
  final String? email;

  /// 创建 UserProfile 实例
  const UserProfile({
    required this.userId,
    required this.nickName,
    this.avatarUrl,
    this.onlineFlag,
    this.mobile,
    this.email,
  });

  /// 创建一个带有更新字段的新实例
  UserProfile copyWith({
    String? userId,
    String? nickName,
    String? avatarUrl,
    bool? onlineFlag,
    String? mobile,
    String? email,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      nickName: nickName ?? this.nickName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      onlineFlag: onlineFlag ?? this.onlineFlag,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [userId, nickName, avatarUrl, onlineFlag, mobile, email];
}
