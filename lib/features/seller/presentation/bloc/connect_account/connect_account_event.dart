import 'package:equatable/equatable.dart';

abstract class ConnectAccountEvent extends Equatable {
  const ConnectAccountEvent();

  @override
  List<Object?> get props => [];
}

/// 检查 Connect 账户状态
class CheckConnectAccountStatus extends ConnectAccountEvent {}

/// 创建 Connect 账户
class CreateConnectAccount extends ConnectAccountEvent {
  final String country;

  const CreateConnectAccount({required this.country});

  @override
  List<Object?> get props => [country];
}

/// 获取 Onboarding 链接
class FetchOnboardingLink extends ConnectAccountEvent {}

/// 获取 Account Session（用于嵌入式 Onboarding）
class FetchAccountSession extends ConnectAccountEvent {}

/// 刷新账户状态（Onboarding 完成后）
class RefreshConnectAccountStatus extends ConnectAccountEvent {}
