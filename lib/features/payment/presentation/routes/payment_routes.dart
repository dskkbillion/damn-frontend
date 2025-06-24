import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../bloc/payment_bloc.dart';
import '../pages/order_confirm_page.dart';
import '../pages/payment_result_page.dart';

/// 定义支付模块的路由
class PaymentRoutes {
  PaymentRoutes._(); // 私有构造函数
  
  /// 获取支付模块的路由列表
  static List<RouteBase> get routes => _routes;
  
  // 定义路由
  static final List<RouteBase> _routes = [
    // 订单确认页面
    GoRoute(
      path: '/products/:productId/confirm',
      name: 'orderConfirm',
      builder: (context, state) {
        final productId = int.parse(state.pathParameters['productId'] ?? '0');
        // 获取路由传递的额外数据
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
        
        return BlocProvider(
          create: (_) => getIt<PaymentBloc>(),
          child: OrderConfirmPage(
            productId: productId,
            variantId: extra['variantId'] ?? 0,
            quantity: extra['quantity'] ?? 1,
            sellerId: extra['sellerId'] ?? 0,
            price: extra['price'] ?? 0.0,
            productName: extra['productName'] ?? '',
            imageUrl: extra['imageUrl'],
          ),
        );
      },
    ),
    // 支付结果页面
    GoRoute(
      path: '/payment/result',
      name: 'paymentResult',
      builder: (context, state) {
        final success = state.uri.queryParameters['success'] == 'true';
        final orderId = state.uri.queryParameters['orderId'];
        final errorMessage = state.uri.queryParameters['errorMessage'];
        
        return PaymentResultPage(
          success: success,
          orderId: orderId,
          errorMessage: errorMessage,
        );
      },
    ),
  ];
} 