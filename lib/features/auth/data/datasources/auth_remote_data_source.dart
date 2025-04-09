import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/registration_details.dart'; // 不再需要
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/verification_purpose.dart'; // 不再需要

import '../models/authenticated_user_model.dart'; // 重命名为 LoginResponseModel
// import 'package:dskk_flutter_refactor/core/data/models/user_info_model.dart'; // 假设 UserInfoModel 在 Core 中

/// 定义 Auth 模块的远程数据源接口
abstract class AuthRemoteDataSource {
  /// 调用 API 执行验证码登录
  /// 返回包含 token 的响应模型
  Future<AuthenticatedUserModel> loginWithVerificationCode(
      VerificationCodeCredentials credentials);

  /// 调用 API 发送验证码 (/api/common/send-code/register)
  Future<void> sendVerificationCode({
    required String phone,
    // required VerificationPurpose purpose, // 移除 purpose
  });

  // fetchUserInfo 移至 UserInfoRemoteDataSource
  // /// 调用 GET /api/member/info 获取用户信息 (含 userId)
  // Future<Map<String, dynamic>> fetchUserInfo(String token);

  /// (可选) 调用 API 使 Token 失效或执行其他登出操作
  /// RN 代码未显示后端登出，此方法可能不需要
  // Future<void> logout(String token);
}

// --- UserInfo RemoteDataSource Interface (示例，应放在 Core 或 Profile) ---
// /// Interface for fetching user information remotely.
// abstract class UserInfoRemoteDataSource {
//    /// Fetches user information using the provided token.
//   Future<UserInfoModel> fetchUserInfo(String token);
// }
