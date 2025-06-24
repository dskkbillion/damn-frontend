import 'package:injectable/injectable.dart';

import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/orders/domain/usecases/create_order_use_case.dart';
import '../payment/services/i_payment_service.dart';

/// 支付模块依赖注入
@module
abstract class PaymentModule {
  /// 提供PaymentBloc
  @injectable
  PaymentBloc providePaymentBloc(
    CreateOrderUseCase createOrderUseCase,
    IPaymentService paymentService,
  ) => 
    PaymentBloc(
      createOrderUseCase: createOrderUseCase,
      paymentService: paymentService,
    );
} 