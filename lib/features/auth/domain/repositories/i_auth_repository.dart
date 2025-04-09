import 'package:dartz/dartz.dart';
import 'package:damn_frontend/core/error/failures.dart';
import '../entities/auth_credentials.dart';
import '../entities/auth_status.dart';
import '../entities/authenticated_user.dart';
import '../entities/registration_details.dart';
// import 'package:damn_frontend/core/domain/entities/user_info.dart'; // 假设 UserInfo 在 Core 中

/// 定义 Auth 模块的数据交互接口
abstract class IAuthRepository {
  /// 提供认证状态的流。
  Stream<AuthStatus> get authStatus;

  /// 执行登录，获取 token，然后获取 userId，存储并返回 AuthenticatedUser。
  Future<Either<Failure, AuthenticatedUser>> loginWithVerificationCode(
      VerificationCodeCredentials credentials);

  /// 执行注册 API 调用。
  Future<Either<Failure, void>> register(RegistrationDetails details);

  /// 执行本地登出逻辑 (清除存储)。
  Future<Either<Failure, void>> logout();

  /// 调用发送验证码 API (/api/common/send-code/register)。
  Future<Either<Failure, void>> sendVerificationCode({
    required String phone,
  });

  /// 同步获取当前内存中的用户（如果存在且有效）。
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
