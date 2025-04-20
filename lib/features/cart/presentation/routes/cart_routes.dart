import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_bloc.dart';
import '../pages/cart_page.dart';
import '../../domain/repositories/i_cart_repository.dart';

/// 购物车模块路由定义
class CartRoutes {
  /// 购物车路由路径
  static const String cartPath = '/cart';

  /// 购物车路由名称
  static const String cartName = 'cart';

  /// 获取购物车路由
  static List<RouteBase> getRoutes({
    required CartBloc Function() cartBlocProvider,
  }) {
    return [
      GoRoute(
        path: cartPath,
        name: cartName,
        builder: (context, state) {
          return BlocProvider<CartBloc>(
            create: (context) => cartBlocProvider(),
            child: const CartPage(),
          );
        },
      ),
    ];
  }

  /// 导航到购物车
  static void navigateToCart(BuildContext context) {
    GoRouter.of(context).pushNamed(cartName);
  }

  /// 导航到商品详情
  static void navigateToProductDetail(BuildContext context, String productId) {
    GoRouter.of(context).pushNamed('productDetail', params: {'productId': productId});
  }

  /// 导航到结算页面
  static void navigateToCheckout(BuildContext context, CheckoutPreview checkoutPreview) {
    GoRouter.of(context).pushNamed('checkout', extra: checkoutPreview);
  }

  /// 导航到登录页面
  static void navigateToLogin(BuildContext context) {
    GoRouter.of(context).pushNamed('login');
  }

  /// 继续购物（返回上一页或首页）
  static void continueShopping(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      GoRouter.of(context).goNamed('home');
    }
  }
}