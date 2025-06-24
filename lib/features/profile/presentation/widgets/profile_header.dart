import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import '../bloc/profile_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import '../routes/profile_routes.dart'; // 导入路由常量

class ProfileHeader extends ConsumerWidget {
  final ProfileState state;

  const ProfileHeader({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取国际化资源
    final s = S.of(context);
    
    UserProfile? profile;
    if (state is ProfileLoaded) {
      profile = (state as ProfileLoaded).profile;
    } else if (state is ProfileUpdated) {
      profile = (state as ProfileUpdated).profile;
    }
    print('[ProfileHeader] Received state: ${state.runtimeType}');
    print('[ProfileHeader] Extracted profile nickname: ${profile?.nickName}');

    return Container(
      margin: const EdgeInsets.all(12.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
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
            color: Colors.black.withOpacity(0.1),
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
                _buildAvatar(context, profile),
                const SizedBox(width: 16),
                _buildNameAndStatus(context, profile, s),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchToSellerButton(context, ref, s),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserProfile? profile) {
    final imageUrl = profile?.avatarUrl;
    final hasUrl = imageUrl != null && imageUrl.isNotEmpty;
    print('[ProfileHeader] Avatar URL: $imageUrl, Has URL: $hasUrl');

    // 使用InkWell使头像可点击，点击后跳转到账号与安全页面
    return InkWell(
      onTap: () => context.go(ProfileRoutes.accountSecurityPath), // 点击时导航到账号与安全页面
      child: CircleAvatar(
        radius: 35,
        backgroundColor: Colors.white.withOpacity(0.8),
        backgroundImage: hasUrl ? NetworkImage(imageUrl) : null,
        // 只有在没有URL时才显示默认用户图标，有URL时不显示任何图标
        child: !hasUrl
            ? Icon(Icons.person, size: 35, color: Theme.of(context).primaryColor)
            : null,
      ),
    );
  }

  Widget _buildNameAndStatus(BuildContext context, UserProfile? profile, S s) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _showEditNicknameDialog(context, profile?.nickName),
            child: Text(
              profile?.nickName ?? s.profile_default_name,
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
                  color: profile?.onlineFlag == true ? Colors.greenAccent : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: [
                     if (profile?.onlineFlag == true)
                       BoxShadow(
                         color: Colors.greenAccent.withOpacity(0.5),
                         blurRadius: 4,
                       ),
                  ]
                ),
              ),
              const SizedBox(width: 6),
              Text(
                profile?.onlineFlag == true ? s.profile_online : s.profile_offline,
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

  Widget _buildSwitchToSellerButton(BuildContext context, WidgetRef ref, S s) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.storefront_outlined, size: 18),
        label: Text(s.profile_switch_to_seller),
        onPressed: () {
          ref.read(appModeProvider.notifier).state = AppMode.seller;
          try {
            context.go('/seller');
          } catch (e) {
            print('Error navigating to /seller: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.profile_switch_error('$e'))),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _showEditNicknameDialog(BuildContext context, String? currentNickname) {
    // 获取国际化资源
    final s = S.of(context);
    
    final textController = TextEditingController(text: currentNickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.profile_edit_nickname),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: s.profile_nickname_hint,
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.profile_cancel),
          ),
          TextButton(
            onPressed: () {
              final newNickname = textController.text.trim();
              if (newNickname.isNotEmpty) {
                context.read<ProfileBloc>().add(
                  UpdateUserProfileEvent(nickName: newNickname)
                );
              }
              Navigator.pop(context);
            },
            child: Text(s.profile_save),
          ),
        ],
      ),
    );
  }
}
