import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

/// 修改后的主壳页面，支持可配置的开发tab
class MainShellPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({required this.navigationShell, super.key});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 读取是否显示开发tab的配置
    final showDevTab = ref.watch(showDevTabProvider);
    
    // 根据配置构建导航栏项目
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.auto_awesome_outlined),
        activeIcon: Icon(Icons.auto_awesome),
        label: 'AI助手',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '主页',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: '消息',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: '我的',
      ),
    ];
    
    // 仅在配置为显示开发tab时添加
    if (showDevTab) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.developer_mode_outlined),
        activeIcon: Icon(Icons.developer_mode),
        label: '开发',
      ));
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        showUnselectedLabels: true,
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
} 