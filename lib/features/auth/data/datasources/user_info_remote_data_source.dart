import 'package:dskk_flutter_refactor/features/auth/data/models/user_info_model.dart'; // Assuming UserInfoModel exists for parsing

/// Defines the remote data source interface for fetching user info.
abstract class UserInfoRemoteDataSource {
  /// Fetches user information from the backend using the provided token.
  ///
  /// Throws [ServerException] for server-side errors.
  /// Throws [UnauthenticatedException] if the token is invalid (e.g., 401).
  Future<UserInfoModel> fetchUserInfo(String token);
}
