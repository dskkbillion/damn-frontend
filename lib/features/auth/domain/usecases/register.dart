import 'package:dartz/dartz.dart';
import 'package:damn_frontend/core/error/failures.dart';
import 'package:damn_frontend/features/auth/domain/entities/registration_details.dart';
// import 'package:damn_frontend/features/auth/domain/entities/authenticated_user.dart'; // Register 不再返回 User
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'register.dart';

/// 处理用户注册流程 (不自动登录)。
abstract class RegisterUseCase {
  Future<Either<Failure, void>> call(RegistrationDetails details);
}

class Register implements RegisterUseCase {
  final IAuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, void>> call(RegistrationDetails details) async {
    // 根据 API 文档，校验 phone, code, scene, password
    if (details.phone.isEmpty ||
        details.code.isEmpty ||
        details.scene.isEmpty ||
        details.password.isEmpty) {
      return Left(ValidationFailure(
          message: 'Phone, code, scene, and password cannot be empty'));
    }
    // TODO: 可能需要根据后端要求校验 scene, password, inviterId 格式

    return await repository.register(details);
  }
}
