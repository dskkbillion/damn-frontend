/// Abstract interface for securely storing key-value data.
/// Implementations might use flutter_secure_storage, SharedPreferences (less secure),
/// or other platform-specific secure storage mechanisms.
abstract class ISecureStorageRepository {
  /// Reads an integer value associated with the [key].
  /// Returns null if the key is not found or the value cannot be parsed as int.
  Future<int?> getInt(String key);

  /// Reads a string value associated with the [key].
  /// Returns null if the key is not found.
  Future<String?> getString(String key);

  /// Saves an integer [value] associated with the [key].
  Future<void> saveInt(String key, int value);

  /// Saves a string [value] associated with the [key].
  Future<void> saveString(String key, String value);

  /// Deletes the value associated with the [key].
  Future<void> delete(String key);

  /// Deletes all authentication related data (e.g., user id, token).
  /// Implementations should know which keys to delete.
  Future<void> clearAllAuthData();

  // Convenience methods often derived from the above, mirroring Fake implementation

  /// Retrieves the stored authentication token.
  Future<String?> getToken() => getString('auth_token'); // Default implementation using getString

  /// Retrieves the stored user ID (as a string).
  Future<String?> getUserId() async { // Default implementation using getInt
    final id = await getInt('user_id');
    return id?.toString();
  }

  /// Saves the authentication token.
  Future<void> saveToken(String token) => saveString('auth_token', token);

  /// Saves the user ID (assuming it's an int internally).
  Future<void> saveUserId(String userId) async { // Default implementation using saveInt
    final id = int.tryParse(userId);
    if (id != null) {
      await saveInt('user_id', id);
    }
    // Handle error case? Or assume valid string?
  }

  /// Deletes the stored authentication token.
  Future<void> deleteToken() => delete('auth_token');

  /// Deletes the stored user ID.
  Future<void> deleteUserId() => delete('user_id');
}
