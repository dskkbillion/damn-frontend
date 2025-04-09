import 'package:dio/dio.dart'; // 假设使用 Dio 作为网络客户端

import 'package:damn_frontend/core/error/exceptions.dart'; // 假设有自定义 Exception
import 'package:damn_frontend/features/auth/domain/entities/auth_credentials.dart';
import 'package:damn_frontend/features/auth/domain/entities/registration_details.dart';
// import 'package:damn_frontend/features/auth/domain/entities/verification_purpose.dart'; // No longer needed
import '../models/authenticated_user_model.dart'; // Renamed to LoginResponseModel
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; // 网络客户端通过依赖注入传入

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    const String endpoint = '/api/auth/login';
    final Map<String, dynamic> data = {
      'mobile': credentials.phone,
      'code': credentials.code,
      'scene': 'sms_code_login',
    };

    try {
      final response = await dio.post(endpoint, data: data);

      if (response.statusCode == 200 && response.data != null) {
        // TODO: 确认是否需要检查 response.data['code'] == 200
        return LoginResponseModel.fromJson(response.data);
      } else {
        print('Login API returned status ${response.statusCode} or empty data.');
        throw ServerException(
            'Login failed. Status: ${response.statusCode}, Data: ${response.data?.toString() ?? 'N/A'}');
      }
    } on DioException catch (e) {
      print('DioException during login: ${e.message}');
      throw ServerException('Login failed due to network or server error.');
    } on FormatException catch (e) {
      print('Error parsing login response: ${e.toString()}');
      throw ServerException('Failed to parse login response.');
    } catch (e) {
      print('Unknown error during login: ${e.toString()}');
      throw ServerException('An unknown error occurred during login.');
    }
  }

  @override
  Future<void> register(RegistrationDetails details) async {
    const String endpoint = '/api/auth/register';
    // 构建请求体，基于 API 文档，但与 RN 实现可能冲突
    // 后端需要最终确认这些字段
    final Map<String, dynamic> data = {
      'mobile': details.phone,
      'code': details.code,
      'scene': details.scene,
      'password': details.password,
      // API 文档定义 inviterId 为 integer? nullable? required?
      // 暂时根据之前的实体定义发送 int? 类型
      'inviterId': details.inviterId,
    };

    print('Attempting registration with data (based on API doc, may differ from RN): $data');

    try {
      final response = await dio.post(endpoint, data: data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Registration successful.');
        return;
      } else {
        print('Register API returned status ${response.statusCode}.');
        throw ServerException(
            'Registration failed. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during registration: ${e.message}');
      throw ServerException('Registration failed due to network or server error.');
    } catch (e) {
      print('Unknown error during registration: ${e.toString()}');
      throw ServerException('An unknown error occurred during registration.');
    }
  }

  @override
  Future<void> sendVerificationCode({
    required String phone,
    // VerificationPurpose purpose, // Removed
  }) async {
    const String endpoint = '/api/common/send-code/register'; // Confirmed endpoint
    final Map<String, dynamic> data = {
      'mobile': phone, // Confirmed body
      // 'scene': ... // No longer seems needed based on RN code
    };

    try {
      final response = await dio.post(endpoint, data: data);
      // RN 代码检查 res?.data?.code !== 200，这里做类似处理
      if (response.statusCode == 200 && response.data != null /*&& response.data['code'] == 200*/) {
         print('Verification code sent successfully.');
        return;
      } else {
         print('Send code API returned status ${response.statusCode} or business error: ${response.data?.toString()}');
         throw ServerException(
            'Failed to send verification code. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during send code: ${e.message}');
      throw ServerException('Send code failed due to network or server error.');
    } catch (e) {
      print('Unknown error during send code: ${e.toString()}');
      throw ServerException('An unknown error occurred while sending the code.');
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
