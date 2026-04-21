import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/verification_purpose.dart'; // 不再需要
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
    // 验证输入格式（支持手机号和邮箱）
    if (params.phone.isEmpty) {
      return const Left(ValidationFailure(message: 'Account cannot be empty'));
    }
    
    // 检查是否是邮箱格式
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isEmail = emailRegex.hasMatch(params.phone);
    
    // 如果不是邮箱，则验证手机号格式
    if (!isEmail && params.phone.length < 11) {
      return const Left(ValidationFailure(message: 'Invalid phone number format'));
    }
    
    // 后端的 mobile 参数同时支持手机号和邮箱
    return await repository.sendVerificationCode(phone: params.phone);
  }
}

// UseCase 的参数对象
class SendVerificationCodeParams extends Equatable {
  /// 手机号或邮箱地址
  /// 后端的 mobile 参数同时支持手机号和邮箱
  final String phone;

  const SendVerificationCodeParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}
