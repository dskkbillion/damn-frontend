import 'package:equatable/equatable.dart';

/// 用户实体 (主要字段来自 /api/member/info)
class User extends Equatable {
  /// 用户 ID (系统内部 ID)
  final int id;

  /// 昵称
  final String nickName;

  /// 头像 URL
  final String? avatar;

  /// 通用用户 ID (重要: 用于 WebSocket 连接)
  final int commonUserId;

  const User({
    required this.id,
    required this.nickName,
    this.avatar,
    required this.commonUserId,
  });

  @override
  List<Object?> get props => [id, nickName, avatar, commonUserId];
} 