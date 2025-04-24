import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_section.dart';
import '../widgets/profile_menu_section.dart';

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
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthStatusLoaded) {
            if (state.isAuthenticated) {
              // 如果已登录，获取用户资料和钱包摘要
              context.read<ProfileBloc>().add(GetUserProfileEvent());
              context.read<ProfileBloc>().add(GetWalletSummaryEvent());
            } else {
              // 如果未登录，显示登录页面
              return _buildLoginPrompt(context);
            }
          }

          // 构建主页面
          return _buildMainContent(context, state);
        },
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
            context.read<ProfileBloc>().add(GetWalletSummaryEvent());
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

                // 我的关看
                ProfileMenuSection(
                  title: '我的关看',
                  menuItems: [
                    MenuItem(
                      icon: Icons.star_border,
                      text: '收藏',
                      onTap: () {
                        // 导航到收藏列表
                        context.go('/favorites');
                      },
                    ),
                    MenuItem(
                      icon: Icons.favorite_border,
                      text: '点赞的故事',
                      onTap: () {
                        // TODO: 导航到点赞故事列表
                        // navigationService.navigateToLikedStories();
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
                        // TODO: 导航到钱包页面
                        // navigationService.navigateToWallet();
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
                        // TODO: 导航到账号安全页面
                        // navigationService.navigateToAccountSafety();
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

                // 登出按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 弹出确认对话框
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('确认登出'),
                            content: const Text('您确定要退出登录吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.read<ProfileBloc>().add(LogoutEvent());
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('退出登录'),
                    ),
                  ),
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
