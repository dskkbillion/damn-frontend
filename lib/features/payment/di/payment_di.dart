import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../presentation/bloc/payment_bloc.dart';
import '../../../core/payment/services/i_payment_service.dart';
import '../../../core/payment/services/alipay_payment_service.dart';
import '../../../core/api/api_client.dart';
import '../../../features/orders/domain/usecases/create_order_use_case.dart';
import '../../../features/orders/domain/repositories/i_order_repository.dart';
import '../../../core/network/network_info.dart';

/// 支付模块依赖注入
class PaymentDI {
  /// 注册依赖
  static Future<void> init(GetIt sl) async {
    // 注册 PaymentBloc
    if (!sl.isRegistered<PaymentBloc>()) {
      sl.registerFactory<PaymentBloc>(() => PaymentBloc(
        createOrderUseCase: sl<CreateOrderUseCase>(),
        paymentService: sl<IPaymentService>(),
      ));
      print('[payment_di] Registered PaymentBloc');
    }
    
    // 注册 ApiClient（如果尚未注册）
    if (!sl.isRegistered<ApiClient>()) {
      sl.registerLazySingleton<ApiClient>(
        () => ApiClient.getInstance(
          baseUrl: 'https://api.duoshaokk.com',
          token: null,
        ),
      );
      print('[payment_di] Registered ApiClient');
    }

    // 注册 IPaymentService 的实现（如果尚未注册）
    if (!sl.isRegistered<IPaymentService>()) {
      sl.registerLazySingleton<IPaymentService>(
        () => AlipayPaymentService(sl<ApiClient>()),
      );
      print('[payment_di] Registered AlipayPaymentService as IPaymentService');
    }
    
    // 确保 CreateOrderUseCase 已注册
    if (!sl.isRegistered<CreateOrderUseCase>()) {
      sl.registerLazySingleton<CreateOrderUseCase>(
        () => CreateOrderUseCase(sl<IOrderRepository>()),
      );
      print('[payment_di] Registered CreateOrderUseCase');
    }
  }
} 