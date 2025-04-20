import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import '../entities/user.dart';

abstract class IUserRepository {
  Future<Either<Failure, User>> getCurrentUser();
  // Add other auth-related methods if needed (e.g., login, logout, etc.)
} 