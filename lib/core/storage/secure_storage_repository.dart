import 'package:injectable/injectable.dart';

/// 安全存储仓库接口
/// 
/// 用于安全地存储敏感信息，如token、userId等
abstract class ISecureStorageRepository {
  /// 获取字符串值
  Future<String?> getString(String key);

  /// 保存字符串值
  Future<void> saveString(String key, String value);

  /// 获取整数值
  Future<int?> getInt(String key);

  /// 保存整数值
  Future<void> saveInt(String key, int value);

  /// 删除指定键的值
  Future<void> delete(String key);

  /// 获取认证token
  Future<String?> getToken();

  /// 保存认证token
  Future<void> saveToken(String token);

  /// 删除认证token
  Future<void> deleteToken();

  /// 获取用户ID
  Future<int?> getUserId();

  /// 保存用户ID
  Future<void> saveUserId(int userId);

  /// 删除用户ID
  Future<void> deleteUserId();

  /// 获取通用用户ID
  Future<int?> getCommonUserId();

  /// 保存通用用户ID
  Future<void> saveCommonUserId(int commonUserId);

  /// 删除通用用户ID
  Future<void> deleteCommonUserId();

  /// 清除所有认证数据
  Future<void> clearAllAuthData();
}