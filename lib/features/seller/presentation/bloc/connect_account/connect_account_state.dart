import 'package:equatable/equatable.dart';
import '../../../data/datasources/stripe_connect_remote_data_source.dart';

abstract class ConnectAccountState extends Equatable {
  const ConnectAccountState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ConnectAccountInitial extends ConnectAccountState {}

/// 加载中
class ConnectAccountLoading extends ConnectAccountState {}

/// 未绑定（未创建 Connect 账户）
class ConnectAccountUnlinked extends ConnectAccountState {}

/// Onboarding 链接已就绪，可以跳转
class ConnectAccountOnboardingReady extends ConnectAccountState {
  final String onboardingUrl;

  const ConnectAccountOnboardingReady({required this.onboardingUrl});

  @override
  List<Object?> get props => [onboardingUrl];
}

/// 等待 Stripe 审核
class ConnectAccountPendingVerification extends ConnectAccountState {
  final ConnectAccountStatus accountStatus;

  const ConnectAccountPendingVerification({required this.accountStatus});

  @override
  List<Object?> get props => [accountStatus];
}

/// 账户已激活
class ConnectAccountActive extends ConnectAccountState {
  final ConnectAccountStatus accountStatus;

  const ConnectAccountActive({required this.accountStatus});

  @override
  List<Object?> get props => [accountStatus];
}

/// 错误
class ConnectAccountError extends ConnectAccountState {
  final String message;

  const ConnectAccountError({required this.message});

  @override
  List<Object?> get props => [message];
}
