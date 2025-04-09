// TODO: 考虑引入 core/usecases/usecase.dart 或类似的基础 UseCase 定义

import 'package:dartz/dartz.dart';
import 'package:damn_frontend/core/error/failures.dart'; // 假设 Failure 定义在 core 中
import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart';
import 'package:damn_frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'login_with_verification_code.dart';

/// 处理使用手机和验证码登录的流程。
abstract class LoginWithVerificationCodeUseCase {
  Future<Either<Failure, AuthenticatedUser>> call(VerificationCodeCredentials credentials);
}

class LoginWithVerificationCode implements LoginWithVerificationCodeUseCase {
  final IAuthRepository repository;

  LoginWithVerificationCode(this.repository);

  @override
  Future<Either<Failure, AuthenticatedUser>> call(VerificationCodeCredentials credentials) async {
    // TODO: 可以在这里添加额外的业务逻辑，例如参数校验
    if (credentials.phone.isEmpty || credentials.code.isEmpty) {
      return Left(ValidationFailure(message: 'Phone and code cannot be empty'));
    }
    if (credentials.code.length < 4) { // 假设验证码至少4位
        return Left(ValidationFailure(message: 'Invalid verification code format'));
    }
    return await repository.loginWithVerificationCode(credentials);
  }
}
