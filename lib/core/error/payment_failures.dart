import 'failures.dart';

/// 支付相关错误抽象基类
abstract class PaymentFailure extends Failure {
  PaymentFailure({required String message}) : super(message: message);
}

/// 网络连接支付错误
class NetworkPaymentFailure extends PaymentFailure {
  NetworkPaymentFailure() : super(message: '网络连接失败，请检查网络设置');
}

/// 支付应用未安装错误
class PaymentNotInstalledFailure extends PaymentFailure {
  final String appName;
  PaymentNotInstalledFailure(this.appName) : super(message: '未安装$appName，请先安装');
}

/// 用户取消支付错误
class PaymentCancelledFailure extends PaymentFailure {
  PaymentCancelledFailure() : super(message: '用户取消支付');
}

/// 支付超时错误
class PaymentTimeoutFailure extends PaymentFailure {
  PaymentTimeoutFailure() : super(message: '支付超时，请重试');
}

/// 订单创建失败错误
class OrderCreationFailure extends PaymentFailure {
  final String? orderId;
  OrderCreationFailure({String? message, this.orderId}) 
    : super(message: message ?? '订单创建失败');
}

/// 支付信息获取失败错误
class PaymentInfoFailure extends PaymentFailure {
  final String paymentMethod;
  PaymentInfoFailure(this.paymentMethod, {String? message}) 
    : super(message: message ?? '获取${paymentMethod}支付信息失败');
}

/// 支付验证失败错误
class PaymentVerificationFailure extends PaymentFailure {
  final String? transactionId;
  PaymentVerificationFailure({String? message, this.transactionId}) 
    : super(message: message ?? '支付验证失败');
}

/// 不支持的支付方式错误
class UnsupportedPaymentMethodFailure extends PaymentFailure {
  final String paymentMethod;
  UnsupportedPaymentMethodFailure(this.paymentMethod) 
    : super(message: '不支持的支付方式: $paymentMethod');
}

/// 支付金额错误
class InvalidPaymentAmountFailure extends PaymentFailure {
  final double amount;
  InvalidPaymentAmountFailure(this.amount) 
    : super(message: '无效的支付金额: ¥${amount.toStringAsFixed(2)}');
}

/// 支付配置错误
class PaymentConfigurationFailure extends PaymentFailure {
  final String paymentMethod;
  PaymentConfigurationFailure(this.paymentMethod) 
    : super(message: '$paymentMethod支付配置错误，请联系客服');
}

/// 服务器支付错误
class ServerPaymentFailure extends PaymentFailure {
  final int? statusCode;
  final String? errorCode;
  
  ServerPaymentFailure({
    String? message,
    this.statusCode,
    this.errorCode,
  }) : super(message: message ?? '服务器支付错误');
}

/// 支付重试次数超限错误
class PaymentRetryExceededFailure extends PaymentFailure {
  final int maxRetries;
  PaymentRetryExceededFailure(this.maxRetries) 
    : super(message: '支付重试次数已超过$maxRetries次，请稍后再试');
}

/// 支付错误工厂类
class PaymentFailureFactory {
  /// 根据错误类型创建对应的PaymentFailure
  static PaymentFailure createFromException(
    Exception exception, {
    String? paymentMethod,
  }) {
    final errorMessage = exception.toString();
    
    if (errorMessage.contains('网络') || errorMessage.contains('network')) {
      return NetworkPaymentFailure();
    }
    
    if (errorMessage.contains('超时') || errorMessage.contains('timeout')) {
      return PaymentTimeoutFailure();
    }
    
    if (errorMessage.contains('取消') || errorMessage.contains('cancel')) {
      return PaymentCancelledFailure();
    }
    
    if (errorMessage.contains('未安装') || errorMessage.contains('not installed')) {
      return PaymentNotInstalledFailure(paymentMethod ?? '支付应用');
    }
    
    // 默认返回通用支付错误
    return PaymentFailure(message: errorMessage);
  }
  
  /// 从API错误码创建支付错误
  static PaymentFailure createFromApiError(
    int statusCode,
    String? errorCode,
    String? message,
  ) {
    if (statusCode >= 500) {
      return ServerPaymentFailure(
        statusCode: statusCode,
        errorCode: errorCode,
        message: message ?? '服务器内部错误',
      );
    }
    
    if (statusCode == 404) {
      return PaymentFailure(message: '支付接口不存在');
    }
    
    if (statusCode == 401 || statusCode == 403) {
      return PaymentFailure(message: '支付权限验证失败');
    }
    
    return PaymentFailure(message: message ?? '支付请求失败');
  }
}

/// 简化的PaymentFailure实现
class SimplePaymentFailure extends PaymentFailure {
  SimplePaymentFailure({required String message}) : super(message: message);
}