import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart'; // 导入国际化资源
import 'package:dskk_flutter_refactor/core/utils/haptic_utils.dart'; // 导入震动工具类
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
// import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 不再需要 AppMode

class SellerBottomNavigationBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell; // <--- 接收 navigationShell

  const SellerBottomNavigationBar({super.key, required this.navigationShell});

  // 移除 _calculateSelectedIndex 方法

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取国际化资源
    final appLocalizations = AppLocalizations.of(context);
    
    return GlassNavigationSurface(
      child: BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconSize: 24,
      type: BottomNavigationBarType.fixed, 
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics_outlined), 
          activeIcon: const Icon(Icons.analytics), 
          label: appLocalizations.nav_seller_analytics
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2_outlined), 
          activeIcon: const Icon(Icons.inventory_2), 
          label: appLocalizations.nav_seller_products
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline), 
          activeIcon: const Icon(Icons.chat_bubble), 
          label: appLocalizations.nav_seller_messages
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle_outlined), 
          activeIcon: const Icon(Icons.account_circle), 
          label: appLocalizations.nav_seller_profile
        ),
      ],
      currentIndex: navigationShell.currentIndex, // <--- 直接使用 shell 的 index
      onTap: (index) {
        // 添加轻微震动反馈
        HapticUtils.lightTabFeedback();
        
        // 使用 navigationShell.goBranch 进行导航
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      ),
    );
  }
}
