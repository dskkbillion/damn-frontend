import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_bottom_navigation_bar.dart';

/// 卖家模式的主框架页面，包含底部导航栏
class SellerShellPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const SellerShellPage({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell, // GoRouter 管理的主体内容
      bottomNavigationBar: SellerBottomNavigationBar( // 使用卖家导航栏
        navigationShell: navigationShell,
      ),
    );
  }
} 