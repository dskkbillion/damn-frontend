import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源

import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_section.dart';
import '../widgets/profile_menu_section.dart';
import '../routes/profile_routes.dart'; // 导入路由常量

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ProfileBloc>()..add(CheckAuthStatusEvent()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileAuthStatusLoaded && state.isAuthenticated) {
            print('[ProfilePage] Auth confirmed, dispatching data load events.');
            context.read<ProfileBloc>().add(GetUserProfileEvent());
            // context.read<ProfileBloc>().add(GetWalletSummaryEvent());
          } else if (state is ProfileAuthStatusLoaded && !state.isAuthenticated) {
            // 可以在这里处理未认证的导航，如果需要的话
            // context.go('/login');
          } else if (state is ProfileLoggedOut) {
            // 处理登出后的逻辑，导航到登录页面
            print('[ProfilePage] User logged out, redirecting to login page.');
            context.go('/auth/login');
          } else if (state is ProfileUpdated) {
            // 用户信息更新成功，重新获取完整的用户资料以确保UI同步
            print('[ProfilePage] Profile updated successfully, refreshing user data...');
            context.read<ProfileBloc>().add(GetUserProfileEvent());
          } else if (state is ProfileAvatarUploadError) {
            // 处理头像上传失败，显示友好的错误提示，便于调试
            final s = S.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.profile_avatar_upload_failed),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 获取国际化资源
            final s = S.of(context);
            
            print('[ProfilePage] BlocBuilder received state: ${state.runtimeType}');
            
            if (state is ProfileInitial || (state is ProfileAuthStatusLoaded && !state.isAuthenticated)) {
              if (state is ProfileAuthStatusLoaded && !state.isAuthenticated) {
                return _buildLoginPrompt(context);
              }
              return const Center(child: CircularProgressIndicator()); 
            }

            if (state is ProfileLoading) {
                // 可以根据需要显示更精细的加载状态，或者统一处理
                // 这里暂时继续显示之前的UI，避免页面跳跃
                // return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(child: Text(s.profile_loading_error(state.message)));
            }
            
            return _buildMainContent(context, state); 
          },
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    // 获取国际化资源
    final s = S.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.profile_personal_center),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.profile_login_prompt,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 导航到登录页面
                // TODO: 使用导航服务
                // navigationService.navigateToLogin();
              },
              child: Text(s.profile_login_button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileState state) {
    // 获取国际化资源
    final s = S.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // 下拉刷新时重新加载数据
            context.read<ProfileBloc>().add(GetUserProfileEvent());
            // context.read<ProfileBloc>().add(GetWalletSummaryEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息头部
                ProfileHeader(),

                // 我的订单
                const OrderStatusSection(),

                // 我的多看
                ProfileMenuSection(
                  title: s.profile_my_dskk,
                  menuItems: [
                    MenuItem(
                      icon: Icons.star_border,
                      text: s.profile_favorites,
                      onTap: () {
                        // 导航到收藏列表
                        context.go('/favorites');
                      },
                    ),
                  ],
                ),

                // 我的钱包
                ProfileMenuSection(
                  title: s.profile_my_wallet,
                  menuItems: [
                    MenuItem(
                      icon: Icons.account_balance_wallet,
                      text: s.profile_wallet,
                      onTap: () {
                        // 使用go_router导航到钱包页面
                        context.go(ProfileRoutes.walletPath);
                      },
                    ),
                  ],
                ),

                // 设置
                ProfileMenuSection(
                  title: s.profile_settings,
                  menuItems: [
                    MenuItem(
                      icon: Icons.security,
                      text: s.profile_account_security,
                      onTap: () {
                        // 使用go_router导航到账号安全页面
                        context.go(ProfileRoutes.accountSecurityPath);
                      },
                    ),
                    MenuItem(
                      icon: Icons.notifications_none,
                      text: s.profile_message_notifications,
                      onTap: () {
                        // TODO: 导航到消息通知页面
                        // navigationService.navigateToNotifications();
                      },
                    ),
                    // 添加语言设置选项
                    MenuItem(
                      icon: Icons.language,
                      text: s.language_settings,
                      onTap: () {
                        context.go(ProfileRoutes.languageSettingsPath);
                      },
                    ),
                  ],
                ),

                // 关于我们
                ProfileMenuSection(
                  title: s.profile_about_us,
                  menuItems: [
                    MenuItem(
                      icon: Icons.smart_toy_outlined,
                      text: s.profile_assistant_mission,
                      onTap: () {
                        // 导航到小帮手的使命页面
                        context.go(ProfileRoutes.assistantMissionPath);
                      },
                    ),
                  ],
                ),

                // 底部空间
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
