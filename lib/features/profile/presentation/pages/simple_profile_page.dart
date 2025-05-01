import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/wallet_bloc.dart';
import 'wallet_page.dart';
import 'account_security_page.dart';

class SimpleProfilePage extends StatefulWidget {
  final VoidCallback? onSwitchMode;

  const SimpleProfilePage({Key? key, this.onSwitchMode}) : super(key: key);

  @override
  State<SimpleProfilePage> createState() => _SimpleProfilePageState();
}

class _SimpleProfilePageState extends State<SimpleProfilePage> {
  // 模拟用户数据
  String userName = '用户名';
  bool isOnline = false;
  String? avatarUrl;
  File? avatarFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar
      // appBar: AppBar(
      //   title: const Text('个人中心'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('设置功能尚未实现')),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildProfileSection(
              context,
              '我的订单',
              _buildOrderStatusList(context)
            ),
            _buildProfileSection(
              context,
              '我的关看',
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.star_border,
                  title: '收藏',
                  onTap: () => context.go('/favorites'),
                ),
                MenuItem(
                  icon: Icons.favorite_border,
                  title: '点赞的故事',
                  onTap: () => _showFeatureNotImplemented('点赞的故事'),
                ),
              ]),
            ),
            _buildProfileSection(
              context,
              '我的钱包',
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.account_balance_wallet,
                  title: '钱包',
                  onTap: () => _navigateToWallet(context),
                ),
              ]),
            ),
            _buildProfileSection(
              context,
              '设置',
              _buildMenuList(context, [
                MenuItem(
                  icon: Icons.security,
                  title: '账号与安全',
                  onTap: () => _navigateToAccountSecurity(context),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _showFeatureNotImplemented('退出登录');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.red[50],
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 用户信息
          Row(
            children: [
              // 头像
              GestureDetector(
                onTap: () => _pickImage(),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  backgroundImage: avatarFile != null ? FileImage(avatarFile!) : null,
                  child: avatarFile == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 16),

              // 用户名称和状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showFeatureNotImplemented('编辑昵称'),
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '在线',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 卖家模式开关
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '买家模式',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Switch(
                  value: false,
                  onChanged: (value) {
                    if (value && widget.onSwitchMode != null) {
                      widget.onSwitchMode!();
                    }
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildOrderStatusList(BuildContext context) {
    final List<OrderStatusItem> items = [
      OrderStatusItem(
        icon: Icons.access_time,
        label: '待付款',
        onTap: () => _showFeatureNotImplemented('待付款订单'),
      ),
      OrderStatusItem(
        icon: Icons.sync,
        label: '进行中',
        onTap: () => _showFeatureNotImplemented('进行中订单'),
      ),
      OrderStatusItem(
        icon: Icons.check_circle,
        label: '已完成',
        onTap: () => _showFeatureNotImplemented('已完成订单'),
      ),
      OrderStatusItem(
        icon: Icons.undo,
        label: '退款/售后',
        onTap: () => _showFeatureNotImplemented('退款/售后'),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((item) => _buildOrderStatusItem(
        context,
        item.icon,
        item.label,
        item.onTap,
      )).toList(),
    );
  }

  Widget _buildOrderStatusItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, List<MenuItem> items) {
    return Column(
      children: items.map((item) => _buildMenuItem(
        context,
        item.icon,
        item.title,
        item.onTap,
      )).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          avatarFile = File(pickedFile.path);
        });
        // 显示提示
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像已更新，但尚未保存到服务器')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片时出错: $e')),
      );
    }
  }

  void _showFeatureNotImplemented(String featureName) {
    if (featureName == '我的钱包') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => GetIt.instance<WalletBloc>(),
            child: const WalletPage(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName功能尚未实现')),
    );
  }

  void _navigateToWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GetIt.instance<WalletBloc>(),
          child: const WalletPage(),
        ),
      ),
    );
  }

  void _navigateToAccountSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountSecurityPage(),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class OrderStatusItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  OrderStatusItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
