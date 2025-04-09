import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:damn_frontend/features/auth/domain/entities/auth_status.dart';
import 'package:damn_frontend/features/auth/domain/usecases/get_auth_status_stream.dart';
import 'package:damn_frontend/features/auth/domain/usecases/logout.dart';
import 'dart:async';

/// 全局管理认证状态的 Cubit/Bloc
class AuthStatusCubit extends Cubit<AuthStatus> {
  final GetAuthStatusStreamUseCase getAuthStatusStreamUseCase;
  final LogoutUseCase logoutUseCase;
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  AuthStatusCubit({
    required this.getAuthStatusStreamUseCase,
    required this.logoutUseCase,
  }) : super(const AuthUnknown()) { // 初始状态为未知
    _subscribeToAuthStatus();
  }

  void _subscribeToAuthStatus() {
    _authStatusSubscription = getAuthStatusStreamUseCase().listen(
      (status) => emit(status), // 当 Repository 状态变化时，更新 Cubit 状态
      onError: (error) {
        print('Error in auth status stream: $error');
        emit(const Unauthenticated()); // 出错时视为未认证
      },
    );
  }

  Future<void> performLogout() async {
    // 调用 LogoutUseCase，它会处理 Repository 的状态更新和本地存储清理
    // Cubit 的状态将通过监听 Repository 的 Stream 自动更新
    final result = await logoutUseCase();
    result.fold(
      (failure) {
        // 登出失败通常也需要在 UI 上提示，但状态仍应是 Unauthenticated
        print('Logout failed: $failure');
        // 可以在这里 emit 一个特定的登出失败状态，或者让 UI 处理通用错误
      },
      (_) => print('Logout successful'),
    );
    // 即使 UseCase 调用失败，Repository 层通常也会将 Stream 更新为 Unauthenticated
    // 所以这里一般不需要手动 emit(Unauthenticated())
  }

  @override
  Future<void> close() {
    _authStatusSubscription.cancel(); // 清理 Stream 监听
    return super.close();
  }
}
