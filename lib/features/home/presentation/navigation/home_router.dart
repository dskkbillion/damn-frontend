import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/seller_public_profile_page.dart';

/// Home模块的路由配置
class HomeRouter {
  // 私有构造函数，防止实例化
  HomeRouter._();
  
  /// 导航器键，用于访问导航上下文
  static final navigatorKey = GlobalKey<NavigatorState>();
  
  /// 路由配置
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // 添加卖家主页路由
      GoRoute(
        path: '/seller/:id/profile',
        name: 'seller_profile',
        builder: (context, state) => SellerPublicProfilePage(
          sellerId: int.parse(state.pathParameters['id'] ?? '0'),
        ),
      ),
    ],
    debugLogDiagnostics: true,
    // 错误处理
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: ${state.error}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}