import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // 根据配置构建导航栏项目
    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.auto_awesome_outlined),
        activeIcon: const Icon(Icons.auto_awesome),
        label: l10n.nav_ai_assistant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: l10n.nav_home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.chat_bubble_outline),
        activeIcon: const Icon(Icons.chat_bubble),
        label: l10n.nav_messages,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: l10n.nav_profile,
      ),
    ];

    // 仅在配置为显示开发tab时添加
    if (showDevTab) {
      items.add(BottomNavigationBarItem(
        icon: const Icon(Icons.developer_mode_outlined),
        activeIcon: const Icon(Icons.developer_mode),
        label: l10n.nav_dev,
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