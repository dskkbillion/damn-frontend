import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源

import '../../../../core/services/profile_preloader_service.dart';
import '../../../../app/app_mode.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_section.dart';
import '../widgets/profile_menu_section.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
import '../routes/profile_routes.dart'; // 导入路由常量

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // 使用BlocProvider.value来使用现有的单例BLoC实例
    final profileBloc = GetIt.instance<ProfileBloc>();

    // 只有在BLoC状态为初始状态时才触发数据加载
    if (profileBloc.state is ProfileInitial) {
      profileBloc.add(CheckAuthStatusEvent());
    }

    return BlocProvider.value(
      value: profileBloc,
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileAuthStatusLoaded && state.isAuthenticated) {
            AppLogger.d(
                '[ProfilePage] Auth confirmed, dispatching data load events.');
            context.read<ProfileBloc>().add(const GetUserProfileEvent());
            // context.read<ProfileBloc>().add(GetWalletSummaryEvent());
          } else if (state is ProfileAuthStatusLoaded &&
              !state.isAuthenticated) {
            // 可以在这里处理未认证的导航，如果需要的话
            // context.go('/login');
          } else if (state is ProfileLoggedOut) {
            // 处理登出后的逻辑，导航到登录页面
            AppLogger.d(
                '[ProfilePage] User logged out, redirecting to login page.');
            context.go('/auth/login');
          } else if (state is ProfileUpdated) {
            // 用户信息更新成功，状态已包含最新数据
            AppLogger.d(
                '[ProfilePage] Profile updated successfully with latest data');
            // 不需要重新获取，ProfileUpdated 状态已经包含最新数据
          } else if (state is ProfileAvatarUploadError) {
            // 处理头像上传失败，显示友好的错误提示，便于调试
            final appLocalizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.profile_avatar_upload_failed),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 获取国际化资源
            final appLocalizations = AppLocalizations.of(context);

            AppLogger.d(
                '[ProfilePage] BlocBuilder received state: ${state.runtimeType}');

            if (state is ProfileInitial ||
                (state is ProfileAuthStatusLoaded && !state.isAuthenticated)) {
              if (state is ProfileAuthStatusLoaded && !state.isAuthenticated) {
                return _buildLoginPrompt(context);
              }
              return const GlassBackdrop(
                child: SafeArea(child: SkeletonPage(itemCount: 3)),
              );
            }

            if (state is ProfileLoading) {
              // 可以根据需要显示更精细的加载状态，或者统一处理
              // 这里暂时继续显示之前的UI，避免页面跳跃
              // return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                  child: Text(
                      appLocalizations.profile_loading_error(state.message)));
            }

            return _buildMainContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.profile_personal_center),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appLocalizations.profile_login_prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingXxl),
            ElevatedButton(
              onPressed: () {
                // 导航到登录页面
                // TODO: 使用导航服务
                // navigationService.navigateToLogin();
              },
              child: Text(appLocalizations.profile_login_button),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileState state) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GlassBackdrop(
        child: RefreshIndicator(
          onRefresh: () async {
            // 下拉刷新时强制从服务器获取最新数据
            AppLogger.d(
                '[ProfilePage] User initiated refresh - fetching fresh data from server');

            // 先清除缓存
            try {
              final preloaderService =
                  GetIt.instance<ProfilePreloaderService>();
              await preloaderService.clearCache(AppMode.buyer);
              await preloaderService.clearCache(AppMode.seller);
            } catch (e) {
              AppLogger.d('[ProfilePage] Failed to clear cache on refresh: $e');
            }

            // 重新加载数据，跳过缓存
            context
                .read<ProfileBloc>()
                .add(const GetUserProfileEvent(skipCache: true));
            // context.read<ProfileBloc>().add(GetWalletSummaryEvent());

            // 等待一下让状态更新
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              // 顶部安全距离作为滚动内容的一部分，而非固定 SafeArea。
              // 因此个人页首屏仍避开状态栏，滚动时卡片却能经过透明顶栏。
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top,
                16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户信息头部
                  const ProfileHeader(),

                  // 我的订单
                  const OrderStatusSection(),

                  // 我的多看
                  ProfileMenuSection(
                    title: appLocalizations.profile_my_dskk,
                    menuItems: [
                      MenuItem(
                        icon: Icons.star_border,
                        text: appLocalizations.profile_favorites,
                        onTap: () {
                          // 导航到收藏列表
                          context.push('/favorites');
                        },
                      ),
                      // #399: 售后常驻入口 —— 买家退款后可主动回看售后详情
                      MenuItem(
                        icon: Icons.assignment_return_outlined,
                        text: appLocalizations.profile_refund,
                        onTap: () {
                          context.push('/afterSales');
                        },
                      ),
                    ],
                  ),

                  // 我的钱包
                  ProfileMenuSection(
                    title: appLocalizations.profile_my_wallet,
                    menuItems: [
                      MenuItem(
                        icon: Icons.account_balance_wallet,
                        text: appLocalizations.profile_wallet,
                        onTap: () {
                          // 使用go_router导航到钱包页面
                          context.push(ProfileRoutes.walletPath);
                        },
                      ),
                    ],
                  ),

                  // Agent 与 CLI 是账号级能力：用户需要能从 App 内发现
                  // Device Flow 授权、已连接会话和待审核需求，而不是依赖深链。
                  ProfileMenuSection(
                    title: appLocalizations.agentAndCliTitle,
                    menuItems: [
                      MenuItem(
                        icon: Icons.add_link,
                        text: appLocalizations.agentConnectTitle,
                        onTap: () {
                          context.push('/agent/connect');
                        },
                      ),
                      MenuItem(
                        icon: Icons.devices_outlined,
                        text: appLocalizations.agentConnectedAgents,
                        onTap: () {
                          context.push(ProfileRoutes.connectedAgentsPath);
                        },
                      ),
                      MenuItem(
                        icon: Icons.verified_user_outlined,
                        text: appLocalizations.agentMandates,
                        onTap: () {
                          context.push('/agent/mandates');
                        },
                      ),
                      MenuItem(
                        icon: Icons.assignment_outlined,
                        text: appLocalizations.agentRequestDrafts,
                        onTap: () {
                          context.push(ProfileRoutes.agentRequestsPath);
                        },
                      ),
                    ],
                  ),

                  // 设置
                  ProfileMenuSection(
                    title: appLocalizations.profile_settings,
                    menuItems: [
                      MenuItem(
                        icon: Icons.security,
                        text: appLocalizations.profile_account_security,
                        onTap: () {
                          // 使用go_router导航到账号安全页面
                          context.push(ProfileRoutes.accountSecurityPath);
                        },
                      ),
                      MenuItem(
                        icon: Icons.notifications_none,
                        text: appLocalizations.profile_message_notifications,
                        onTap: () {
                          context.push('/notifications');
                        },
                      ),
                      // 添加语言设置选项
                      MenuItem(
                        icon: Icons.language,
                        text: appLocalizations.language_settings,
                        onTap: () {
                          context.push(ProfileRoutes.languageSettingsPath);
                        },
                      ),
                    ],
                  ),

                  // 关于我们
                  ProfileMenuSection(
                    title: appLocalizations.profile_about_us,
                    bottomPadding:
                        GlassNavigationMetrics.contentBottomInset(context) +
                            AppDimensions.spacingXl,
                    menuItems: [
                      MenuItem(
                        icon: Icons.smart_toy_outlined,
                        text: appLocalizations.profile_assistant_mission,
                        onTap: () {
                          // 导航到小帮手的使命页面
                          context.push(ProfileRoutes.assistantMissionPath);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
