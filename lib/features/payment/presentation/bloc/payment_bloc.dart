import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/payment/services/payment_service_factory.dart';
import '../../../../core/config/payment_config.dart';
import '../../../orders/domain/usecases/create_order_use_case.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// 支付Bloc
@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;

  PaymentBloc({
    required this.createOrderUseCase,
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
      // 打印支付配置信息（仅在调试模式下）
      PaymentConfig.printConfig();
      
      // 验证支付方式
      final isAvailable = await PaymentServiceFactory.isPaymentMethodAvailable(event.paymentMethod);
      if (!isAvailable) {
        emit(PaymentFailedState(
          errorMessage: '不支持的支付方式: ${event.paymentMethod}',
        ));
        return;
      }
      
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
          final errorMessage = failure.message;
          Fluttertoast.showToast(msg: errorMessage);
          emit(PaymentFailedState(errorMessage: errorMessage));
        },
        (creationResult) async {
          // 创建订单成功
          // 显示支付中状态
          emit(PayingState(
            orderId: creationResult.orderId,
            paymentMethod: event.paymentMethod,
          ));

          // 根据选择的支付方式创建对应的支付服务
          try {
            final paymentService = PaymentServiceFactory.create(event.paymentMethod);
            
            // 调用支付
            final payResult = await paymentService.initiatePayment(
              creationResult.orderId,
              paymentMethodId: event.paymentMethod,
            );

            // 处理支付结果
            payResult.fold(
              (failure) {
                // 支付失败
                final errorMessage = failure.message;
                Fluttertoast.showToast(msg: errorMessage);
                emit(PaymentFailedState(
                  errorMessage: errorMessage,
                  orderId: creationResult.orderId,
                  paymentMethod: event.paymentMethod,
                ));
              },
              (_) {
                // 支付成功
                Fluttertoast.showToast(msg: '支付成功');
                emit(PaymentCompletedState(
                  orderId: creationResult.orderId,
                  paymentMethod: event.paymentMethod,
                ));
              },
            );
          } catch (e) {
            // 支付服务创建失败或其他异常
            final errorMessage = '支付服务异常: $e';
            Fluttertoast.showToast(msg: errorMessage);
            emit(PaymentFailedState(
              errorMessage: errorMessage,
              orderId: creationResult.orderId,
              paymentMethod: event.paymentMethod,
            ));
          }
        },
      );
    } catch (e) {
      // 捕获未处理异常
      final errorMessage = '支付过程中发生异常: $e';
      Fluttertoast.showToast(msg: errorMessage);
      emit(PaymentFailedState(errorMessage: errorMessage));
    }
  }

  /// 处理直接支付事件
  Future<void> _onDirectPay(
    DirectPayEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      // 验证支付方式
      final isAvailable = await PaymentServiceFactory.isPaymentMethodAvailable(event.paymentMethod);
      if (!isAvailable) {
        emit(PaymentFailedState(
          errorMessage: '不支持的支付方式: ${event.paymentMethod}',
          orderId: event.orderId,
        ));
        return;
      }
      
      // 显示支付中状态
      emit(PayingState(
        orderId: event.orderId,
        paymentMethod: event.paymentMethod,
      ));

      // 根据选择的支付方式创建对应的支付服务
      try {
        final paymentService = PaymentServiceFactory.create(event.paymentMethod);
        
        // 调用支付
        final payResult = await paymentService.initiatePayment(
          event.orderId,
          paymentMethodId: event.paymentMethod,
        );

        // 处理支付结果
        payResult.fold(
          (failure) {
            // 支付失败
            final errorMessage = failure.message;
            Fluttertoast.showToast(msg: errorMessage);
            emit(PaymentFailedState(
              errorMessage: errorMessage,
              orderId: event.orderId,
              paymentMethod: event.paymentMethod,
            ));
          },
          (_) {
            // 支付成功
            Fluttertoast.showToast(msg: '支付成功');
            emit(PaymentCompletedState(
              orderId: event.orderId,
              paymentMethod: event.paymentMethod,
            ));
          },
        );
      } catch (e) {
        // 支付服务创建失败或其他异常
        final errorMessage = '支付服务异常: $e';
        Fluttertoast.showToast(msg: errorMessage);
        emit(PaymentFailedState(
          errorMessage: errorMessage,
          orderId: event.orderId,
          paymentMethod: event.paymentMethod,
        ));
      }
    } catch (e) {
      // 捕获未处理异常
      final errorMessage = '支付过程中发生异常: $e';
      Fluttertoast.showToast(msg: errorMessage);
      emit(PaymentFailedState(
        errorMessage: errorMessage,
        orderId: event.orderId,
      ));
    }
  }
} 