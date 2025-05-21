import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 导入SVG插件
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/generated/l10n.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/haptic_utils.dart'; // 导入震动工具类

/// 主壳页面，支持可配置的开发tab
class MainShellPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  
  const MainShellPage({required this.navigationShell, super.key});
  
  void _onTap(BuildContext context, int index) {
    // 添加轻微震动反馈
    HapticUtils.lightTabFeedback();
    
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 读取是否显示开发tab的配置
    final showDevTab = ref.watch(showDevTabProvider);
    // 获取国际化资源
    final s = S.of(context);
    
    // 根据配置构建导航栏项目
    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
        activeIcon: SvgPicture.asset(
          'assets/icons/nav/dskk_logo.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(const Color(0xFFD0903D), BlendMode.srcIn),
        ),
        label: s.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: s.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: s.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: s.nav_profile,
      ),
    ];
    
    // 仅在配置为显示开发tab时添加
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: s.nav_dev,
      ));
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0903D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
} 