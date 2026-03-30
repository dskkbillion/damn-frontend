import 'dart:io';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

import '../bloc/profile_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import '../routes/profile_routes.dart'; // 导入路由常量
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart'; // 导入卖家主页
import 'package:dskk_flutter_refactor/core/services/mode_transition_service.dart';


class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;
    
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        UserProfile? profile;
        bool isUploading = false;
        String? pendingAvatarUrl; // 待显示的新头像URL
        
        if (state is ProfileLoaded) {
          profile = state.profile;
        } else if (state is ProfileUpdated) {
          profile = state.profile;
        } else if (state is ProfileUpdating) {
          profile = state.profile;
        } else if (state is ProfileAvatarUploadError) {
          profile = state.profile;
        } else if (state is ProfileAvatarUploading) {
          profile = state.profile;
          isUploading = true;
        } else if (state is ProfileAvatarUploaded) {
          // 头像上传成功，使用新头像URL和保存的用户信息
          profile = state.profile;
          pendingAvatarUrl = state.avatarUrl;
          AppLogger.d('[ProfileHeader] Avatar upload completed, pending URL: $pendingAvatarUrl');
        }
        
        AppLogger.d('[ProfileHeader] Received state: ${state.runtimeType}');
        AppLogger.d('[ProfileHeader] Extracted profile nickname: ${profile?.nickName}');
        AppLogger.d('[ProfileHeader] Avatar URL: ${profile?.avatarUrl}, Has URL: ${profile?.avatarUrl?.isNotEmpty == true}, IsUploading: $isUploading');

        return Container(
          margin: const EdgeInsets.all(12.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.borderSecondary,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildAvatar(context, profile, state, pendingAvatarUrl),
                    const SizedBox(width: 16),
                    _buildNameAndStatus(context, profile, appLocalizations),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSwitchToSellerButton(context, ref, appLocalizations),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, UserProfile? profile, ProfileState state, String? pendingAvatarUrl) {
    // 使用最新的头像URL
    String? imageUrl = profile?.avatarUrl;

    // 如果是刚上传成功状态，优先使用新URL
    if (state is ProfileAvatarUploaded && pendingAvatarUrl != null) {
      imageUrl = pendingAvatarUrl;
    }

    final hasUrl = imageUrl != null && imageUrl.isNotEmpty;
    final isUploading = state is ProfileAvatarUploading || state is ProfileUpdating;
    AppLogger.d('[ProfileHeader] Avatar URL: $imageUrl (pending: $pendingAvatarUrl, profile: ${profile?.avatarUrl}), Has URL: $hasUrl, IsUploading: $isUploading');

    // 使用InkWell使头像可点击，点击后跳转到账号与安全页面
    return InkWell(
      onTap: () => context.push(ProfileRoutes.accountSecurityPath), // 点击时导航到账号与安全页面
      child: Stack(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.8),
            backgroundImage: hasUrl ? NetworkImage(imageUrl) : null,
            // 只有在没有URL时才显示默认用户图标，有URL时不显示任何图标
            child: !hasUrl
                ? Icon(Icons.person, size: 35, color: Theme.of(context).primaryColor)
                : null,
          ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameAndStatus(BuildContext context, UserProfile? profile, AppLocalizations appLocalizations) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showEditNicknameDialog(context, profile?.nickName),
            child: Text(
              profile?.nickName ?? appLocalizations.profile_default_name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: profile?.onlineFlag == true ? AppColors.success : AppColors.textTertiary,
                  shape: BoxShape.circle,
                  boxShadow: [
                     if (profile?.onlineFlag == true)
                       BoxShadow(
                         color: AppColors.success.withOpacity(0.5),
                         blurRadius: 4,
                       ),
                  ]
                ),
              ),
              const SizedBox(width: 6),
              Text(
                profile?.onlineFlag == true ? appLocalizations.profile_online : appLocalizations.profile_offline,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchToSellerButton(BuildContext context, WidgetRef ref, AppLocalizations appLocalizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.storefront_outlined, size: 18),
        label: Text(appLocalizations.profile_switch_to_seller),
        onPressed: () {
          // 使用模式切换服务触发翻转动画
          final modeTransitionService = ref.read(modeTransitionServiceProvider);
          final appModeNotifier = ref.read(appModeProvider.notifier);
          
          modeTransitionService.triggerTransition(
            targetMode: AppMode.seller,
            onAnimationComplete: () {
              // 动画完成后切换模式
              appModeNotifier.state = AppMode.seller;
              // DualModeNavigationShell 会自动处理页面切换
            },
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _showEditNicknameDialog(BuildContext context, String? currentNickname) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context)!;

    // 在创建 Dialog 前先获取 ProfileBloc 的引用，避免 Dialog 内部 Context 作用域问题
    final profileBloc = context.read<ProfileBloc>();

    final textController = TextEditingController(text: currentNickname);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appLocalizations.profile_edit_nickname),
        content: TextField(
          controller: textController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: appLocalizations.profile_nickname_hint,
            counterText: '', // 隐藏默认计数器
          ),
          onSubmitted: (_) {
            // 支持键盘确认键直接保存
            final newNickname = textController.text.trim();
            if (newNickname.isNotEmpty && newNickname.length <= 20) {
              profileBloc.add(
                UpdateUserProfileEvent(nickName: newNickname)
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(appLocalizations.profile_cancel),
          ),
          TextButton(
            onPressed: () {
              final newNickname = textController.text.trim();
              if (newNickname.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(appLocalizations.profile_nickname_empty_error)),
                );
                return;
              }
              if (newNickname.length > 20) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(appLocalizations.profile_nickname_length_error)),
                );
                return;
              }
              profileBloc.add(
                UpdateUserProfileEvent(nickName: newNickname)
              );
              Navigator.of(dialogContext).pop();
            },
            child: Text(appLocalizations.profile_save),
          ),
        ],
      ),
    );
  }
}
