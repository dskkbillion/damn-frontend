import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/app_mode.dart';
import '../../generated/app_localizations.dart';
import '../../core/utils/haptic_utils.dart';
import '../navigation/app_router_config.dart';
import '../../core/config/theme/app_colors.dart';

/// 自适应底部导航栏 Shell，根据当前模式显示不同的导航项
/// 但保持同一个 navigationShell，避免页面重载
class AdaptiveBottomNavShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  
  const AdaptiveBottomNavShell({
    super.key,
    required this.navigationShell,
  });
  
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
    final appLocalizations = AppLocalizations.of(context);
    
    // 根据模式构建不同的底部导航项
    final List<BottomNavigationBarItem> items = currentMode == AppMode.buyer
        ? _buildBuyerNavItems(appLocalizations, showDevTab)
        : _buildSellerNavItems(appLocalizations);
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        showUnselectedLabels: true,
        items: items,
        currentIndex: _getCurrentIndex(currentMode, navigationShell.currentIndex),
        onTap: (index) => _handleTap(context, ref, currentMode, index),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildBuyerNavItems(AppLocalizations appLocalizations, bool showDevTab) {
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
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        label: appLocalizations.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: appLocalizations.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: appLocalizations.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: appLocalizations.nav_profile,
      ),
    ];
    
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: appLocalizations.nav_dev,
      ));
    }
    
    return items;
  }
  
  List<BottomNavigationBarItem> _buildSellerNavItems(AppLocalizations appLocalizations) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.analytics_outlined),
        activeIcon: const Icon(Icons.analytics),
        label: appLocalizations.nav_seller_analytics,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.inventory_2_outlined),
        activeIcon: const Icon(Icons.inventory_2),
        label: appLocalizations.nav_seller_products,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: appLocalizations.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: appLocalizations.nav_profile,
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