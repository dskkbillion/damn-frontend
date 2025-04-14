import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// Authentication Repository Interface
///
/// Defines the contract for authentication related operations,
/// primarily retrieving the authentication token needed for API calls.
abstract class IAuthRepository {
  /// Retrieves the current authentication token.
  ///
  /// Returns [Right<String>] containing the token on success.
  /// Returns [Left<Failure>] on failure (e.g., not logged in, token expired).
  Future<Either<Failure, String>> getToken();
} 