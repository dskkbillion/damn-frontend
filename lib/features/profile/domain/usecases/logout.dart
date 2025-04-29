import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// 用户登出
@lazySingleton
class LogoutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
