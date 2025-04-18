part of 'profile_bloc.dart';

/// Profile 模块的状态抽象类
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// 加载中状态
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// 身份验证状态加载完成
class ProfileAuthStatusLoaded extends ProfileState {
  final bool isAuthenticated;

  const ProfileAuthStatusLoaded({required this.isAuthenticated});

  @override
  List<Object> get props => [isAuthenticated];
}

/// 用户资料加载完成
class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// 正在更新资料
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// 资料更新完成
class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}

/// 正在上传头像
class ProfileAvatarUploading extends ProfileState {
  const ProfileAvatarUploading();
}

/// 头像上传完成
class ProfileAvatarUploaded extends ProfileState {
  final String avatarUrl;

  const ProfileAvatarUploaded({required this.avatarUrl});

  @override
  List<Object> get props => [avatarUrl];
}

/// 钱包摘要加载中
class WalletSummaryLoading extends ProfileState {
  const WalletSummaryLoading();
}

/// 钱包摘要加载完成
class WalletSummaryLoaded extends ProfileState {
  final WalletSummary walletSummary;

  const WalletSummaryLoaded({required this.walletSummary});

  @override
  List<Object> get props => [walletSummary];
}

/// 登出中
class ProfileLoggingOut extends ProfileState {
  const ProfileLoggingOut();
}

/// 已登出
class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

/// 正在切换到卖家模式状态
class ProfileSwitchingToSellerMode extends ProfileState {
  const ProfileSwitchingToSellerMode();
}

/// 已切换到卖家模式
class ProfileSwitchedToSellerMode extends ProfileState {
  const ProfileSwitchedToSellerMode();
}

/// 正在切换到买家模式状态
class ProfileSwitchingToBuyerMode extends ProfileState {
  const ProfileSwitchingToBuyerMode();
}

/// 已切换到买家模式状态
class ProfileSwitchedToBuyerMode extends ProfileState {
  const ProfileSwitchedToBuyerMode();
}

/// 发生错误
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}
