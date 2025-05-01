import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'logout.dart';

/// 处理用户登出流程。
abstract class LogoutUseCase {
  Future<Either<Failure, void>> call();
}

class Logout implements LogoutUseCase {
   final IAuthRepository repository;

   Logout(this.repository);

   @override
   Future<Either<Failure, void>> call() async {
     // 登出操作通常没有太多业务逻辑，直接调用 repository
     return await repository.logout();
   }
}
