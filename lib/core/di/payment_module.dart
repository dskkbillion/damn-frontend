import 'package:injectable/injectable.dart';

import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/orders/domain/usecases/create_order_use_case.dart';
import '../payment/services/payment_service_factory.dart';

/// 支付模块依赖注入
@module
abstract class PaymentModule {
  /// 提供PaymentBloc
  @injectable
  PaymentBloc providePaymentBloc(
    CreateOrderUseCase createOrderUseCase,
    PaymentServiceFactory paymentServiceFactory,
  ) => 
    PaymentBloc(
      createOrderUseCase: createOrderUseCase,
      paymentServiceFactory: paymentServiceFactory,
    );
} 