import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/home_routes.dart';

/// Home模块预览环境的路由配置
/// 
/// 为预览环境提供路由配置，使用Home模块的路由定义
/// 这样，Home模块可以独立运行和测试
class HomePreviewRouter {
  // 私有构造函数，防止实例化
  HomePreviewRouter._();
  
  /// 导航器键，用于访问导航上下文
  static final navigatorKey = GlobalKey<NavigatorState>();
  
  /// 路由配置
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: HomeRoutes.homePath,
    routes: HomeRoutes.routes,
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
              onPressed: () => context.go(HomeRoutes.homePath),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
    // 重定向处理
    redirect: (context, state) {
      // 在预览环境中，我们不需要复杂的重定向逻辑
      // 如果路径为根路径，重定向到首页
      if (state.uri.path == '/') {
        return HomeRoutes.homePath;
      }
      return null; // 返回null表示不重定向
    },
  );
}