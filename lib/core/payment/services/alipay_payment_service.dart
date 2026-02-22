import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
// import 'package:tobias/tobias.dart'; // 暂时禁用支付宝SDK
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../core/api/api_client.dart';
import '../../../core/error/failures.dart';
import '../config/alipay_config.dart';
import '../models/payment_models.dart' as models;
import 'i_payment_service.dart';

/// 支付宝支付服务实现（服务端托管模式）
/// 服务端处理所有签名和密钥管理，客户端只负责调用SDK
@Injectable(as: IPaymentService)
class AlipayPaymentService implements IPaymentService {
  final ApiClient _apiClient;
  AlipayConfig? _config;

  AlipayPaymentService(this._apiClient);

  @override
  Future<models.PaymentResponse> createPayment(models.PaymentRequest request) async {
    try {
      // 确保配置已加载
      await _ensureConfigLoaded();
      
      // 开发环境模拟支付
      if (_config?.mockPayment == true) {
        return await _mockPayment(request);
      }
      
      // 服务端托管模式：简化配置验证
      // 后端已处理所有支付宝配置，客户端只需要能正常请求即可
      if (!_isServiceAvailable()) {
        return models.PaymentResponse.failure(
          message: '支付服务暂不可用，请稍后重试',
          orderId: request.orderId,
        );
      }
      
      // 1. 调用后端创建支付订单（服务端处理所有签名）
      final response = await _createPaymentOrder(request);
      if (!response.success) {
        return response;
      }

      // 2. 根据支付方式处理
      if (request.method == models.PaymentMethod.stripe) {
        // Stripe支付：直接返回URL，由UI层处理WebView
        // 注意：这里只返回成功获取URL，实际支付在WebView完成后才确定
        return response;
      }

      // 3. 支付宝：调用SDK
      final payResult = await _callAlipaySdk(response.data!);

      // 4. 解析支付结果
      return _parsePayResult(payResult, request.orderId);
      
    } catch (e) {
      AppLogger.d('支付异常: $e');
      return models.PaymentResponse.failure(
        message: _getErrorMessage(e),
        orderId: request.orderId,
      );
    }
  }

  @override
  Future<models.PaymentResult> queryPaymentStatus(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/api/payment/status/$orderId');
      
      if (response.data['success'] == true) {
        final data = response.data['data'];
        return models.PaymentResult(
          status: _parsePaymentStatus(data['status']),
          orderId: orderId,
          tradeNo: data['tradeNo'],
          amount: data['amount'],
          message: data['message'],
          payTime: data['payTime'] != null 
            ? DateTime.tryParse(data['payTime']) 
            : null,
        );
      } else {
        return models.PaymentResult.failure(
          orderId: orderId,
          message: response.data['message'] ?? '查询失败',
        );
      }
    } catch (e) {
      return models.PaymentResult.failure(
        orderId: orderId,
        message: _getErrorMessage(e),
      );
    }
  }

  @override
  Future<bool> cancelPayment(String orderId) async {
    try {
      final response = await _apiClient.dio.post('/api/payment/cancel', data: {
        'orderId': orderId,
      });
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.d('取消支付失败: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      // 加载配置
      await _ensureConfigLoaded();
      
      AppLogger.d('支付宝支付服务初始化成功（服务端托管模式）');
    } catch (e) {
      AppLogger.d('支付宝支付服务初始化失败: $e');
    }
  }

  @override
  bool get isAvailable {
    // 服务端托管模式：只要配置能加载或启用Mock就认为可用
    return _config != null && (_config!.mockPayment || _isServiceAvailable());
  }

  /// 确保配置已加载（服务端托管模式）
  Future<void> _ensureConfigLoaded() async {
    _config ??= await AlipayConfig.getInstance();
    // 注意：服务端托管模式不再加载客户端密钥
  }

  /// 验证服务是否可用（简化版）
  bool _isServiceAvailable() {
    // 服务端托管模式：只要配置能加载就认为可用
    // 所有的密钥和签名验证都由服务端处理
    return _config != null;
  }

  /// 创建支付订单
  Future<models.PaymentResponse> _createPaymentOrder(models.PaymentRequest request) async {
    // 构建请求参数（根据后端API文档调整）
    final requestData = {
              'businessId': int.tryParse(request.orderId) ?? 0, // 后端期望的是驼峰命名businessId
      'scene': request.scene.code, // 业务场景：order, vip, wallet
      'payway': request.method.code, // 支付方式：alipay, wechat, wallet, stripe
      'currency': request.method == models.PaymentMethod.stripe ? 'usd' : 'cny', // Stripe使用usd，其他使用cny
    };

    final response = await _apiClient.dio.post('/api/payment', data: requestData);

    // 后端返回格式:
    // - 支付宝: {"msg":"支付成功","code":200,"data":"alipay_sdk=..."}
    // - Stripe: {"msg":"支付成功","code":200,"data":{"url":"https://checkout.stripe.com/..."}}
    if (response.statusCode == 200 && response.data['code'] == 200) {
      // 处理不同支付方式的响应格式
      final responseData = response.data['data'];
      String paymentData;
      if (responseData is Map) {
        // Stripe 格式：从 data 对象中提取 url
        paymentData = responseData['url']?.toString() ?? '';
      } else {
        // 支付宝格式：data 直接是字符串
        paymentData = responseData?.toString() ?? '';
      }

      return models.PaymentResponse.success(
        data: paymentData,
        orderId: request.orderId,
        paymentId: null, // 后端没有返回paymentId
        message: response.data['msg'],
      );
    } else {
      return models.PaymentResponse.failure(
        message: response.data['msg'] ?? '创建支付订单失败',
        code: response.data['code'],
        orderId: request.orderId,
      );
    }
  }

  /// 调用支付宝SDK
  Future<Map<String, dynamic>> _callAlipaySdk(String paymentString) async {
    // 暂时禁用支付宝SDK
    throw UnimplementedError('支付宝支付暂不可用，请使用其他支付方式');
    // final tobias = Tobias();
    // final result = await tobias.pay(paymentString);
    // return Map<String, dynamic>.from(result);
  }

  /// 解析支付结果
  models.PaymentResponse _parsePayResult(Map<String, dynamic> result, String orderId) {
    final resultStatus = result['resultStatus'];
    final memo = result['memo'] ?? '';
    final resultString = result['result'] ?? '';

    switch (resultStatus) {
      case '9000':
        // 支付成功
        return models.PaymentResponse.success(
          data: resultString,
          orderId: orderId,
          message: '支付成功',
        );
      case '8000':
        // 正在处理中
        return models.PaymentResponse.failure(
          message: '支付处理中，请稍后查询结果',
          code: 8000,
          orderId: orderId,
          resultType: models.PaymentResultType.processing,
        );
      case '4000':
        // 支付失败
        return models.PaymentResponse.failure(
          message: memo.isNotEmpty ? memo : '支付失败',
          code: 4000,
          orderId: orderId,
          resultType: models.PaymentResultType.failed,
        );
      case '5000':
        // 重复请求
        return models.PaymentResponse.failure(
          message: '重复请求',
          code: 5000,
          orderId: orderId,
          resultType: models.PaymentResultType.failed,
        );
      case '6001':
        // 用户取消
        return models.PaymentResponse.failure(
          message: '您已取消支付',
          code: 6001,
          orderId: orderId,
          resultType: models.PaymentResultType.userCancelled,
        );
      case '6002':
        // 网络错误
        return models.PaymentResponse.failure(
          message: '网络连接出错，请重试',
          code: 6002,
          orderId: orderId,
          resultType: models.PaymentResultType.networkError,
        );
      case '6004':
        // 结果未知
        return models.PaymentResponse.failure(
          message: '支付结果未知，请查询订单状态',
          code: 6004,
          orderId: orderId,
          resultType: models.PaymentResultType.unknown,
        );
      default:
        return models.PaymentResponse.failure(
          message: memo.isNotEmpty ? memo : '支付失败',
          code: int.tryParse(resultStatus) ?? 9999,
          orderId: orderId,
          resultType: models.PaymentResultType.failed,
        );
    }
  }

  /// 模拟支付（开发环境）
  Future<models.PaymentResponse> _mockPayment(models.PaymentRequest request) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));
    
    return models.PaymentResponse.success(
      data: 'mock_payment_data',
      orderId: request.orderId,
      message: '模拟支付成功',
    );
  }

  /// 解析支付状态
  models.PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return models.PaymentStatus.pending;
      case 'processing':
        return models.PaymentStatus.processing;
      case 'success':
        return models.PaymentStatus.success;
      case 'failed':
        return models.PaymentStatus.failed;
      case 'cancelled':
        return models.PaymentStatus.cancelled;
      case 'timeout':
        return models.PaymentStatus.timeout;
      default:
        return models.PaymentStatus.failed;
    }
  }

  /// 获取错误消息
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '网络连接超时，请重试';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查网络';
        case DioExceptionType.badResponse:
          return '服务器响应异常';
        default:
          return '网络请求失败';
      }
    } else if (error is models.PaymentException) {
      return error.message;
    } else {
      return error.toString();
    }
  }

  // --- 向后兼容的方法实现 ---

  @override
  Future<Either<Failure, void>> initiatePayment(
    String orderId, {
    String? paymentMethodId,
  }) async {
    try {
      // 先查询订单信息获取实际金额
      String actualAmount = '0.01'; // 默认值
      String subject = '订单支付';
      
      try {
        // 调用订单查询API获取订单详情
        final orderResponse = await _apiClient.dio.get('/api/shop/order/detail?id=$orderId');
        if (orderResponse.statusCode == 200 && orderResponse.data['code'] == 200) {
          final orderData = orderResponse.data['data'];
          actualAmount = orderData['payPrice']?.toString() ?? orderData['totalPrice']?.toString() ?? '0.01';
          subject = '订单支付 - ${orderData['orderSn'] ?? orderId}';
        }
      } catch (e) {
        AppLogger.d('获取订单信息失败，使用默认金额: $e');
      }
      
      final request = models.PaymentRequest(
        orderId: orderId,
        amount: actualAmount, // 使用实际订单金额
        subject: subject,
        description: '订单号: $orderId',
        method: models.PaymentMethod.alipay,
        scene: models.PaymentScene.order,
      );
      
      final response = await createPayment(request);
      
      if (response.success) {
        return const Right(null);
      } else {
        return Left(PaymentFailure(message: response.message ?? '支付失败'));
      }
    } catch (e) {
      return Left(PaymentFailure(message: '发起支付失败: $e'));
    }
  }

  @override
  Future<String> generateOrderInfo(Map<String, dynamic> orderData) async {
    try {
      // 构建请求参数（根据API文档修正参数格式）
      final requestData = {
        'tenantId': orderData['sellerId'] ?? orderData['tenantId'], // 添加卖家ID（tenantId）
        'couponId': orderData['couponId'], // 优惠券ID，可为null
        'remark': orderData['remark'] ?? '通过应用下单',
        'items': [
          {
            'productId': orderData['productId'],
            'variantId': orderData['variantId'],
            'quantity': orderData['quantity'] ?? 1
          }
        ],
        'addressId': orderData['addressId'], // 收货地址ID，可为null  
        'groupId': orderData['groupId'], // 拼团ID，可为null
        'activityType': orderData['activityType'] ?? 'product', // 活动类型
        'referrerId': orderData['referrerId'], // 邀请人ID，可为null
      };
      
      // 调用创建订单API（使用正确的端点）
      final response = await _apiClient.dio.post(
        '/api/shop/order/create',
        data: requestData,
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final orderId = response.data['data']['id'];
        
        // 调用支付API获取支付信息
        final payResponse = await _apiClient.dio.post(
          '/api/payment',
          data: {
            'businessId': orderId, // 后端期望的是驼峰命名businessId
            'scene': 'order',
            'payway': 'alipay',
          },
        );
        
        if (payResponse.statusCode == 200 && payResponse.data['code'] == 200) {
          // 后端直接返回支付宝SDK字符串作为data，不是包装在orderInfo中
          return payResponse.data['data'];
        } else {
          throw Exception(payResponse.data['msg'] ?? '获取支付信息失败');
        }
      } else {
        throw Exception(response.data['msg'] ?? '创建订单失败');
      }
    } catch (e) {
      // 在开发/测试环境下，使用Mock订单信息
      if (orderData.containsKey('orderId') && orderData['orderId'].toString().startsWith('ORDER-')) {
        AppLogger.d('使用Mock订单信息进行支付测试');
        return 'mock_order_info_for_testing';
      }
      
      throw Exception('创建订单失败: $e');
    }
  }

  @override
  Future<PaymentResult> pay(String orderInfo) async {
    // 暂时禁用支付宝SDK
    return PaymentResult(
      success: false,
      errorMessage: '支付宝支付暂不可用，请使用其他支付方式（Stripe）',
    );
    /* 原支付宝SDK实现，暂时注释
    try {
      // 调用支付宝SDK进行支付
      final tobias = Tobias();
      final Map<dynamic, dynamic> payResult = await tobias.pay(orderInfo);

      // 解析支付结果
      final String resultStatus = payResult['resultStatus']?.toString() ?? '4000';

      // 根据结果状态码判断支付是否成功
      if (resultStatus == '9000') {
        // 支付成功
        Map<dynamic, dynamic> response = {};
        if (payResult.containsKey('result')) {
          response = payResult['result'] is Map ? payResult['result'] : {};
        } else if (payResult.containsKey('alipay_trade_app_pay_response')) {
          response = payResult['alipay_trade_app_pay_response'] is Map
            ? payResult['alipay_trade_app_pay_response']
            : {};
        }

        return PaymentResult(
          success: true,
          orderId: response['out_trade_no']?.toString(),
        );
      } else {
        // 支付失败
        return PaymentResult(
          success: false,
          errorMessage: _getPaymentErrorMsg(resultStatus),
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: '支付异常: $e',
      );
    }
    */
  }

  /// 获取支付错误信息
  String _getPaymentErrorMsg(String code) {
    switch (code) {
      case '8000': return '支付结果确认中';
      case '6001': return '用户取消支付';
      case '6002': return '网络连接出错';
      case '4000': return '支付失败';
      default: return '未知错误，错误码: $code';
    }
  }
} 