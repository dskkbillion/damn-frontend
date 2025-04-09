// TODO: 考虑引入 core/usecases/usecase.dart 或类似的基础 UseCase 定义

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:dskk_flutter_refactor/core/error/failures.dart'; // 使用包路径
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // 确认路径

/// 处理使用手机和验证码登录的流程。
class LoginWithVerificationCodeUseCase
    implements UseCase<AuthenticatedUser, VerificationCodeCredentials> {
  final IAuthRepository repository;

  LoginWithVerificationCodeUseCase(this.repository);

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
