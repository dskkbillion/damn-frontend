part of 'profile_bloc.dart';

/// Profile 模块的事件抽象类
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// 检查用户身份验证状态
class CheckAuthStatusEvent extends ProfileEvent {}

/// 获取用户资料
class GetUserProfileEvent extends ProfileEvent {}

/// 更新用户资料
class UpdateUserProfileEvent extends ProfileEvent {
  final String? nickName;
  final String? avatar;  // 添加头像字段
  final bool? onlineFlag;

  const UpdateUserProfileEvent({
    this.nickName,
    this.avatar,  // 添加头像参数
    this.onlineFlag,
  });

  @override
  List<Object?> get props => [nickName, avatar, onlineFlag];
}

/// 上传头像
class UploadAvatarEvent extends ProfileEvent {
  final File imageFile;

  const UploadAvatarEvent({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}

/// 获取钱包摘要
class GetWalletSummaryEvent extends ProfileEvent {}

/// 登出
class LogoutEvent extends ProfileEvent {}

/// 切换到卖家模式
class SwitchToSellerModeEvent extends ProfileEvent {
  const SwitchToSellerModeEvent();
}

/// 切换到买家模式
class SwitchToBuyerModeEvent extends ProfileEvent {
  const SwitchToBuyerModeEvent();
}

/// 获取用户资料（缓存优先）
class GetUserProfileCachedEvent extends ProfileEvent {
  final AppMode mode;
  
  const GetUserProfileCachedEvent({required this.mode});
  
  @override
  List<Object> get props => [mode];
}
