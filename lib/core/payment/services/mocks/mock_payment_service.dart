import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';

/// IPaymentService 的手动 Mock 实现。
class MockPaymentService implements IPaymentService {
  // --- 控制 initiatePayment 的行为 ---
  bool _shouldFail = false;
  String? _lastInitiatedOrderId;
  String? _lastUsedPaymentMethodId;
  // Removed const because ServerFailure constructor is not const
  Failure _failureToReturn = ServerFailure(message: 'Mock Payment Error: Failed to initiate'); // 默认错误

  void setShouldFail(bool fail) {
    _shouldFail = fail;
  }

  void setFailureToReturn(Failure failure) {
    _failureToReturn = failure;
  }

  // 属性用于测试断言
  String? get lastInitiatedOrderId => _lastInitiatedOrderId;
  String? get lastUsedPaymentMethodId => _lastUsedPaymentMethodId;

  void clearLastInitiation() {
    _lastInitiatedOrderId = null;
    _lastUsedPaymentMethodId = null;
  }

  @override
  Future<Either<Failure, void>> initiatePayment(
    String orderId, {
    String? paymentMethodId,
  }) async {
    print('[MockPaymentService] Initiating payment for order: $orderId, Method ID: $paymentMethodId');
    _lastInitiatedOrderId = orderId;
    _lastUsedPaymentMethodId = paymentMethodId;
    await Future.delayed(const Duration(milliseconds: 200)); // 模拟处理时间

    if (_shouldFail) {
       print('[MockPaymentService] Returning Failure: $_failureToReturn');
      return Left(_failureToReturn);
    } else {
       print('[MockPaymentService] Payment initiation successful (mock).');
      return const Right(null); // 使用 const Right(null) 表示成功
    }
  }

  // --- 其他方法的 Mock 实现待添加 ---
} 