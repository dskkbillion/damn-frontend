import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

/// IAuthRepository 的手动 Mock 实现，用于测试和预览环境。
/// Always reports the user as authenticated.
class MockAuthRepository implements IAuthRepository {
  // Define a fake authenticated user using the correct constructor
  final _mockUser = const AuthenticatedUser(
    id: 9999, // Example dev user ID as int
    token: 'fake_dev_token',
  );

  // --- 控制 getCurrentUserId 的行为 ---
  bool _shouldReturnUserId = true;
  String _userIdToReturn = 'mock_user_123'; // 默认模拟用户 ID
  Failure _failureToReturn = AuthFailure('Mock Auth Error: Not logged in'); // 默认模拟错误

  /// 配置 Mock 对象在调用 getCurrentUserId 时是否返回用户 ID。
  void setShouldReturnUserId(bool shouldReturn) {
    _shouldReturnUserId = shouldReturn;
  }

  /// 配置 Mock 对象在成功时返回的用户 ID。
  void setUserIdToReturn(String userId) {
    _userIdToReturn = userId;
  }

   /// 配置 Mock 对象在失败时返回的 Failure 类型。
  void setFailureToReturn(Failure failure) {
    _failureToReturn = failure;
  }

  // Return a stream that immediately emits the fake authenticated status
  @override
  Stream<AuthStatus> get authStatus => Stream.value(Authenticated(_mockUser));

  // Return the fake authenticated user synchronously
  @override
  Either<Failure, AuthenticatedUser?> getLoggedInUserSync() {
    print('[MockAuthRepository] getLoggedInUserSync called, returning mock user.');
    return Right(_mockUser);
  }

  // Simulate successful login
  @override
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    print('[MockAuthRepository] loginWithVerificationCode called (simulated success).');
    // Simulate a short delay
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockUser);
  }

  // Simulate successful logout
  @override
  Future<Either<Failure, void>> logout() async {
    print('[MockAuthRepository] logout called (simulated success).');
    // In a real mock, you might want to change the authStatus stream here
    return const Right(null);
  }

  // Simulate successful code sending
  @override
  Future<Either<Failure, void>> sendVerificationCode({required String phone}) async {
    print('[MockAuthRepository] sendVerificationCode called for $phone (simulated success).');
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> getCurrentUserId() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldReturnUserId) {
      print('[MockAuthRepository] Returning user ID: $_userIdToReturn');
      return Right(_userIdToReturn);
    } else {
       print('[MockAuthRepository] Returning Failure: $_failureToReturn');
      return Left(_failureToReturn);
    }
  }

  // --- 未来可以为其他接口方法添加类似的控制逻辑 ---
} 