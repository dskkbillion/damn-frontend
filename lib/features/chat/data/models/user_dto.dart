import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// 用户数据传输对象
class UserDto extends Equatable {
  /// 用户ID
  final String id;
  
  /// 用户名称
  final String name;
  
  /// 头像URL
  final String? avatar;
  
  /// 在线状态
  final String? status;
  
  /// 通用用户ID (用于WebSocket连接)
  final String? commonUserId;

  const UserDto({
    required this.id,
    required this.name,
    this.avatar,
    this.status,
    this.commonUserId,
  });

  /// 从JSON映射创建DTO
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nickname'] ?? '',
      avatar: json['avatar'] ?? json['avatar_url'],
      status: json['status'] ?? json['online_status'],
      commonUserId: json['common_user_id'],
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (avatar != null) 'avatar': avatar,
      if (status != null) 'status': status,
      if (commonUserId != null) 'common_user_id': commonUserId,
    };
  }

  /// 转换为领域实体
  User toDomain() {
    // 解析在线状态
    OnlineStatus onlineStatus;
    switch (status?.toLowerCase()) {
      case 'online':
        onlineStatus = OnlineStatus.ONLINE;
        break;
      case 'busy':
        onlineStatus = OnlineStatus.BUSY;
        break;
      case 'away':
        onlineStatus = OnlineStatus.AWAY;
        break;
      default:
        onlineStatus = OnlineStatus.OFFLINE;
    }
    
    return User(
      id: id,
      name: name,
      avatar: avatar,
      onlineStatus: onlineStatus,
    );
  }

  /// 从领域实体创建DTO
  factory UserDto.fromDomain(User user) {
    // 转换在线状态
    String? statusStr;
    switch (user.onlineStatus) {
      case OnlineStatus.ONLINE:
        statusStr = 'online';
        break;
      case OnlineStatus.BUSY:
        statusStr = 'busy';
        break;
      case OnlineStatus.AWAY:
        statusStr = 'away';
        break;
      default:
        statusStr = 'offline';
    }
    
    return UserDto(
      id: user.id,
      name: user.name,
      avatar: user.avatar,
      status: statusStr,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    status,
    commonUserId,
  ];
} 