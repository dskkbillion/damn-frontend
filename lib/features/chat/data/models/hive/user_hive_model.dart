import 'package:hive/hive.dart';

import '../../../domain/entities/user.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 2) // typeId 需要在项目中唯一
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String nickName;

  @HiveField(2)
  final String? avatar;

  @HiveField(3)
  final int commonUserId;

  UserHiveModel({
    required this.id,
    required this.nickName,
    this.avatar,
    required this.commonUserId,
  });

  /// 从 Domain Entity 创建 Hive Model
  factory UserHiveModel.fromEntity(User entity) {
    return UserHiveModel(
      id: entity.id,
      nickName: entity.nickName,
      avatar: entity.avatar,
      commonUserId: entity.commonUserId,
    );
  }

  /// 转换为 Domain Entity
  User toEntity() {
    return User(
      id: id,
      nickName: nickName,
      avatar: avatar,
      commonUserId: commonUserId,
    );
  }
} 