import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
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
              return Center(child: Text('加载失败: ${state.message}'));
            }
            
            return _buildMainContent(context, state); 
          },
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '请登录以查看您的个人资料',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 导航到登录页面
                // TODO: 使用导航服务
                // navigationService.navigateToLogin();
              },
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProfileState state) {
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
                ProfileHeader(state: state),

                // 我的订单
                const OrderStatusSection(),

                // 我的多看
                ProfileMenuSection(
                  title: '我的多看',
                  menuItems: [
                    MenuItem(
                      icon: Icons.star_border,
                      text: '收藏',
                      onTap: () {
                        // 导航到收藏列表
                        context.go('/favorites');
                      },
                    ),
                  ],
                ),

                // 我的钱包
                ProfileMenuSection(
                  title: '我的钱包',
                  menuItems: [
                    MenuItem(
                      icon: Icons.account_balance_wallet,
                      text: '钱包',
                      onTap: () {
                        // 使用go_router导航到钱包页面
                        context.go(ProfileRoutes.walletPath);
                      },
                    ),
                  ],
                ),

                // 设置
                ProfileMenuSection(
                  title: '设置',
                  menuItems: [
                    MenuItem(
                      icon: Icons.security,
                      text: '账号与安全',
                      onTap: () {
                        // 使用go_router导航到账号安全页面
                        context.go(ProfileRoutes.accountSecurityPath);
                      },
                    ),
                    MenuItem(
                      icon: Icons.notifications_none,
                      text: '消息通知',
                      onTap: () {
                        // TODO: 导航到消息通知页面
                        // navigationService.navigateToNotifications();
                      },
                    ),
                  ],
                ),

                // 关于我们
                ProfileMenuSection(
                  title: '关于我们',
                  menuItems: [
                    MenuItem(
                      icon: Icons.smart_toy_outlined,
                      text: '小帮手的使命',
                      onTap: () {
                        // TODO: 导航到关于我们页面
                        // navigationService.navigateToAboutUs();
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
