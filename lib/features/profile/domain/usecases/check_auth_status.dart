import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// 检查认证状态的用例
@lazySingleton
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  final IAuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    final result = repository.getLoggedInUserSync();
    return result.fold(
      (failure) => Left(failure),
      (user) => Right(user != null),
    );
  }
}
