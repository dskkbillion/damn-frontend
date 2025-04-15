import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import '../pages/product_detail_page.dart';

/// Home模块的路由定义
/// 
/// 定义Home模块的所有路由路径、名称和对应的页面构建器
/// 这些路由将来会注册到主应用的中央路由系统中
class HomeRoutes {
  // 私有构造函数，防止实例化
  HomeRoutes._();

  // 路由路径常量
  /// 主页路径
  static const String homePath = '/home';
  
  /// 产品详情路径（子路由，完整路径为 /home/product/:productId）
  static const String productDetailPath = 'product/:productId';
  
  /// 搜索路径（子路由，完整路径为 /home/search）
  static const String searchPath = 'search';
  
  /// 分类详情路径（子路由，完整路径为 /home/category/:categoryId）
  static const String categoryDetailPath = 'category/:categoryId';
  
  // 路由名称常量
  /// 主页名称
  static const String homeName = 'home';
  
  /// 产品详情名称
  static const String productDetailName = 'productDetail';
  
  /// 搜索名称
  static const String searchName = 'search';
  
  /// 分类详情名称
  static const String categoryDetailName = 'categoryDetail';

  // 通过静态getter暴露路由列表
  /// 获取Home模块的所有路由
  static List<RouteBase> get routes => _routes;

  // 模块内部路由定义
  static final List<RouteBase> _routes = [
    GoRoute(
      path: homePath,
      name: homeName,
      builder: (context, state) => const HomePage(),
      routes: [
        // 产品详情路由
        GoRoute(
          path: productDetailPath,
          name: productDetailName,
          builder: (context, state) {
            final productId = state.pathParameters['productId'] ?? '';
            return ProductDetailPage(productId: productId);
          },
        ),
        
        // 搜索路由（占位，将来实现）
        GoRoute(
          path: searchPath,
          name: searchName,
          builder: (context, state) {
            final query = state.uri.queryParameters['q'];
            // 占位实现，将来替换为实际的搜索页面
            return Scaffold(
              appBar: AppBar(title: const Text('搜索')),
              body: Center(child: Text('搜索: ${query ?? "全部"}')),
            );
          },
        ),
        
        // 分类详情路由（占位，将来实现）
        GoRoute(
          path: categoryDetailPath,
          name: categoryDetailName,
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            // 占位实现，将来替换为实际的分类详情页面
            return Scaffold(
              appBar: AppBar(title: const Text('分类详情')),
              body: Center(child: Text('分类ID: $categoryId')),
            );
          },
        ),
      ],
    ),
  ];
}