import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/profile_preloader_service.dart';
import '../../../../app/app_mode.dart';
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
    on<GetUserProfileCachedEvent>(_onGetUserProfileCached);
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
    // 如果已经有用户数据，不需要重新检查认证状态
    if (state is ProfileLoaded || state is ProfileUpdated) {
      AppLogger.d('[ProfileBloc] Already has profile data, skipping auth check');
      emit(const ProfileAuthStatusLoaded(isAuthenticated: true));
      return;
    }
    
    emit(const ProfileLoading());
    final result = await checkAuthStatus(NoParams());
    result.fold(
      (failure) => emit(const ProfileAuthStatusLoaded(isAuthenticated: false)),
      (isAuthenticated) => emit(ProfileAuthStatusLoaded(isAuthenticated: isAuthenticated)),
    );
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // 如果不跳过缓存，优先尝试从缓存获取数据
    if (!event.skipCache) {
      try {
        final preloaderService = GetIt.instance<ProfilePreloaderService>();
        final cachedProfile = await preloaderService.getCachedData<UserProfile>(
          'user_profile',
          AppMode.buyer, // 默认买家模式，后续可优化为动态获取当前模式
        );

        if (cachedProfile != null) {
          AppLogger.d('[ProfileBloc] Using cached profile data: ${cachedProfile.nickName}');
          _currentProfile = cachedProfile;
          emit(ProfileLoaded(profile: cachedProfile));
          return;
        }
      } catch (e) {
        AppLogger.d('[ProfileBloc] Failed to get cached profile: $e');
      }
    } else {
      AppLogger.d('[ProfileBloc] Skipping cache, fetching fresh data from server');
    }

    // 缓存未命中或跳过缓存，执行正常的数据获取流程
    emit(const ProfileLoading());
    final result = await getUserProfile(NoParams());
    result.fold(
      (failure) => emit(ProfileError(message: failure.toString())),
      (profile) {
        _currentProfile = profile; // 保存当前用户信息
        AppLogger.d('[ProfileBloc] Emitting ProfileLoaded with profile: ${profile.nickName}, avatar: ${profile.avatarUrl}');
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> _onGetUserProfileCached(
    GetUserProfileCachedEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final preloaderService = GetIt.instance<ProfilePreloaderService>();
      final cachedProfile = await preloaderService.getCachedData<UserProfile>(
        'user_profile', 
        event.mode,
      );
      
      if (cachedProfile != null) {
        AppLogger.d('[ProfileBloc] Using cached profile data for ${event.mode.name}: ${cachedProfile.nickName}');
        _currentProfile = cachedProfile;
        emit(ProfileLoaded(profile: cachedProfile));
        return;
      } else {
        AppLogger.d('[ProfileBloc] No cached data found for ${event.mode.name}, triggering normal load');
        // 缓存未命中，触发普通的获取流程
        add(const GetUserProfileEvent());
      }
    } catch (e) {
      AppLogger.d('[ProfileBloc] Failed to get cached profile for ${event.mode.name}: $e');
      // 发生错误时，回退到普通获取流程
      add(const GetUserProfileEvent());
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // 如果当前状态是头像上传成功，保留当前用户资料
    final previousProfile = _currentProfile;

    emit(ProfileUpdating(profile: previousProfile));
    final result = await updateUserProfile(
      UpdateUserProfileParams(
        nickName: event.nickName,
        avatar: event.avatar,  // 添加头像参数
        onlineFlag: event.onlineFlag,
      ),
    );
    await result.fold(
      (failure) {
        AppLogger.d('[ProfileBloc] Failed to update profile: $failure');
        emit(ProfileError(message: failure.toString()));
      },
      (profile) async {
        _currentProfile = profile; // 更新当前用户信息
        AppLogger.d('[ProfileBloc] Profile updated successfully with avatar: ${profile.avatarUrl}');

        // 清除缓存，确保下次获取最新数据
        try {
          final preloaderService = GetIt.instance<ProfilePreloaderService>();
          await preloaderService.clearCache(AppMode.buyer);
          await preloaderService.clearCache(AppMode.seller);
        } catch (e) {
          AppLogger.d('[ProfileBloc] Failed to clear cache: $e');
        }

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
      (avatarUrl) {
        AppLogger.d('[ProfileBloc] Avatar uploaded successfully, URL: $avatarUrl');
        // 更新当前用户资料的头像URL
        if (_currentProfile != null) {
          _currentProfile = _currentProfile!.copyWith(avatarUrl: avatarUrl);
        }
        emit(ProfileAvatarUploaded(avatarUrl: avatarUrl, profile: _currentProfile));
      },
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

    // 切换完成后，恢复用户数据状态，确保卖家模式能显示最新的用户信息
    if (_currentProfile != null) {
      emit(ProfileLoaded(profile: _currentProfile!));
    }
  }

  Future<void> _onSwitchToBuyerMode(
    SwitchToBuyerModeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileSwitchingToBuyerMode());
    // 这里可能需要在 BLoC 以外处理实际的导航逻辑
    emit(const ProfileSwitchedToBuyerMode());

    // 切换完成后，恢复用户数据状态，确保买家模式能显示最新的用户信息
    if (_currentProfile != null) {
      emit(ProfileLoaded(profile: _currentProfile!));
    }
  }
}
