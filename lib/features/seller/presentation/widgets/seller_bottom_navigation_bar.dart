import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 不再需要 AppMode

class SellerBottomNavigationBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell; // <--- 接收 navigationShell

  const SellerBottomNavigationBar({Key? key, required this.navigationShell}) : super(key: key);

  // 移除 _calculateSelectedIndex 方法

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, 
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: '数据'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: '商品'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: '消息'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), activeIcon: Icon(Icons.account_circle), label: '我的'),
      ],
      currentIndex: navigationShell.currentIndex, // <--- 直接使用 shell 的 index
      onTap: (index) {
        // 使用 navigationShell.goBranch 进行导航
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
    );
  }
} 