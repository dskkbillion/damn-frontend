import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_mode.dart';
import '../navigation/app_router_config.dart';
import '../../generated/l10n.dart';
import '../../core/utils/haptic_utils.dart';

/// 统一Shell页面 - 根据AppMode动态显示不同的底部导航
class UnifiedShellPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  
  const UnifiedShellPage({required this.navigationShell, super.key});
  
  void _onTap(BuildContext context, int index) {
    final appMode = ref.read(appModeProvider);
    
    // 添加分析日志
    print('[UnifiedShell] Tab switched: mode=$appMode, index=$index');
    
    // 添加性能监控
    final stopwatch = Stopwatch()..start();
    
    HapticUtils.lightTabFeedback();
    
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    
    stopwatch.stop();
    print('[UnifiedShell] Tab switch took: ${stopwatch.elapsedMilliseconds}ms');
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appMode = ref.watch(appModeProvider);
    final showDevTab = ref.watch(showDevTabProvider);
    final s = S.of(context);
    
    print('[UnifiedShell] Building with mode: $appMode, currentIndex: ${navigationShell.currentIndex}');
    
    // 根据模式动态构建导航项
    final List<BottomNavigationBarItem> items = _buildNavigationItems(appMode, s);
    
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
        selectedItemColor: _getThemeColor(appMode),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildNavigationItems(AppMode mode, S s) {
    switch (mode) {
      case AppMode.buyer:
        return [
          BottomNavigationBarItem(
            icon: _buildIcon('assets/icons/nav/dskk_logo.svg', false),
            activeIcon: _buildIcon('assets/icons/nav/dskk_logo.svg', true),
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
      case AppMode.seller:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics_outlined),
            activeIcon: const Icon(Icons.analytics),
            label: '数据',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_outlined),
            activeIcon: const Icon(Icons.inventory),
            label: '商品',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: '我的',
          ),
        ];
    }
  }
  
  Widget _buildIcon(String assetPath, bool isActive) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive ? const Color(0xFFD0903D) : Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }
  
  Color _getThemeColor(AppMode mode) {
    switch (mode) {
      case AppMode.buyer:
        return const Color(0xFFD0903D); // 买家主题色
      case AppMode.seller:
        return const Color(0xFF1976D2); // 卖家主题色
    }
  }
}