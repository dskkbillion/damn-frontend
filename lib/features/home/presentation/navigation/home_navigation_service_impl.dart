import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/home_routes.dart';
import 'home_navigation_service.dart';

/// Home模块导航服务的预览实现
/// 
/// 实现导航服务接口，使用GoRouter进行导航
/// 这个实现用于预览环境，将来会替换为使用中央路由系统的实现
class HomeNavigationServiceImpl implements HomeNavigationService {
  /// 导航器键，用于访问导航上下文
  final GlobalKey<NavigatorState> navigatorKey;

  /// 构造函数
  /// 
  /// [navigatorKey] 导航器键，用于访问导航上下文
  HomeNavigationServiceImpl({required this.navigatorKey});

  @override
  void navigateToProductDetail(String productId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).goNamed(
        HomeRoutes.productDetailName,
        pathParameters: {'productId': productId},
      );
    }
  }

  @override
  void navigateToSearch(String? query) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final params = query != null ? {'q': query} : <String, String>{};
      GoRouter.of(context).goNamed(
        HomeRoutes.searchName,
        queryParameters: params,
      );
    }
  }

  @override
  void navigateToCategoryDetail(String categoryId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).goNamed(
        HomeRoutes.categoryDetailName,
        pathParameters: {'categoryId': categoryId},
      );
    }
  }

  @override
  void navigateToUrl(String url) {
    // 在预览环境中，只显示SnackBar
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('外部链接: $url'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: '关闭',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  void showRecommendConfirmation(String productId, String productName) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('推荐确认'),
          content: Text('确定要推荐"$productName"吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 显示推荐成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已推荐: $productName'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }
}