import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import '../models/user_profile_dto.dart';

const cachedUserProfile = 'CACHED_USER_PROFILE';

/// 本地数据源抽象接口
abstract class ProfileLocalDataSource {
  /// 获取上次缓存的用户个人资料
  ///
  /// 如果没有缓存的数据，则抛出 [CacheException]
  Future<UserProfileDto> getLastUserProfile();

  /// 缓存用户个人资料
  ///
  /// [userProfile] 要缓存的用户个人资料
  Future<void> cacheUserProfile(UserProfileDto userProfile);

  /// 清除缓存的用户个人资料
  Future<void> clearUserProfile();
}

/// 本地数据源实现
@Injectable(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileDto> getLastUserProfile() async {
    final jsonString = sharedPreferences.getString('USER_PROFILE');
    if (jsonString != null) {
      return Future.value(UserProfileDto(
        userId: 'cached_user',
        nickName: '缓存用户',
        avatarUrl: 'https://example.com/avatar.jpg',
        onlineFlag: true,
      ));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileDto userProfile) {
    return Future.value();
  }

  @override
  Future<void> clearUserProfile() {
    return sharedPreferences.remove(cachedUserProfile);
  }
}

/// 缓存异常
class CacheException implements Exception {}
