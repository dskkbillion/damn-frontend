import 'package:equatable/equatable.dart';

class UserInfo extends Equatable {
  final int id;
  final String? mobile;
  final String? nickName;
  final String? avatar;
  final int? commonUserId;
  // 可以根据需要添加更多从 /api/member/info 获取的字段
  // 例如: gender, status, etc.

  const UserInfo({
    required this.id,
    this.mobile,
    this.nickName,
    this.avatar,
    this.commonUserId,
  });

  @override
  List<Object?> get props => [id, mobile, nickName, avatar, commonUserId];
}
