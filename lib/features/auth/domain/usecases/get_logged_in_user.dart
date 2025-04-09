import 'package:dartz/dartz.dart';
import 'package:damn_frontend/core/error/failures.dart';
import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart';
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'get_logged_in_user.dart';

/// 同步获取当前登录的用户凭证（如果已认证）。
abstract class GetLoggedInUserUseCase {
  Either<Failure, AuthenticatedUser?> call();
}

class GetLoggedInUser implements GetLoggedInUserUseCase {
  final IAuthRepository repository;

  GetLoggedInUser(this.repository);

  @override
  Either<Failure, AuthenticatedUser?> call() {
    // 直接调用 repository 的同步方法
    return repository.getLoggedInUserSync();
  }
}
