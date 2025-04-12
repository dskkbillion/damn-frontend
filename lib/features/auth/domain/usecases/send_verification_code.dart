import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
// import 'package:damn_frontend/features/auth/domain/entities/verification_purpose.dart'; // 不再需要
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart'; // 确认路径
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart'; // Import injectable

// 定义发送验证码的 UseCase
@lazySingleton // Register UseCase as LazySingleton
@injectable // Mark class for injectable generator
class SendVerificationCodeUseCase implements UseCase<void, SendVerificationCodeParams> {
  final IAuthRepository repository;

  SendVerificationCodeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendVerificationCodeParams params) async {
    // 可以在这里添加手机号格式校验
    if (params.phone.isEmpty || params.phone.length < 11) { // Example validation
      return Left(ValidationFailure(message: 'Invalid phone number format'));
    }
    return await repository.sendVerificationCode(phone: params.phone);
  }
}

// UseCase 的参数对象
class SendVerificationCodeParams extends Equatable {
  final String phone;

  const SendVerificationCodeParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}
