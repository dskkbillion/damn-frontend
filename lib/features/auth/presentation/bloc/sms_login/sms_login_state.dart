import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/entities/authenticated_user.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 短信登录页面的状态
abstract class SmsLoginState extends Equatable {
  const SmsLoginState();

  @override
  List<Object> get props => [];
}

/// 初始状态
class SmsLoginInitial extends SmsLoginState {}

/// 正在发送验证码
class SmsLoginCodeSending extends SmsLoginState {}

/// 验证码发送成功，可以开始倒计时
class SmsLoginCodeSentSuccess extends SmsLoginState {
  final DateTime timestamp;
  SmsLoginCodeSentSuccess({DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object> get props => [timestamp];
}

/// 验证码发送失败
class SmsLoginCodeSendFailure extends SmsLoginState {
  final Failure failure;
  const SmsLoginCodeSendFailure(this.failure);

  @override
  List<Object> get props => [failure];
}

/// 正在执行登录操作
class SmsLoginLoading extends SmsLoginState {}

/// 登录成功
class SmsLoginSuccess extends SmsLoginState {
  final AuthenticatedUser user;
  const SmsLoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

/// 登录失败
class SmsLoginFailure extends SmsLoginState {
  final Failure failure;
  const SmsLoginFailure(this.failure);

  @override
  List<Object> get props => [failure];
}
