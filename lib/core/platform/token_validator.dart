import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Token验证结果的枚举
enum TokenValidationResult {
  /// Token有效
  valid,

  /// Token过期
  expired,

  /// Token无效（格式错误或被篡改）
  invalid,

  /// 验证过程中出现错误
  error
}

/// Token验证器接口
abstract class TokenValidator {
  /// 验证Token的有效性
  ///
  /// 返回一个[TokenValidationResult]表示验证结果
  Future<TokenValidationResult> validateToken(String token);
}

/// Token验证器默认实现
@LazySingleton(as: TokenValidator)
class TokenValidatorImpl implements TokenValidator {
  final Dio dio;

  TokenValidatorImpl(this.dio);

  @override
  Future<TokenValidationResult> validateToken(String token) async {
    // 简单的格式检查
    if (token.isEmpty) {
      return TokenValidationResult.invalid;
    }

    // JWT格式检查（基本格式：header.payload.signature）
    if (!token.contains('.') || token.split('.').length != 3) {
      return TokenValidationResult.invalid;
    }

    try {
      // 调用API验证Token
      final response = await dio.get(
        '/api/member/info', // 使用获取用户信息的接口来验证Token
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'clienttype': '1',
            'client': 'android',
            'version': '100',
          },
        ),
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 检查业务状态码
        if (response.data != null &&
            (response.data['code'] == 200 || response.data['code'] == 0)) {
          return TokenValidationResult.valid;
        }

        // 检查是否有过期信息
        if (response.data != null &&
            response.data['code'] != null &&
            response.data['msg'] != null) {
          final message = response.data['msg'].toString().toLowerCase();
          if (message.contains('expire') ||
              message.contains('expired') ||
              message.contains('过期')) {
            return TokenValidationResult.expired;
          }
        }

        // 其他业务错误视为Token无效
        return TokenValidationResult.invalid;
      } else if (response.statusCode == 401) {
        // 401表示未授权，Token无效或过期
        return TokenValidationResult.expired;
      } else {
        // 其他HTTP错误
        return TokenValidationResult.error;
      }
    } on DioException catch (e) {
      // 处理网络请求异常
      if (e.response?.statusCode == 401) {
        return TokenValidationResult.expired;
      }
      return TokenValidationResult.error;
    } catch (e) {
      // 其他未知异常
      return TokenValidationResult.error;
    }
  }
}
