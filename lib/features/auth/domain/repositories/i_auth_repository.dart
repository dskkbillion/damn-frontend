import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/registration_details.dart'; // 移除

/// 定义 Auth 模块的核心数据操作接口
abstract class IAuthRepository {
  /// 提供认证状态变化的流
  Stream<AuthStatus> get authStatus;

  /// 使用验证码进行登录
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials);

  // /// 注册新用户 (已移除)
  // Future<Either<Failure, void>> register(RegistrationDetails details);

  /// 执行登出操作 (主要是本地状态清理)
  Future<Either<Failure, void>> logout();

  /// 发送验证码到指定手机号
  Future<Either<Failure, void>> sendVerificationCode({
    required String phone,
  });

  /// 同步获取当前缓存的登录用户 (可能为 null)
  Either<Failure, AuthenticatedUser?> getLoggedInUserSync();

  // fetchUserId 移至 IUserInfoRepository
  // /// (内部或辅助) 使用 token 获取 userId。
  // /// 返回值是 userId 字符串，如果获取失败则返回 Failure。
  // Future<Either<Failure, String>> fetchUserId(String token);
}

// --- UserInfo Repository Interface (示例，应放在 Core 或 Profile) ---
// /// Interface for fetching user information.
// abstract class IUserInfoRepository {
//   /// Fetches user information using the provided token.
//   Future<Either<Failure, UserInfo>> fetchUserInfo(String token);
// }
