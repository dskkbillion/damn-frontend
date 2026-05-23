import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

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
      pageBuilder: (context, state) {
        final raw = state.uri.queryParameters['success'];
        final initialStatus = raw == 'true'
            ? PaymentResultStatus.success
            : raw == 'pending'
                ? PaymentResultStatus.pending
                : PaymentResultStatus.failure;
        final orderId = state.uri.queryParameters['orderId'];
        final errorMessage = state.uri.queryParameters['errorMessage'];

        return state.buildSmartPage(
          PaymentResultPage(
            initialStatus: initialStatus,
            orderId: orderId,
            errorMessage: errorMessage,
          ),
          name: 'paymentResult',
        );
      },
    ),
  ];
}