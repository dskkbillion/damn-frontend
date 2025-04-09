import 'package:dartz/dartz.dart';
import 'package:damn_frontend/core/error/failures.dart';
// import 'package:damn_frontend/features/auth/domain/entities/verification_purpose.dart'; // 不再需要
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'send_verification_code.dart';

// 参数类 - 现在只需要 phone
class SendVerificationCodeParams {
  final String phone;
  // final VerificationPurpose purpose; // 移除

  SendVerificationCodeParams({required this.phone /*, required this.purpose*/ });
}

/// 发送指定用途的验证码。
abstract class SendVerificationCodeUseCase {
  Future<Either<Failure, void>> call(SendVerificationCodeParams params);
}

class SendVerificationCode implements SendVerificationCodeUseCase {
  final IAuthRepository repository;

  SendVerificationCode(this.repository);

  @override
  Future<Either<Failure, void>> call(SendVerificationCodeParams params) async {
    // TODO: 添加手机号格式校验逻辑
    if (params.phone.isEmpty) { // 或者使用更严格的正则校验
      return Left(ValidationFailure(message: 'Invalid phone number format'));
    }
    // 调用 repository 时不再传递 purpose
    return await repository.sendVerificationCode(
        phone: params.phone,
        // purpose: params.purpose,
    );
  }
}
