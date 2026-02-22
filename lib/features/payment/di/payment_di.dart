import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../presentation/bloc/payment_bloc.dart';
import '../../../core/payment/services/i_payment_service.dart';
import '../../../core/payment/services/alipay_payment_service.dart';
// import '../../../core/payment/services/wechat_payment_service.dart'; // 暂时禁用
import '../../../core/payment/services/payment_service_factory.dart';
import '../../../core/api/api_client.dart';
import '../../../features/orders/domain/usecases/create_order_use_case.dart';
import '../../../features/orders/domain/repositories/i_order_repository.dart';
import '../../../core/network/network_info.dart';

/// 支付模块依赖注入
class PaymentDI {
  /// 注册依赖
  static Future<void> init(GetIt sl) async {
    
    // 注册 PaymentServiceFactory（核心）
    if (!sl.isRegistered<PaymentServiceFactory>()) {
      sl.registerLazySingleton<PaymentServiceFactory>(
        () => PaymentServiceFactory(sl<ApiClient>()),
      );
      AppLogger.d('[payment_di] Registered PaymentServiceFactory');
    }
    
    // 注册微信支付服务 - 暂时禁用
    // if (!sl.isRegistered<WechatPaymentService>()) {
    //   sl.registerLazySingleton<WechatPaymentService>(
    //     () => WechatPaymentService(sl<ApiClient>()),
    //   );
    //   AppLogger.d('[payment_di] Registered WechatPaymentService');
    // }
    
    // 注册 PaymentBloc - 使用PaymentServiceFactory
    if (!sl.isRegistered<PaymentBloc>()) {
      sl.registerFactory<PaymentBloc>(() => PaymentBloc(
        createOrderUseCase: sl<CreateOrderUseCase>(),
        paymentServiceFactory: sl<PaymentServiceFactory>(),
      ));
      AppLogger.d('[payment_di] Registered PaymentBloc');
    }
    
    // 注册 ApiClient（如果尚未注册）
    if (!sl.isRegistered<ApiClient>()) {
      final baseUrl = dotenv.env['BACKEND_BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('BACKEND_BASE_URL environment variable is not set');
      }
      sl.registerLazySingleton<ApiClient>(
        () => ApiClient.getInstance(
          baseUrl: baseUrl,
          token: null,
        ),
      );
      AppLogger.d('[payment_di] Registered ApiClient with URL: $baseUrl');
    }

    // 注册默认的支付服务（支付宝作为默认）
    if (!sl.isRegistered<IPaymentService>()) {
      sl.registerLazySingleton<IPaymentService>(
        () => AlipayPaymentService(sl<ApiClient>()),
      );
      AppLogger.d('[payment_di] Registered AlipayPaymentService as default IPaymentService');
    }
    
    // 确保 CreateOrderUseCase 已注册
    if (!sl.isRegistered<CreateOrderUseCase>()) {
      sl.registerLazySingleton<CreateOrderUseCase>(
        () => CreateOrderUseCase(sl<IOrderRepository>()),
      );
      AppLogger.d('[payment_di] Registered CreateOrderUseCase');
    }
  }
} 