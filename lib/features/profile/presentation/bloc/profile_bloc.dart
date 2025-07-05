import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/get_wallet_summary.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/upload_avatar.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Profile 模块的 Bloc
@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;
  final UploadAvatarUseCase uploadAvatar;
  final GetWalletSummary getWalletSummary;
  final CheckAuthStatusUseCase checkAuthStatus;
  final LogoutUseCase logout;

  // 保存当前用户信息，用于错误状态时保持用户信息
  UserProfile? _currentProfile;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.uploadAvatar,
    required this.getWalletSummary,
    required this.checkAuthStatus,
    required this.logout,
  }) : super(const ProfileInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<GetWalletSummaryEvent>(_onGetWalletSummary);
    on<LogoutEvent>(_onLogout);
    on<SwitchToSellerModeEvent>(_onSwitchToSellerMode);
    on<SwitchToBuyerModeEvent>(_onSwitchToBuyerMode);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await checkAuthStatus(NoParams());
    result.fold(
      (failure) => emit(ProfileAuthStatusLoaded(isAuthenticated: false)),
      (isAuthenticated) => emit(ProfileAuthStatusLoaded(isAuthenticated: isAuthenticated)),
    );
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await getUserProfile(NoParams());
    result.fold(
      (failure) => emit(ProfileError(message: failure.toString())),
      (profile) {
        _currentProfile = profile; // 保存当前用户信息
        print('[ProfileBloc] Emitting ProfileLoaded with profile: ${profile.nickName}');
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    final result = await updateUserProfile(
      UpdateUserProfileParams(
        nickName: event.nickName,
        avatar: event.avatar,  // 添加头像参数
        onlineFlag: event.onlineFlag,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(message: failure.toString())),
      (profile) {
        _currentProfile = profile; // 更新当前用户信息
        emit(ProfileUpdated(profile: profile));
      },
    );
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileAvatarUploading(profile: _currentProfile));
    final result = await uploadAvatar(UploadAvatarParams(imageFile: event.imageFile));
    result.fold(
      (failure) => emit(ProfileAvatarUploadError(message: failure.toString(), profile: _currentProfile)),
      (avatarUrl) => emit(ProfileAvatarUploaded(avatarUrl: avatarUrl, profile: _currentProfile)),
    );
  }

  Future<void> _onGetWalletSummary(
    GetWalletSummaryEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const WalletSummaryLoading());
    final result = await getWalletSummary(NoParams());
    result.fold(
      (failure) => emit(ProfileError(message: failure.toString())),
      (walletSummary) => emit(WalletSummaryLoaded(walletSummary: walletSummary)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoggingOut());
    final result = await logout(NoParams());
    result.fold(
      (failure) => emit(ProfileError(message: failure.toString())),
      (_) {
        _currentProfile = null; // 清空当前用户信息
        emit(const ProfileLoggedOut());
      },
    );
  }

  Future<void> _onSwitchToSellerMode(
    SwitchToSellerModeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSwitchingToSellerMode());
    // 这里可能需要在 BLoC 以外处理实际的导航逻辑
    // 例如通过 `BlocListener` 监听此状态并使用导航服务
    emit(const ProfileSwitchedToSellerMode());
  }

  Future<void> _onSwitchToBuyerMode(
    SwitchToBuyerModeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSwitchingToBuyerMode());
    // 这里可能需要在 BLoC 以外处理实际的导航逻辑
    emit(const ProfileSwitchedToBuyerMode());
  }
}
