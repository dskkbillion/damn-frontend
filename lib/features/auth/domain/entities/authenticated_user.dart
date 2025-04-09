import 'package:equatable/equatable.dart';

/// 表示已通过身份验证的用户凭证。
class AuthenticatedUser extends Equatable {
  final String userId;
  final String token;

  const AuthenticatedUser({required this.userId, required this.token});

  @override
  List<Object?> get props => [userId, token];
}
