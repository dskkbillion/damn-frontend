import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

// Import the interface and exception type
import 'secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // Added from 'ours'

/// 安全存储的键名常量 (from 'theirs')
const String _TOKEN_KEY = 'auth_token';
const String _USER_ID_KEY = 'user_id';
const String _COMMON_USER_ID_KEY = 'common_user_id';

/// 安全存储仓库实现
@LazySingleton(as: ISecureStorageRepository)
@injectable // Added from 'ours'
class SecureStorageRepositoryImpl implements ISecureStorageRepository {
  final FlutterSecureStorage _secureStorage;

  /// 构造函数
  SecureStorageRepositoryImpl(this._secureStorage);

  // Helper function to handle potential exceptions (from 'ours')
  Future<T> _tryCatch<T>(Future<T> Function() action, String operation) async {
    try {
      return await action();
    } catch (e) {
      print('SecureStorage Error during $operation: $e');
      // Wrap the error in a CacheException
      throw CacheException(message: 'Failed to $operation secure storage.');
    }
  }

  @override
  Future<String?> getString(String key) async {
    // Apply error handling from 'ours' to implementation from 'theirs'
    return _tryCatch(() => _secureStorage.read(key: key), 'get string for key $key');
  }

  @override
  Future<void> saveString(String key, String value) async {
    // Apply error handling from 'ours' to implementation from 'theirs'
    await _tryCatch(() => _secureStorage.write(key: key, value: value), 'save string for key $key');
  }

  @override
  Future<int?> getInt(String key) async {
    // Apply error handling from 'ours' to implementation from 'theirs'
     return _tryCatch(() async {
      final value = await _secureStorage.read(key: key);
      return value == null ? null : int.tryParse(value);
     }, 'get int for key $key');
  }

  @override
  Future<void> saveInt(String key, int value) async {
    // Apply error handling from 'ours' to implementation from 'theirs'
    await _tryCatch(() => _secureStorage.write(key: key, value: value.toString()), 'save int for key $key');
  }

  @override
  Future<void> delete(String key) async {
    // Apply error handling from 'ours' to implementation from 'theirs'
    await _tryCatch(() => _secureStorage.delete(key: key), 'delete key $key');
  }

  // --- Convenience Methods (using structure from 'theirs' and constants) ---

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
    // Interface expects int, implementation matches
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
    // Combine implementations: call delete with error handling implicitly via convenience methods
    await deleteToken();
    await deleteUserId();
    await deleteCommonUserId();
    print('Cleared all auth data from secure storage.'); // Added print statement from 'ours'
  }
}

// Removed @module definition from 'theirs' as it's likely redundant with @injectable constructor
