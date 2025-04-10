import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import 'user_dto.dart';

/// 用户模型类
/// 用于用户数据的转换和处理
class UserModel extends Equatable {
  final UserDto dto;

  const UserModel({required this.dto});

  /// 从DTO创建模型
  factory UserModel.fromDto(UserDto dto) {
    return UserModel(dto: dto);
  }

  /// 从领域实体创建模型
  factory UserModel.fromDomain(User user) {
    return UserModel(dto: UserDto.fromDomain(user));
  }

  /// 从JSON映射创建模型
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(dto: UserDto.fromJson(json));
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return dto.toJson();
  }

  /// 转换为领域实体
  User toDomain() {
    return dto.toDomain();
  }

  @override
  List<Object?> get props => [dto];
} 