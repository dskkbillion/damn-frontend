import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/error/exceptions.dart';

/// Implementation of ISecureStorageRepository using flutter_secure_storage.
@LazySingleton(as: ISecureStorageRepository) // Register as LazySingleton for ISecureStorageRepository
@injectable // Mark class for injectable generator
class SecureStorageRepositoryImpl implements ISecureStorageRepository {
  final FlutterSecureStorage _storage;

  // Inject FlutterSecureStorage instance
  SecureStorageRepositoryImpl(this._storage);

  // Helper function to handle potential exceptions from secure storage
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
  Future<void> delete(String key) async {
    await _tryCatch(() => _storage.delete(key: key), 'delete key $key');
  }

  @override
  Future<int?> getInt(String key) async {
     return _tryCatch(() async {
      final value = await _storage.read(key: key);
      return value == null ? null : int.tryParse(value);
     }, 'get int for key $key');
  }

  @override
  Future<String?> getString(String key) async {
    return _tryCatch(() => _storage.read(key: key), 'get string for key $key');
  }

  @override
  Future<void> saveInt(String key, int value) async {
     await _tryCatch(() => _storage.write(key: key, value: value.toString()), 'save int for key $key');
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _tryCatch(() => _storage.write(key: key, value: value), 'save string for key $key');
  }

  // --- Convenience Methods (already defined in interface, reuse implementation) ---

  @override
  Future<String?> getToken() async => getString('auth_token');

  @override
  Future<String?> getUserId() async => (await getInt('user_id'))?.toString(); // Convert int? to String?

  @override
  Future<void> saveToken(String token) async => saveString('auth_token', token);

  @override
  Future<void> saveUserId(String userId) async {
    final intValue = int.tryParse(userId);
    if (intValue != null) {
      await saveInt('user_id', intValue);
    } else {
      // Handle error: userId is not a valid integer string
      print('Error: Attempted to save non-integer userId ($userId) to secure storage.');
      throw CacheException(message: 'User ID must be an integer.');
    }
  }

  @override
  Future<void> deleteToken() async => delete('auth_token');

  @override
  Future<void> deleteUserId() async => delete('user_id');


  @override
  Future<void> clearAllAuthData() async {
     // Implement clearing logic if needed, e.g., delete both keys
     await deleteToken();
     await deleteUserId();
     print('Cleared all auth data from secure storage.');
  }
}
