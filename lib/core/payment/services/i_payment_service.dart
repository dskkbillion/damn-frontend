import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 定义支付服务相关的接口契约。
abstract class IPaymentService {

  /// 启动针对特定订单的支付流程。
  ///
  /// 这可能会导航到一个支付网关页面，或者直接调起支付 SDK。
  /// 具体的行为和参数取决于支付模块的实现。
  ///
  /// [orderId] 需要支付的订单 ID。
  /// [paymentMethodId] (可选) 用户可能选择的支付方式。
  /// 返回值可能表示支付流程是否成功启动，或者直接是支付结果。
  /// 这里暂时定义为 Future<Either<Failure, void>>，表示启动成功或失败。
  Future<Either<Failure, void>> initiatePayment(
    String orderId, {
    String? paymentMethodId, // 例如 'alipay', 'wechatpay', 'creditcard'
    // 其他可能需要的参数，如支付金额（虽然可以从订单获取）、回调 URL 等
  });

  // --- 可以根据需要添加更多支付相关方法 ---
  // Future<Either<Failure, List<PaymentMethod>>> getAvailablePaymentMethods();
  // Future<Either<Failure, PaymentStatus>> checkPaymentStatus(String orderId);
} 