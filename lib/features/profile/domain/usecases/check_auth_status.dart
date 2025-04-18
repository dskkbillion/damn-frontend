import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_auth_repository.dart';

/// 检查认证状态的用例
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final IAuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final isLoggedIn = await repository.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
