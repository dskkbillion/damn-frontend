import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_dto.dart';

const cachedUserProfile = 'CACHED_USER_PROFILE';

/// 本地数据源抽象接口
abstract class ProfileLocalDataSource {
  /// 获取最后缓存的用户个人资料
  ///
  /// 如果没有缓存，则抛出 [CacheException]
  Future<UserProfileDto> getLastUserProfile();

  /// 缓存用户个人资料
  Future<void> cacheUserProfile(UserProfileDto userProfile);

  /// 清除缓存的用户个人资料
  Future<void> clearUserProfile();
}

/// 本地数据源实现
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileDto> getLastUserProfile() async {
    final jsonString = sharedPreferences.getString(cachedUserProfile);
    if (jsonString != null) {
      return UserProfileDto.fromJson(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileDto userProfile) {
    return sharedPreferences.setString(
      cachedUserProfile,
      json.encode(userProfile.toJson()),
    );
  }

  @override
  Future<void> clearUserProfile() {
    return sharedPreferences.remove(cachedUserProfile);
  }
}

/// 缓存异常
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}
