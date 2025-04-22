import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'secure_storage_repository.dart';

/// 安全存储的键名常量
const String _TOKEN_KEY = 'auth_token';
const String _USER_ID_KEY = 'user_id';
const String _COMMON_USER_ID_KEY = 'common_user_id';

/// 安全存储仓库实现
@LazySingleton(as: ISecureStorageRepository)
class SecureStorageRepositoryImpl implements ISecureStorageRepository {
  final FlutterSecureStorage _secureStorage;

  /// 构造函数
  SecureStorageRepositoryImpl(this._secureStorage);

  @override
  Future<String?> getString(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<int?> getInt(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) {
      return null;
    }
    return int.tryParse(value);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<String?> getToken() async {
    return await getString(_TOKEN_KEY);
  }

  @override
  Future<void> saveToken(String token) async {
    await saveString(_TOKEN_KEY, token);
  }

  @override
  Future<void> deleteToken() async {
    await delete(_TOKEN_KEY);
  }

  @override
  Future<int?> getUserId() async {
    return await getInt(_USER_ID_KEY);
  }

  @override
  Future<void> saveUserId(int userId) async {
    await saveInt(_USER_ID_KEY, userId);
  }

  @override
  Future<void> deleteUserId() async {
    await delete(_USER_ID_KEY);
  }

  @override
  Future<int?> getCommonUserId() async {
    return await getInt(_COMMON_USER_ID_KEY);
  }

  @override
  Future<void> saveCommonUserId(int commonUserId) async {
    await saveInt(_COMMON_USER_ID_KEY, commonUserId);
  }

  @override
  Future<void> deleteCommonUserId() async {
    await delete(_COMMON_USER_ID_KEY);
  }

  @override
  Future<void> clearAllAuthData() async {
    await deleteToken();
    await deleteUserId();
    await deleteCommonUserId();
  }
}

/// 提供FlutterSecureStorage实例的工厂
@module
abstract class SecureStorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
