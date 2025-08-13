import 'package:equatable/equatable.dart';

/// 支付方式枚举
enum PaymentMethod {
  alipay('alipay', '支付宝'),
  wechat('weapp', '微信支付'),  // 后端期望 'weapp' 代表微信APP支付
  stripe('stripe', '信用卡支付'); // 后端期望 'stripe' 代表Stripe支付

  const PaymentMethod(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// 支付场景枚举
enum PaymentScene {
  order('order', '订单支付'),
  vip('vip', '会员充值');

  const PaymentScene(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// 支付状态枚举
enum PaymentStatus {
  pending('pending', '待支付'),
  processing('processing', '支付中'),
  success('success', '支付成功'),
  failed('failed', '支付失败'),
  cancelled('cancelled', '支付取消'),
  timeout('timeout', '支付超时');

  const PaymentStatus(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// 支付结果类型枚举
/// 用于区分不同的支付结果，以便采用不同的导航和用户交互策略
enum PaymentResultType {
  /// 支付成功 - 跳转到支付成功页面或订单详情
  success('success', '支付成功'),
  
  /// 用户主动取消 - 跳转到订单页面的待付款状态，而不是失败页面
  userCancelled('user_cancelled', '用户取消支付'),
  
  /// 网络错误 - 提供重试选项，跳转到待付款订单
  networkError('network_error', '网络连接出错'),
  
  /// 支付结果未知 - 提供状态查询功能，跳转到待付款订单
  unknown('unknown', '支付结果未知'),
  
  /// 其他支付失败 - 跳转到支付失败页面
  failed('failed', '支付失败'),
  
  /// 正在处理中 - 提示用户等待，跳转到待付款订单
  processing('processing', '支付处理中');

  const PaymentResultType(this.code, this.displayName);
  final String code;
  final String displayName;
  
  /// 是否应该跳转到待付款订单而不是失败页面
  bool get shouldNavigateToOrders => this != PaymentResultType.success && this != PaymentResultType.failed;
  
  /// 是否需要提供重试功能
  bool get shouldOfferRetry => this == PaymentResultType.networkError || this == PaymentResultType.unknown;
  
  /// 是否需要提供状态查询功能
  bool get shouldOfferStatusQuery => this == PaymentResultType.unknown || this == PaymentResultType.processing;
}

/// 支付请求参数
class PaymentRequest extends Equatable {
  final String orderId;            // 订单ID
  final String amount;             // 支付金额
  final String subject;            // 商品标题
  final String description;        // 商品描述
  final PaymentMethod method;      // 支付方式
  final PaymentScene scene;        // 支付场景
  final String? passbackParams;    // 回传参数
  final int? timeoutExpress;       // 超时时间（分钟）
  
  const PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.subject,
    required this.description,
    required this.method,
    required this.scene,
    this.passbackParams,
    this.timeoutExpress,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'subject': subject,
      'description': description,
      'method': method.code,
      'scene': scene.code,
      'passbackParams': passbackParams,
      'timeoutExpress': timeoutExpress,
    };
  }
  
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      orderId: json['orderId'] ?? '',
      amount: json['amount'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      method: PaymentMethod.values.firstWhere(
        (e) => e.code == json['method'],
        orElse: () => PaymentMethod.alipay,
      ),
      scene: PaymentScene.values.firstWhere(
        (e) => e.code == json['scene'],
        orElse: () => PaymentScene.order,
      ),
      passbackParams: json['passbackParams'],
      timeoutExpress: json['timeoutExpress'],
    );
  }
  
  @override
  List<Object?> get props => [
    orderId, amount, subject, description, 
    method, scene, passbackParams, timeoutExpress
  ];
}

/// 支付响应
class PaymentResponse extends Equatable {
  final bool success;
  final String? data;              // 支付串或跳转URL
  final String? orderId;          // 订单ID
  final String? paymentId;        // 支付记录ID
  final String? message;          // 响应消息
  final int? code;               // 响应代码
  final PaymentResultType resultType;  // 支付结果类型，用于导航策略
  
  const PaymentResponse({
    required this.success,
    this.data,
    this.orderId,
    this.paymentId,
    this.message,
    this.code,
    this.resultType = PaymentResultType.failed,
  });
  
  factory PaymentResponse.success({
    required String data,
    String? orderId,
    String? paymentId,
    String? message,
  }) {
    return PaymentResponse(
      success: true,
      data: data,
      orderId: orderId,
      paymentId: paymentId,
      message: message,
      code: 200,
      resultType: PaymentResultType.success,
    );
  }
  
  factory PaymentResponse.failure({
    required String message,
    int? code,
    String? orderId,
    PaymentResultType? resultType,
  }) {
    return PaymentResponse(
      success: false,
      message: message,
      code: code ?? 500,
      orderId: orderId,
      resultType: resultType ?? PaymentResultType.failed,
    );
  }
  
  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'] ?? false,
      data: json['data'],
      orderId: json['orderId'],
      paymentId: json['paymentId'],
      message: json['message'],
      code: json['code'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'orderId': orderId,
      'paymentId': paymentId,
      'message': message,
      'code': code,
    };
  }
  
  @override
  List<Object?> get props => [success, data, orderId, paymentId, message, code, resultType];
}

/// 支付结果
class PaymentResult extends Equatable {
  final PaymentStatus status;
  final String? orderId;          // 订单ID
  final String? tradeNo;          // 交易号
  final String? amount;           // 实际支付金额
  final String? message;          // 结果消息
  final DateTime? payTime;        // 支付时间
  final Map<String, dynamic>? extraData; // 额外数据
  
  const PaymentResult({
    required this.status,
    this.orderId,
    this.tradeNo,
    this.amount,
    this.message,
    this.payTime,
    this.extraData,
  });
  
  /// 支付成功
  factory PaymentResult.success({
    required String orderId,
    required String tradeNo,
    required String amount,
    String? message,
    DateTime? payTime,
    Map<String, dynamic>? extraData,
  }) {
    return PaymentResult(
      status: PaymentStatus.success,
      orderId: orderId,
      tradeNo: tradeNo,
      amount: amount,
      message: message ?? '支付成功',
      payTime: payTime ?? DateTime.now(),
      extraData: extraData,
    );
  }
  
  /// 支付失败
  factory PaymentResult.failure({
    String? orderId,
    required String message,
    Map<String, dynamic>? extraData,
  }) {
    return PaymentResult(
      status: PaymentStatus.failed,
      orderId: orderId,
      message: message,
      extraData: extraData,
    );
  }
  
  /// 支付取消
  factory PaymentResult.cancelled({
    String? orderId,
    String? message,
    Map<String, dynamic>? extraData,
  }) {
    return PaymentResult(
      status: PaymentStatus.cancelled,
      orderId: orderId,
      message: message ?? '用户取消支付',
      extraData: extraData,
    );
  }
  
  /// 是否成功
  bool get isSuccess => status == PaymentStatus.success;
  
  /// 是否失败
  bool get isFailed => status == PaymentStatus.failed;
  
  /// 是否取消
  bool get isCancelled => status == PaymentStatus.cancelled;
  
  @override
  List<Object?> get props => [
    status, orderId, tradeNo, amount, 
    message, payTime, extraData
  ];
}

/// 支付异常类
class PaymentException implements Exception {
  final String message;
  final int? code;
  final String? orderId;
  final dynamic originalError;
  
  const PaymentException({
    required this.message,
    this.code,
    this.orderId,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'PaymentException{message: $message, code: $code, orderId: $orderId}';
  }
} 