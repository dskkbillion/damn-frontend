import 'package:equatable/equatable.dart';

/// 用于解析 /api/member/info 响应的 DTO
/// 字段基于 RN 代码中 User 类型和 createFetchUserProfileThunk 的推断
class UserInfoModel extends Equatable {
  final String userId; // 假设后端返回的是 user_id 或 id
  final String? nickname;
  final String? avatar;
  final String mobile; // 手机号应该包含
  // ... 其他可能的字段 (gender, birthday, etc.)

  const UserInfoModel({
    required this.userId,
    required this.mobile,
    this.nickname,
    this.avatar,
    // ... 其他字段
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    // API 响应结构可能是在 'data' 字段下
    final data = json.containsKey('data') && json['data'] is Map<String, dynamic>
                 ? json['data'] as Map<String, dynamic>
                 : json; // 如果没有 data 嵌套，直接使用顶层 json

    // 确定 userId 的字段名 (可能是 id, user_id, memberId 等)
    final userIdField = data.containsKey('id') ? 'id'
                      : data.containsKey('user_id') ? 'user_id'
                      : data.containsKey('memberId') ? 'memberId'
                      : null;

    if (userIdField == null) {
      throw FormatException('Failed to find userId field (id, user_id, or memberId) in user info response.');
    }
    if (!data.containsKey('mobile')) {
        throw FormatException('User info response missing required field: mobile');
    }

    return UserInfoModel(
      // TODO: 确认 userId 的实际类型 (int or String?)
      userId: data[userIdField].toString(), // 转换为 String 以兼容
      mobile: data['mobile'] as String,
      nickname: data['nickname'] as String?,
      avatar: data['avatar'] as String?,
      // ... 解析其他字段
    );
  }

  @override
  List<Object?> get props => [userId, mobile, nickname, avatar];
}
