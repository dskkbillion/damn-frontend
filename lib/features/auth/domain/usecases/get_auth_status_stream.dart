import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// 获取并监听认证状态的实时变化。
abstract class GetAuthStatusStreamUseCase {
  Stream<AuthStatus> call();
}

class GetAuthStatusStream implements GetAuthStatusStreamUseCase {
  final IAuthRepository repository;

  GetAuthStatusStream(this.repository);

  @override
  Stream<AuthStatus> call() {
    return repository.authStatus;
  }
}
