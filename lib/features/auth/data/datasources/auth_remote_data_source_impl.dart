import 'dart:io' show Platform;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
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

  AuthRemoteDataSourceImpl({required this.dio}) {
    // 添加全局请求头
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // 添加后端实际需要的请求头
      'clienttype': '1',
      'client': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'),
      'version': '100',
    };
    AppLogger.d('Dio配置: 基础URL=${dio.options.baseUrl}, 请求头=${dio.options.headers}');
  }

  @override
  Future<AuthenticatedUserModel> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    const String endpoint = '/api/auth/login';
    final bool isEmail = credentials.phone.contains('@');
    final Map<String, dynamic> data = {
      'mobile': credentials.phone,
      'code': credentials.code,
      'scene': isEmail ? 'email_code_login' : 'sms_code_login',
    };

    AppLogger.d('===== 登录 =====');
    AppLogger.d('请求接口: $endpoint');
    AppLogger.d('登录标识: ${credentials.phone}, 验证码: [REDACTED]');

    try {
      AppLogger.d('开始发送请求...');
      final response = await dio.post(endpoint, data: data);
      AppLogger.d('收到服务器响应: 状态码 ${response.statusCode}');
      AppLogger.d('登录响应已接收（敏感字段不记录）');

      // 检查HTTP状态码和业务状态码
      if (response.statusCode == 200 &&
          response.data != null &&
          (response.data['code'] == 200 || response.data['code'] == 0) &&
          response.data['token'] != null) {
        AppLogger.d('登录成功（Token 已安全接收，不记录）');
        return AuthenticatedUserModel.fromJson(response.data);
      } else {
        AppLogger.d('登录失败: HTTP状态码 ${response.statusCode}, 业务状态码 ${response.data['code']}, 响应消息: ${response.data['msg']}');
        final String errorMsg = response.data['msg'] ?? '登录失败';
        throw ServerException(message: errorMsg);
      }
    } on DioException catch (e) {
      AppLogger.d('DIO错误: ${e.message}');
      AppLogger.d('请求信息: ${e.requestOptions.uri}');
      AppLogger.d('登录请求失败（请求体包含验证码，不记录）');
      if (e.response != null) {
        AppLogger.d('错误响应状态码: ${e.response?.statusCode}');
        AppLogger.d('登录错误响应已接收（敏感字段不记录）');
        // 检查响应中是否有具体的错误信息
        if (e.response?.data is Map && e.response?.data['msg'] != null) {
          final String errorMsg = e.response?.data['msg'];
          throw ServerException(message: errorMsg);
        }
      }
      throw ServerException(message: '登录失败，网络或服务器错误');
    } on FormatException catch (e) {
      AppLogger.d('响应解析错误: ${e.toString()}');
      throw ServerException(message: '登录响应解析失败');
    } catch (e) {
      AppLogger.d('未知错误: ${e.toString()}');
      throw ServerException(message: '登录失败，请稍后重试');
    }
  }

  // register 方法已彻底移除
  // @override
  // Future<void> register(RegistrationDetails details) async { ... }

  @override
  Future<void> sendVerificationCode({
    required String phone,
  }) async {
    // 使用登录验证码接口，因为我们的登录注册是合一的
    const String endpoint = '/api/common/send-code/login';
    final bool isEmail = phone.contains('@');
    final Map<String, dynamic> data = {
      'mobile': phone,
      'scene': isEmail ? 'email_code_login' : 'sms_code_login',
    };

    AppLogger.d('===== 发送验证码 =====');
    AppLogger.d('请求接口: $endpoint');
    AppLogger.d('手机号: $phone');
    AppLogger.d('请求头: ${dio.options.headers}');

    try {
      AppLogger.d('开始发送请求...');
      final response = await dio.post(endpoint, data: data);
      AppLogger.d('收到服务器响应: 状态码 ${response.statusCode}');
      AppLogger.d('响应数据: ${response.data}');
      AppLogger.d('code类型: ${response.data['code'].runtimeType}, code值: ${response.data['code']}');

      // 检查HTTP状态码和业务状态码
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
         AppLogger.d('验证码发送成功!');
        return;
      } else {
         AppLogger.d('验证码发送失败: HTTP状态码 ${response.statusCode}, 业务状态码 ${response.data['code']}, 响应消息: ${response.data['msg']}');
         // 可以考虑解析 response.data 中的错误信息 (如果后端返回了结构化错误)
         throw ServerException(
            message: '发送验证码失败: ${response.data['msg']}');
      }
    } on DioException catch (e) {
      AppLogger.d('DIO错误: ${e.message}');
      AppLogger.d('请求信息: ${e.requestOptions.uri}');
      AppLogger.d('请求数据: ${e.requestOptions.data}');
      AppLogger.d('请求头: ${e.requestOptions.headers}');
      if (e.response != null) {
        AppLogger.d('错误响应状态码: ${e.response?.statusCode}');
        AppLogger.d('错误响应数据: ${e.response?.data}');
      }
      throw ServerException(message: '验证码发送失败，网络或服务器错误');
    } catch (e) {
      AppLogger.d('未知错误: ${e.toString()}');
      throw ServerException(message: '验证码发送失败，请稍后重试');
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
