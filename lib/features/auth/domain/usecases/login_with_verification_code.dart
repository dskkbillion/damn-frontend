// TODO: 考虑引入 core/usecases/usecase.dart 或类似的基础 UseCase 定义

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart'; // Import injectable

import 'package:dskk_flutter_refactor/core/error/failures.dart'; // 使用包路径
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // 确认路径

/// 处理使用手机号/邮箱和验证码登录的流程。
/// 支持手机号和邮箱两种登录方式。
@lazySingleton // Register UseCase as LazySingleton
@injectable // Mark class for injectable generator
class LoginWithVerificationCodeUseCase
    implements UseCase<AuthenticatedUser, VerificationCodeCredentials> {
  final IAuthRepository repository;

  LoginWithVerificationCodeUseCase(this.repository);

  @override
  Future<Either<Failure, AuthenticatedUser>> call(VerificationCodeCredentials credentials) async {
    // 验证参数（支持手机号和邮箱）
    if (credentials.phone.isEmpty || credentials.code.isEmpty) {
      return Left(ValidationFailure(message: 'Account and code cannot be empty'));
    }
    if (credentials.code.length < 4) { // 假设验证码至少4位
        return Left(ValidationFailure(message: 'Invalid verification code format'));
    }
    return await repository.loginWithVerificationCode(credentials);
  }
}
