import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// 定义用户资料的数据访问接口
abstract class IUserProfileRepository {
  /// 获取用户资料
  ///
  /// 返回 [UserProfile] 实体或 [Failure]
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// 更新用户资料
  ///
  /// [data] 更新的用户数据
  /// 返回更新后的 [UserProfile] 实体或 [Failure]
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfileUpdateData data);

  /// 上传头像文件
  ///
  /// [imageFile] 头像图片文件
  /// 返回图片 URL 或 [Failure]
  Future<Either<Failure, String>> uploadAvatar(File imageFile);
}

/// 更新用户资料的数据类
class UserProfileUpdateData {
  final String? nickName;
  final bool? onlineFlag;

  UserProfileUpdateData({
    this.nickName,
    this.onlineFlag,
  });
}
