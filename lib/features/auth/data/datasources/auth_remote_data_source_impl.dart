import 'package:dio/dio.dart'; // 假设使用 Dio 作为网络客户端

import 'package:dskk_flutter_refactor/core/error/exceptions.dart'; // 假设有自定义 Exception
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_credentials.dart';
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/registration_details.dart'; // 移除
// import 'package:dskk_flutter_refactor/features/auth/domain/entities/verification_purpose.dart'; // No longer needed
import '../models/authenticated_user_model.dart'; // 确认这是登录响应模型
import 'auth_remote_data_source.dart';
import 'package:injectable/injectable.dart'; // Import injectable

@LazySingleton(as: AuthRemoteDataSource) // Register implementation for the interface
@injectable // Mark class for injectable generator
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; // 网络客户端通过依赖注入传入

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthenticatedUserModel> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    const String endpoint = '/api/auth/login';
    final Map<String, dynamic> data = {
      'mobile': credentials.phone,
      // 确认后端接收的是 `code` 还是 `smsCode`，暂时用 `code`
      'code': credentials.code,
      'scene': 'sms_code_login',
    };

    try {
      final response = await dio.post(endpoint, data: data);

      // 确认后端返回 token
      if (response.statusCode == 200 && response.data != null && response.data['token'] != null) {
        // 假设 AuthenticatedUserModel可以直接从整个响应 Map 创建
        // 如果它只期望 data 部分，需要调整为 AuthenticatedUserModel.fromJson(response.data)
        // 或者如果它只包含 token，需要手动创建：AuthenticatedUserModel(token: response.data['token'])
        // TODO: 确认 AuthenticatedUserModel 的 fromJson 构造函数
        return AuthenticatedUserModel.fromJson(response.data);
      } else {
        print(
            'Login API returned status ${response.statusCode} or missing token in data.');
        throw ServerException(
            message: 'Login failed. Status: ${response.statusCode}, Data: ${response.data?.toString() ?? 'N/A'}');
      }
    } on DioException catch (e) {
      print('DioException during login: ${e.message}');
      throw ServerException(message: 'Login failed due to network or server error.');
    } on FormatException catch (e) {
      print('Error parsing login response: ${e.toString()}');
      throw ServerException(message: 'Failed to parse login response.');
    } catch (e) {
      print('Unknown error during login: ${e.toString()}');
      throw ServerException(message: 'An unknown error occurred during login.');
    }
  }

  // register 方法已彻底移除
  // @override
  // Future<void> register(RegistrationDetails details) async { ... }

  @override
  Future<void> sendVerificationCode({
    required String phone,
  }) async {
    const String endpoint = '/api/common/send-code/register';
    final Map<String, dynamic> data = {
      'mobile': phone,
    };

    try {
      final response = await dio.post(endpoint, data: data);
      // 仅检查状态码，因为成功时不一定有特定响应体
      if (response.statusCode == 200 || response.statusCode == 204) {
         print('Verification code sent successfully.');
        return;
      } else {
         print('Send code API returned status ${response.statusCode} or business error: ${response.data?.toString()}');
         // 可以考虑解析 response.data 中的错误信息 (如果后端返回了结构化错误)
         throw ServerException(
            message: 'Failed to send verification code. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during send code: ${e.message}');
      throw ServerException(message: 'Send code failed due to network or server error.');
    } catch (e) {
      print('Unknown error during send code: ${e.toString()}');
      throw ServerException(message: 'An unknown error occurred while sending the code.');
    }
  }

  // fetchUserInfo removed - should be in UserInfoRemoteDataSourceImpl
  // @override
  // Future<Map<String, dynamic>> fetchUserInfo(String token) async { ... }

  // Logout method removed as no backend API call seems needed
 // @override
 // Future<void> logout(String token) async {
   // ... (Implementation removed)
 // }

}
