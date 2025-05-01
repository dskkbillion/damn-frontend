import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 引入 Riverpod
// TODO: 引入卖家导航栏 Widget (创建后)
// import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_bottom_navigation_bar.dart';

// This widget now receives the StatefulNavigationShell from GoRouter
// and uses it to manage the scaffold body and bottom navigation state.
class MainShellPage extends ConsumerWidget { // Changed to ConsumerWidget
  final StatefulNavigationShell navigationShell;

  const MainShellPage({required this.navigationShell, super.key});

  // We no longer need StatefulWidget or local state management for index
  // as GoRouter's StatefulNavigationShell handles it.

  // We also don't need the _widgetOptions list here,
  // as the navigationShell widget itself displays the correct page.

  void _onTap(BuildContext context, int index) {
    // Use the navigationShell's goBranch method to navigate
    // Tapping the current tab again might reset the inner stack (optional)
    navigationShell.goBranch(
      index,
      // `initialLocation` true = reset the branch to its initial location
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 不再需要监听 AppMode
    // final currentMode = ref.watch(appModeProvider);

    return Scaffold(
      // The body is now simply the navigationShell widget.
      // It handles displaying the correct page based on the active branch.
      body: navigationShell,
      // 直接构建买家导航栏
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0903D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI助手',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_mode_outlined),
            activeIcon: Icon(Icons.developer_mode),
            label: '开发',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index), // 传递 context
      ),
    );
  }

  // 移除 _buildBuyerNavigationBar 和 _buildSellerNavigationBar 方法
} 