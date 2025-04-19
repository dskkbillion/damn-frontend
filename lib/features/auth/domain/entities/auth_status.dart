import 'package:equatable/equatable.dart';
import 'authenticated_user.dart';

/// 用户认证状态的枚举。

abstract class AuthStatus extends Equatable {
  const AuthStatus();
}

/// 初始状态或正在检查认证状态。
class AuthUnknown extends AuthStatus {
  const AuthUnknown();

  @override
  List<Object?> get props => [];
}

/// 未认证状态。
class Unauthenticated extends AuthStatus {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

/// 已认证状态，并持有用户凭证。
class Authenticated extends AuthStatus {
  final AuthenticatedUser user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}
