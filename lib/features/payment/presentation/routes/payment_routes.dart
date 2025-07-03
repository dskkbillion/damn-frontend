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
    // 订单确认页面路由已移至主路由系统，避免路径冲突
    
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