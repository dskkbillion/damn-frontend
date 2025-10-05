import 'dart:io' show Platform;
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
    print('Dio配置: 基础URL=${dio.options.baseUrl}, 请求头=${dio.options.headers}');
  }

  @override
  Future<AuthenticatedUserModel> loginWithVerificationCode(
      VerificationCodeCredentials credentials) async {
    const String endpoint = '/api/auth/login';
    final Map<String, dynamic> data = {
      'mobile': credentials.phone,
      'code': credentials.code,
      'scene': 'sms_code_login',
    };

    print('===== 登录 =====');
    print('请求接口: $endpoint');
    print('手机号: ${credentials.phone}, 验证码: ${credentials.code}');

    try {
      print('开始发送请求...');
      final response = await dio.post(endpoint, data: data);
      print('收到服务器响应: 状态码 ${response.statusCode}');
      print('响应数据: ${response.data}');

      // 检查HTTP状态码和业务状态码
      if (response.statusCode == 200 &&
          response.data != null &&
          (response.data['code'] == 200 || response.data['code'] == 0) &&
          response.data['token'] != null) {
        print('登录成功! Token: ${response.data['token']}');
        return AuthenticatedUserModel.fromJson(response.data);
      } else {
        print('登录失败: HTTP状态码 ${response.statusCode}, 业务状态码 ${response.data['code']}, 响应消息: ${response.data['msg']}');
        String errorMsg = response.data['msg'] ?? '登录失败';
        // 统一验证码相关错误信息
        if (errorMsg.contains('验证码') || errorMsg.contains('code') || errorMsg.contains('Code')) {
          errorMsg = '验证码已过期';
        }
        throw ServerException(message: errorMsg);
      }
    } on DioException catch (e) {
      print('DIO错误: ${e.message}');
      print('请求信息: ${e.requestOptions.uri}');
      print('请求数据: ${e.requestOptions.data}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
        // 检查响应中是否有具体的错误信息
        if (e.response?.data is Map && e.response?.data['msg'] != null) {
          String errorMsg = e.response?.data['msg'];
          // 统一验证码相关错误信息
          if (errorMsg.contains('验证码') || errorMsg.contains('code') || errorMsg.contains('Code')) {
            errorMsg = '验证码已过期';
          }
          throw ServerException(message: errorMsg);
        }
      }
      throw ServerException(message: '登录失败，网络或服务器错误');
    } on FormatException catch (e) {
      print('响应解析错误: ${e.toString()}');
      throw ServerException(message: '登录响应解析失败');
    } catch (e) {
      print('未知错误: ${e.toString()}');
      throw ServerException(message: '登录过程中发生未知错误: ${e.toString()}');
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
    final Map<String, dynamic> data = {
      'mobile': phone,
      // 移除所有额外参数，只保留手机号
    };

    print('===== 发送验证码 =====');
    print('请求接口: $endpoint');
    print('手机号: $phone');
    print('请求头: ${dio.options.headers}');

    try {
      print('开始发送请求...');
      final response = await dio.post(endpoint, data: data);
      print('收到服务器响应: 状态码 ${response.statusCode}');
      print('响应数据: ${response.data}');

      // 检查HTTP状态码和业务状态码
      if (response.statusCode == 200 &&
          (response.data['code'] == 200 || response.data['code'] == 0)) {
         print('验证码发送成功!');
        return;
      } else {
         print('验证码发送失败: HTTP状态码 ${response.statusCode}, 业务状态码 ${response.data['code']}, 响应消息: ${response.data['msg']}');
         // 可以考虑解析 response.data 中的错误信息 (如果后端返回了结构化错误)
         throw ServerException(
            message: '发送验证码失败: ${response.data['msg']}');
      }
    } on DioException catch (e) {
      print('DIO错误: ${e.message}');
      print('请求信息: ${e.requestOptions.uri}');
      print('请求数据: ${e.requestOptions.data}');
      print('请求头: ${e.requestOptions.headers}');
      if (e.response != null) {
        print('错误响应状态码: ${e.response?.statusCode}');
        print('错误响应数据: ${e.response?.data}');
      }
      throw ServerException(message: 'Send code failed due to network or server error: ${e.message}');
    } catch (e) {
      print('未知错误: ${e.toString()}');
      throw ServerException(message: 'An unknown error occurred while sending the code: ${e.toString()}');
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
