import 'package:equatable/equatable.dart';

/// 用户在线状态枚举
enum OnlineStatus {
  /// 在线
  ONLINE,
  /// 离线
  OFFLINE,
  /// 忙碌
  BUSY,
  /// 离开
  AWAY,
}

/// 用户实体类
class User extends Equatable {
  /// 用户ID
  final String id;
  
  /// 用户名称
  final String name;
  
  /// 头像URL
  final String? avatar;
  
  /// 在线状态
  final OnlineStatus onlineStatus;

  const User({
    required this.id,
    required this.name,
    this.avatar,
    this.onlineStatus = OnlineStatus.OFFLINE,
  });

  /// 复制并返回一个新的用户对象，可更新指定字段
  User copyWith({
    String? id,
    String? name,
    String? avatar,
    OnlineStatus? onlineStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      onlineStatus: onlineStatus ?? this.onlineStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    onlineStatus,
  ];
} 