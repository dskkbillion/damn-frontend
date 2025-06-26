import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import '../models/payment_models.dart' as models;

/// 定义支付服务相关的接口契约。
abstract class IPaymentService {

  /// 初始化支付服务
  Future<void> initialize();

  /// 支付服务是否可用
  bool get isAvailable;

  /// 创建支付订单
  Future<models.PaymentResponse> createPayment(models.PaymentRequest request);

  /// 查询支付状态
  Future<models.PaymentResult> queryPaymentStatus(String orderId);

  /// 取消支付
  Future<bool> cancelPayment(String orderId);

  // --- 向后兼容的方法 ---
  
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

  /// 生成支付订单信息
  /// 
  /// [orderData] 订单数据，包含商品ID、数量、价格等信息
  /// 返回可用于发起支付的支付宝订单信息字符串
  Future<String> generateOrderInfo(Map<String, dynamic> orderData);
  
  /// 发起支付
  /// 
  /// [orderInfo] 支付宝订单信息字符串
  /// 返回支付结果
  Future<PaymentResult> pay(String orderInfo);

  // --- 可以根据需要添加更多支付相关方法 ---
  // Future<Either<Failure, List<PaymentMethod>>> getAvailablePaymentMethods();
  // Future<Either<Failure, PaymentStatus>> checkPaymentStatus(String orderId);
}

/// 支付结果
class PaymentResult {
  /// 支付是否成功
  final bool success;
  
  /// 订单ID，支付成功时有值
  final String? orderId;
  
  /// 错误信息，支付失败时有值
  final String? errorMessage;
  
  PaymentResult({
    required this.success,
    this.orderId,
    this.errorMessage,
  });
} 