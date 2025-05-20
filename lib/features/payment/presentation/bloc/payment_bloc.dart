import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/payment/services/i_payment_service.dart';
import '../../../orders/domain/usecases/create_order_use_case.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// 支付Bloc
@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;
  final IPaymentService paymentService;

  PaymentBloc({
    required this.createOrderUseCase,
    required this.paymentService,
  }) : super(PaymentInitial()) {
    on<CreateOrderAndPayEvent>(_onCreateOrderAndPay);
    on<DirectPayEvent>(_onDirectPay);
    on<ResetPaymentEvent>((event, emit) => emit(PaymentInitial()));
  }

  /// 处理创建订单并支付事件
  Future<void> _onCreateOrderAndPay(
    CreateOrderAndPayEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // 显示创建订单中状态
      emit(CreatingOrderState());

      // 创建订单
      final orderResult = await createOrderUseCase.execute(
        productId: event.productId,
        variantId: event.variantId,
        quantity: event.quantity,
        sellerId: event.sellerId,
        price: event.price,
      );

      // 处理结果
      await orderResult.fold(
        (failure) {
          // 创建订单失败
          Fluttertoast.showToast(msg: failure.message);
          emit(PaymentFailedState(errorMessage: failure.message));
        },
        (creationResult) async {
          // 创建订单成功
          // 显示支付中状态
          emit(PayingState(orderId: creationResult.orderId));

          // 调用支付
          final payResult = await paymentService.initiatePayment(
            creationResult.orderId,
            paymentMethodId: 'alipay',
          );

          // 处理支付结果
          payResult.fold(
            (failure) {
              // 支付失败
              emit(PaymentFailedState(
                errorMessage: failure.message,
                orderId: creationResult.orderId,
              ));
            },
            (_) {
              // 支付成功
              emit(PaymentCompletedState(orderId: creationResult.orderId));
            },
          );
        },
      );
    } catch (e) {
      // 捕获未处理异常
      emit(PaymentFailedState(errorMessage: '支付过程中发生异常: $e'));
    }
  }

  /// 处理直接支付事件
  Future<void> _onDirectPay(
    DirectPayEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // 显示支付中状态
      emit(PayingState(orderId: event.orderId));

      // 调用支付
      final payResult = await paymentService.initiatePayment(
        event.orderId,
        paymentMethodId: event.paymentMethod,
      );

      // 处理支付结果
      payResult.fold(
        (failure) {
          // 支付失败
          emit(PaymentFailedState(
            errorMessage: failure.message,
            orderId: event.orderId,
          ));
        },
        (_) {
          // 支付成功
          emit(PaymentCompletedState(orderId: event.orderId));
        },
      );
    } catch (e) {
      // 捕获未处理异常
      emit(PaymentFailedState(errorMessage: '支付过程中发生异常: $e'));
    }
  }
} 