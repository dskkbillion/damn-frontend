import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart';

/// IAuthRepository 的手动 Mock 实现，用于测试和预览环境。
class MockAuthRepository implements IAuthRepository {
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