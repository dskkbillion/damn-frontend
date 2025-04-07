import 'package:equatable/equatable.dart';

import 'chat_enums.dart';

/// 聊天用户实体类
///
/// 表示参与聊天的用户，包含基本信息和在线状态
class User extends Equatable {
  /// 用户唯一标识符
  final String id;
  
  /// 用户名称/昵称
  final String name;
  
  /// 用户头像URL
  final String? avatar;
  
  /// 用户在线状态
  final OnlineStatus onlineStatus;
  
  /// 用户简介/个性签名
  final String? bio;
  
  /// 是否是系统用户
  final bool isSystem;

  /// 创建一个用户实体
  const User({
    required this.id,
    required this.name,
    this.avatar,
    this.onlineStatus = OnlineStatus.OFFLINE,
    this.bio,
    this.isSystem = false,
  });
  
  /// 创建一个系统用户
  factory User.system() {
    return const User(
      id: 'system',
      name: '系统',
      onlineStatus: OnlineStatus.ONLINE,
      isSystem: true,
    );
  }
  
  /// 创建一个AI用户
  factory User.ai() {
    return const User(
      id: 'ai',
      name: 'AI助手',
      onlineStatus: OnlineStatus.ONLINE,
      isSystem: true,
    );
  }
  
  /// 创建此用户的副本，但部分字段替换为新值
  User copyWith({
    String? id,
    String? name,
    String? avatar,
    OnlineStatus? onlineStatus,
    String? bio,
    bool? isSystem,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      bio: bio ?? this.bio,
      isSystem: isSystem ?? this.isSystem,
    );
  }
  
  /// 将用户状态更新为在线
  User markAsOnline() {
    return copyWith(onlineStatus: OnlineStatus.ONLINE);
  }
  
  /// 将用户状态更新为离线
  User markAsOffline() {
    return copyWith(onlineStatus: OnlineStatus.OFFLINE);
  }
  
  /// 判断用户是否在线
  bool get isOnline => onlineStatus == OnlineStatus.ONLINE;
  
  /// 获取初始头像文本（用于生成默认头像）
  String get initialAvatar {
    if (name.isEmpty) return '';
    return name.substring(0, 1).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, avatar, onlineStatus, bio, isSystem];
} 