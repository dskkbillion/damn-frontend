import 'package:damn_frontend/features/auth/domain/entities/auth_status.dart';
import 'package:damn_frontend/features/auth/domain/repositories/i_auth_repository.dart';
import 'get_auth_status_stream.dart';

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
