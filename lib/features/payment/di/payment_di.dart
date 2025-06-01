import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../presentation/bloc/payment_bloc.dart';
import '../../../features/orders/domain/usecases/create_order_use_case.dart';
import '../../../features/orders/domain/repositories/i_order_repository.dart';
import '../../../core/network/network_info.dart';
import '../../../core/config/payment_config.dart';

/// 支付模块依赖注入
class PaymentDI {
  /// 注册依赖
  static Future<void> init(GetIt sl) async {
    // 注册 PaymentBloc (移除对IPaymentService的依赖)
    if (!sl.isRegistered<PaymentBloc>()) {
      sl.registerFactory<PaymentBloc>(() => PaymentBloc(
        createOrderUseCase: sl<CreateOrderUseCase>(),
      ));
      print('[payment_di] Registered PaymentBloc');
    }
    
    // 确保 CreateOrderUseCase 已注册
    if (!sl.isRegistered<CreateOrderUseCase>()) {
      sl.registerLazySingleton<CreateOrderUseCase>(
        () => CreateOrderUseCase(sl<IOrderRepository>()),
      );
      print('[payment_di] Registered CreateOrderUseCase');
    }
    
    // 打印支付配置信息
    PaymentConfig.printConfig();
    
    print('[payment_di] Payment dependencies initialization completed');
  }
  
  /// 获取可用的支付方式
  static List<String> getAvailablePaymentMethods() {
    return PaymentConfig.availablePaymentMethods;
  }
  
  /// 检查支付配置
  static void validatePaymentConfig() {
    final availableMethods = PaymentConfig.availablePaymentMethods;
    
    if (availableMethods.isEmpty) {
      print('[payment_di] WARNING: No payment methods available');
    } else {
      print('[payment_di] Available payment methods: $availableMethods');
    }
    
    // 在调试模式下检查配置
    if (PaymentConfig.isDebugMode) {
      print('[payment_di] Alipay configured: ${PaymentConfig.isAlipayConfigured}');
      print('[payment_di] WeChat configured: ${PaymentConfig.isWechatConfigured}');
      print('[payment_di] Mock payment enabled: ${PaymentConfig.useMockPayment}');
    }
  }
} 