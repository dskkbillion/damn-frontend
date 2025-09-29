import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_mode.dart';
import '../../generated/l10n.dart';
import '../../core/utils/haptic_utils.dart';
import '../navigation/app_router_config.dart';

/// 自适应底部导航栏 Shell，根据当前模式显示不同的导航项
/// 但保持同一个 navigationShell，避免页面重载
class AdaptiveBottomNavShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  
  const AdaptiveBottomNavShell({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);
  
  void _onTap(BuildContext context, int index) {
    HapticUtils.lightTabFeedback();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(appModeProvider);
    final showDevTab = ref.watch(showDevTabProvider);
    final S s = S.of(context);
    
    // 根据模式构建不同的底部导航项
    final List<BottomNavigationBarItem> items = currentMode == AppMode.buyer
        ? _buildBuyerNavItems(s, showDevTab)
        : _buildSellerNavItems(s);
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0903D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: items,
        currentIndex: _getCurrentIndex(currentMode, navigationShell.currentIndex),
        onTap: (index) => _handleTap(context, ref, currentMode, index),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildBuyerNavItems(S s, bool showDevTab) {
    final items = [
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
    
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: s.nav_dev,
      ));
    }
    
    return items;
  }
  
  List<BottomNavigationBarItem> _buildSellerNavItems(S s) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.analytics_outlined),
        activeIcon: const Icon(Icons.analytics),
        label: s.seller_nav_stats,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.inventory_2_outlined),
        activeIcon: const Icon(Icons.inventory_2),
        label: s.seller_nav_products,
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
  }
  
  // 根据模式映射正确的索引
  int _getCurrentIndex(AppMode mode, int shellIndex) {
    if (mode == AppMode.buyer) {
      // 买家模式：0-4 对应 AI助手、首页、消息、我的、开发
      return shellIndex <= 4 ? shellIndex : 0;
    } else {
      // 卖家模式需要映射：
      // Shell 5 (卖家数据) -> Nav 0
      // Shell 6 (商品管理) -> Nav 1  
      // Shell 7 (卖家消息) -> Nav 2
      // Shell 8 (卖家我的) -> Nav 3
      if (shellIndex >= 5 && shellIndex <= 8) {
        return shellIndex - 5;
      }
      return 0;
    }
  }
  
  // 处理点击，根据模式映射到正确的分支
  void _handleTap(BuildContext context, WidgetRef ref, AppMode mode, int navIndex) {
    int targetBranch;
    
    if (mode == AppMode.buyer) {
      // 买家模式直接映射
      targetBranch = navIndex;
    } else {
      // 卖家模式需要映射到正确的分支索引
      targetBranch = navIndex + 5; // 5-8 是卖家分支
    }
    
    _onTap(context, targetBranch);
  }
}