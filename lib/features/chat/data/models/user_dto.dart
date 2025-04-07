import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_enums.dart';
import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

/// 用户数据传输对象
///
/// 用于在API和应用之间传输用户数据
@JsonSerializable()
class UserDto {
  /// 用户唯一标识符
  final String id;
  
  /// 用户名称/昵称
  final String name;
  
  /// 用户头像URL
  final String? avatar;
  
  /// 用户在线状态
  @JsonKey(name: 'online_status')
  final String? onlineStatus;
  
  /// 用户简介/个性签名
  final String? bio;
  
  /// 是否是系统用户
  @JsonKey(name: 'is_system')
  final bool? isSystem;

  /// 创建一个用户DTO
  const UserDto({
    required this.id,
    required this.name,
    this.avatar,
    this.onlineStatus,
    this.bio,
    this.isSystem,
  });

  /// 从JSON创建用户DTO
  factory UserDto.fromJson(Map<String, dynamic> json) => 
      _$UserDtoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// 从实体创建DTO
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      avatar: user.avatar,
      onlineStatus: _onlineStatusToString(user.onlineStatus),
      bio: user.bio,
      isSystem: user.isSystem,
    );
  }

  /// 转换为实体
  User toEntity() {
    return User(
      id: id,
      name: name,
      avatar: avatar,
      onlineStatus: _stringToOnlineStatus(onlineStatus),
      bio: bio,
      isSystem: isSystem ?? false,
    );
  }

  // 枚举转换工具方法
  static String? _onlineStatusToString(OnlineStatus status) {
    switch (status) {
      case OnlineStatus.ONLINE:
        return 'online';
      case OnlineStatus.OFFLINE:
        return 'offline';
      case OnlineStatus.BUSY:
        return 'busy';
      case OnlineStatus.AWAY:
        return 'away';
    }
  }

  static OnlineStatus _stringToOnlineStatus(String? status) {
    if (status == null) return OnlineStatus.OFFLINE;
    
    switch (status.toLowerCase()) {
      case 'online':
        return OnlineStatus.ONLINE;
      case 'offline':
        return OnlineStatus.OFFLINE;
      case 'busy':
        return OnlineStatus.BUSY;
      case 'away':
        return OnlineStatus.AWAY;
      default:
        return OnlineStatus.OFFLINE; // 默认为离线
    }
  }
} 