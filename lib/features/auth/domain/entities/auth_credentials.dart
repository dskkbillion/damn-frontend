import 'package:equatable/equatable.dart';

/// 认证凭证的基类 (当前仅支持验证码)
abstract class AuthCredentials extends Equatable {
  const AuthCredentials();
}

/// 使用验证码登录的凭证。
class VerificationCodeCredentials extends AuthCredentials {
  final String phone;
  final String code;

  const VerificationCodeCredentials({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}

// // 如果未来支持密码登录，可以取消注释
// class PasswordCredentials extends AuthCredentials {
//   final String identifier; // 手机号或邮箱
//   final String password;
//
//   const PasswordCredentials({required this.identifier, required this.password});
//
//   @override
//   List<Object?> get props => [identifier, password];
// }
