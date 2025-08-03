import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/payment/services/payment_service_factory.dart';
import '../../../../core/payment/models/payment_models.dart' as payment_models;
import '../../../../core/payment/services/payment_navigation_service.dart';
import '../../../orders/domain/usecases/create_order_use_case.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// 支付Bloc
@injectable
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreateOrderUseCase createOrderUseCase;
  final PaymentServiceFactory paymentServiceFactory;
  
  bool _isProcessing = false; // 防重复处理标志

  PaymentBloc({
    required this.createOrderUseCase,
    required this.paymentServiceFactory,
  }) : super(PaymentInitial()) {
    on<CreateOrderAndPayEvent>(_onCreateOrderAndPay);
    on<DirectPayEvent>(_onDirectPay);
    on<ResetPaymentEvent>((event, emit) {
      _isProcessing = false; // 重置时清除处理标志
      emit(PaymentInitial());
    });
  }

  /// 处理创建订单并支付事件
  Future<void> _onCreateOrderAndPay(
    CreateOrderAndPayEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // 防重复处理检查
    if (_isProcessing) {
      print('[PaymentBloc] 正在处理支付请求，忽略重复事件');
      return;
    }
    
    try {
      _isProcessing = true; // 设置处理标志
      print('[PaymentBloc] 开始处理订单创建和支付 - 商品: ${event.productName}, 支付方式: ${event.paymentMethod}');
      
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
          _isProcessing = false; // 重置处理标志
          
          // 特殊处理重复提交错误
          String errorMessage = failure.message;
          if (errorMessage.contains('不允许重复提交') || errorMessage.contains('重复提交')) {
            errorMessage = '请勿频繁操作，稍等片刻后再试';
            print('[PaymentBloc] 检测到重复提交错误，显示用户友好提示');
          }
          
          Fluttertoast.showToast(msg: errorMessage);
          emit(PaymentFailedState(errorMessage: errorMessage));
        },
        (creationResult) async {
          // 创建订单成功
          // 显示支付中状态
          emit(PayingState(orderId: creationResult.orderId));

          // 获取对应的支付服务
          final paymentService = await paymentServiceFactory.getPaymentService(event.paymentMethod);

          // 创建支付请求
          final paymentRequest = payment_models.PaymentRequest(
            orderId: creationResult.orderId,
            amount: (event.price * event.quantity).toStringAsFixed(2),
            subject: event.productName,
            description: '${event.productName} x ${event.quantity}',
            method: _getPaymentMethod(event.paymentMethod),
            scene: payment_models.PaymentScene.order,
          );

          // 发起支付
          final paymentResult = await paymentService.createPayment(paymentRequest);

          // 处理支付结果
          if (paymentResult.success) {
            // 检查支付结果类型
            if (paymentResult.resultType == payment_models.PaymentResultType.processing) {
              // 支付处理中（如Stripe跳转）
              _isProcessing = false; // 重置处理标志
              // 不emit完成状态，让用户在外部完成支付
              print('[PaymentBloc] 支付链接已打开，等待用户完成支付');
              // 可以emit一个处理中的状态，或者什么都不做
              emit(PaymentInitial()); // 重置状态
            } else {
              // 支付成功
              _isProcessing = false; // 重置处理标志
              emit(PaymentCompletedState(orderId: creationResult.orderId));
            }
          } else {
            // 支付失败
            _isProcessing = false; // 重置处理标志
            emit(PaymentFailedState(
              errorMessage: paymentResult.message ?? '支付失败',
              orderId: creationResult.orderId,
            ));
          }
        },
      );
    } catch (e) {
      // 捕获未处理异常
      _isProcessing = false; // 重置处理标志
      print('[PaymentBloc] 支付过程中发生异常: $e');
      emit(PaymentFailedState(errorMessage: '支付过程中发生异常: $e'));
    }
  }

  /// 处理直接支付事件
  Future<void> _onDirectPay(
    DirectPayEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // 防重复处理检查
    if (_isProcessing) {
      print('[PaymentBloc] 正在处理支付请求，忽略重复直接支付事件');
      return;
    }
    
    try {
      _isProcessing = true; // 设置处理标志
      print('[PaymentBloc] 开始处理直接支付 - 订单: ${event.orderId}, 支付方式: ${event.paymentMethod}');
      
      // 显示支付中状态
      emit(PayingState(orderId: event.orderId));

      // 获取对应的支付服务
      final paymentService = await paymentServiceFactory.getPaymentService(event.paymentMethod);

      // 创建支付请求
      final paymentRequest = payment_models.PaymentRequest(
        orderId: event.orderId,
        amount: '0.01', // 这里需要从订单获取实际金额
        subject: '订单支付',
        description: '订单支付',
        method: _getPaymentMethod(event.paymentMethod),
        scene: payment_models.PaymentScene.order,
      );

      // 发起支付
      final paymentResult = await paymentService.createPayment(paymentRequest);

      // 处理支付结果
      if (paymentResult.success) {
        // 支付成功
        _isProcessing = false; // 重置处理标志
        emit(PaymentCompletedState(orderId: event.orderId));
      } else {
        // 支付失败
        _isProcessing = false; // 重置处理标志
        emit(PaymentFailedState(
          errorMessage: paymentResult.message ?? '支付失败',
          orderId: event.orderId,
        ));
      }
    } catch (e) {
      // 捕获未处理异常
      _isProcessing = false; // 重置处理标志
      print('[PaymentBloc] 直接支付过程中发生异常: $e');
      emit(PaymentFailedState(errorMessage: '支付过程中发生异常: $e'));
    }
  }

  /// 将字符串转换为PaymentMethod枚举
  payment_models.PaymentMethod _getPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'wechat':
        return payment_models.PaymentMethod.wechat;
      case 'wallet':
        return payment_models.PaymentMethod.wallet;
      case 'stripe':
        return payment_models.PaymentMethod.stripe;
      case 'alipay':
      default:
        return payment_models.PaymentMethod.alipay;
    }
  }
} 