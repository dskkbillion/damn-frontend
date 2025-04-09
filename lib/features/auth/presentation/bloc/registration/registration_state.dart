part of 'registration_cubit.dart';

/// 注册页面的状态
abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class RegistrationInitial extends RegistrationState {}

/// 正在发送验证码
class RegistrationCodeSending extends RegistrationState {}

/// 验证码发送成功
class RegistrationCodeSentSuccess extends RegistrationState {
   final int initialCountdownSeconds;
   const RegistrationCodeSentSuccess({this.initialCountdownSeconds = 60});

    @override
   List<Object?> get props => [initialCountdownSeconds];
}

/// 验证码发送失败
class RegistrationCodeSendFailure extends RegistrationState {
  final Failure failure;
  const RegistrationCodeSendFailure(this.failure);

   @override
  List<Object?> get props => [failure];
}

/// 正在执行注册操作
class RegistrationLoading extends RegistrationState {}

/// 注册成功 (不需要携带 User)
class RegistrationSuccess extends RegistrationState {}

/// 注册失败
class RegistrationFailure extends RegistrationState {
  final Failure failure;
  const RegistrationFailure(this.failure);

   @override
  List<Object?> get props => [failure];
}
