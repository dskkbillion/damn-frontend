import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/platform/token_validator.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';

/// 验证Token用例参数
class ValidateTokenParams {
  final String token;

  ValidateTokenParams(this.token);
}

/// 验证Token用例
///
/// 这个用例封装了Token验证的业务逻辑，并将[TokenValidationResult]
/// 转换成相应的[Either<Failure, bool>]结果
@injectable
class ValidateTokenUseCase implements UseCase<bool, ValidateTokenParams> {
  final TokenValidator tokenValidator;

  ValidateTokenUseCase(this.tokenValidator);

  @override
  Future<Either<Failure, bool>> call(ValidateTokenParams params) async {
    try {
      final result = await tokenValidator.validateToken(params.token);

      switch (result) {
        case TokenValidationResult.valid:
          return const Right(true);

        case TokenValidationResult.expired:
          return Left(AuthenticationFailure(message: 'Token has expired. Please login again.'));

        case TokenValidationResult.invalid:
          return Left(AuthenticationFailure(message: 'Invalid token. Please login again.'));

        case TokenValidationResult.error:
          return Left(ServerFailure(message: 'Error validating token. Please try again.'));
      }
    } catch (e) {
      return Left(UnknownFailure(message: 'An unknown error occurred during token validation.'));
    }
  }
}
