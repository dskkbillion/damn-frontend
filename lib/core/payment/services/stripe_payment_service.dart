import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/error/failures.dart';
import '../models/payment_models.dart' as models;
import '../presentation/pages/stripe_payment_webview_page.dart';
import 'i_payment_service.dart';

/// Stripe支付服务实现
/// 使用WebView在应用内打开支付链接，拦截支付成功URL并返回结果
@Injectable(as: IPaymentService)
class StripePaymentService implements IPaymentService {
  final ApiClient _apiClient;
  bool _isInitialized = false;
  BuildContext? _context;

  StripePaymentService(this._apiClient);

  /// 设置BuildContext，用于打开WebView
  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  Future<models.PaymentResponse> createPayment(models.PaymentRequest request) async {
    try {
      AppLogger.d('[StripePaymentService] createPayment开始 - orderId: ${request.orderId}');

      if (_context == null) {
        AppLogger.d('[StripePaymentService] Context未设置，无法打开WebView');
        return models.PaymentResponse.failure(
          message: 'Context未设置，无法打开支付页面',
          orderId: request.orderId,
        );
      }

      // 1. 调用后端创建Stripe支付会话
      final response = await _createPaymentSession(request);
      if (!response.success) {
        AppLogger.d('[StripePaymentService] 创建支付会话失败: ${response.message}');
        return response;
      }

      // 2. 在WebView中打开Stripe支付页面
      final paymentUrl = response.data;
      AppLogger.d('[StripePaymentService] 准备在WebView中打开支付URL: $paymentUrl');

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        // 打开WebView并等待结果
        final result = await _openPaymentWebView(
          context: _context!,
          paymentUrl: paymentUrl,
          orderId: request.orderId,
        );

        AppLogger.d('[StripePaymentService] WebView返回结果: $result');

        if (result != null && result['result'] == PaymentWebViewResult.success) {
          // 支付成功
          return models.PaymentResponse(
            success: true,
            data: paymentUrl,
            orderId: request.orderId,
            message: '支付成功',
            resultType: models.PaymentResultType.success,
          );
        } else if (result != null && result['result'] == PaymentWebViewResult.cancelled) {
          // 用户取消
          return models.PaymentResponse.failure(
            message: '用户取消支付',
            orderId: request.orderId,
          );
        } else {
          // 支付失败
          return models.PaymentResponse.failure(
            message: '支付失败',
            orderId: request.orderId,
          );
        }
      } else {
        AppLogger.d('[StripePaymentService] 支付URL为空');
        return models.PaymentResponse.failure(
          message: '未获取到支付链接',
          orderId: request.orderId,
        );
      }
    } catch (e) {
      AppLogger.d('[StripePaymentService] Stripe支付异常: $e');
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
      AppLogger.d('取消Stripe支付失败: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      _isInitialized = true;
      AppLogger.d('Stripe支付服务初始化成功');
    } catch (e) {
      AppLogger.d('Stripe支付服务初始化失败: $e');
      _isInitialized = false;
    }
  }

  @override
  bool get isAvailable => _isInitialized;

  /// 创建Stripe支付会话
  Future<models.PaymentResponse> _createPaymentSession(models.PaymentRequest request) async {
    // 构建请求参数，与支付宝和微信保持一致
    final requestData = {
      'businessId': int.tryParse(request.orderId) ?? 0,
      'scene': request.scene.code,
      'payway': request.method.code, // 'stripe'
      'currency': 'usd', // 强制使用美元
    };

    AppLogger.d('[StripePaymentService] 发送支付请求: $requestData');
    final response = await _apiClient.dio.post('/api/payment', data: requestData);
    AppLogger.d('[StripePaymentService] 收到响应: ${response.data}');

    // 后端返回格式: {"msg":"支付成功","code":200,"data":{"url":"https://checkout.stripe.com/..."}}
    if (response.statusCode == 200 && response.data['code'] == 200) {
      // 从data对象中获取url字段
      final data = response.data['data'];
      final stripeUrl = data is Map ? data['url'] : data;
      AppLogger.d('[StripePaymentService] 解析出的URL: $stripeUrl');
      if (stripeUrl != null && stripeUrl.toString().startsWith('http')) {
        return models.PaymentResponse.success(
          data: stripeUrl,
          orderId: request.orderId,
          message: response.data['msg'] ?? '获取支付链接成功',
        );
      } else {
        AppLogger.d('[StripePaymentService] URL格式无效: $stripeUrl');
        return models.PaymentResponse.failure(
          message: '返回的支付链接格式无效',
          orderId: request.orderId,
        );
      }
    } else {
      AppLogger.d('[StripePaymentService] 请求失败: ${response.data}');
      return models.PaymentResponse.failure(
        message: response.data['msg'] ?? '创建支付会话失败',
        code: response.data['code'],
        orderId: request.orderId,
      );
    }
  }

  /// 在WebView中打开支付URL
  Future<Map<String, dynamic>?> _openPaymentWebView({
    required BuildContext context,
    required String paymentUrl,
    required String orderId,
  }) async {
    try {
      AppLogger.d('[StripePaymentService] 打开WebView - URL: $paymentUrl');

      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => StripePaymentWebViewPage(
            paymentUrl: paymentUrl,
            orderId: orderId,
            // 匹配后端配置的 URL: /stripe/callback/success 和 /stripe/callback/cancel
            successUrlPattern: 'stripe/callback/success',
            cancelUrlPattern: 'stripe/callback/cancel',
            failureUrlPattern: 'stripe/callback/failure',
          ),
        ),
      );

      AppLogger.d('[StripePaymentService] WebView关闭，结果: $result');
      return result;
    } catch (e) {
      AppLogger.d('[StripePaymentService] 打开WebView失败: $e');
      return null;
    }
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
      // 查询订单信息
      String actualAmount = '0.01';
      String subject = '订单支付';
      
      try {
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
        amount: actualAmount,
        subject: subject,
        description: '订单号: $orderId',
        method: models.PaymentMethod.stripe,
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
      // 创建订单
      final requestData = {
        'tenantId': orderData['sellerId'] ?? orderData['tenantId'],
        'couponId': orderData['couponId'],
        'remark': orderData['remark'] ?? '通过应用下单',
        'items': [
          {
            'productId': orderData['productId'],
            'variantId': orderData['variantId'],
            'quantity': orderData['quantity'] ?? 1
          }
        ],
        'addressId': orderData['addressId'],
        'groupId': orderData['groupId'],
        'activityType': orderData['activityType'] ?? 'product',
        'referrerId': orderData['referrerId'],
      };
      
      final response = await _apiClient.dio.post(
        '/api/shop/order/create',
        data: requestData,
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final orderId = response.data['data']['id'];
        
        // 调用支付API获取Stripe支付链接
        final payResponse = await _apiClient.dio.post(
          '/api/payment',
          data: {
            'businessId': orderId,
            'scene': 'order',
            'payway': 'stripe',
            'currency': 'usd', // 添加货币参数，使用美元
          },
        );
        
        if (payResponse.statusCode == 200 && payResponse.data['code'] == 200) {
          // 从data对象中获取url字段，与_createPaymentSession保持一致
          final data = payResponse.data['data'];
          final stripeUrl = data is Map ? data['url'] : data;
          if (stripeUrl == null || stripeUrl.toString().isEmpty) {
            throw Exception('未获取到支付链接');
          }
          return stripeUrl.toString(); // 返回Stripe支付URL
        } else {
          throw Exception(payResponse.data['msg'] ?? '获取支付链接失败');
        }
      } else {
        throw Exception(response.data['msg'] ?? '创建订单失败');
      }
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }

  @override
  Future<PaymentResult> pay(String orderInfo) async {
    try {
      if (_context == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Context未设置，无法打开支付页面',
        );
      }

      // 对于Stripe，orderInfo就是支付URL
      // 从orderInfo中提取orderId（如果包含）
      String orderId = 'unknown';
      try {
        final uri = Uri.parse(orderInfo);
        orderId = uri.queryParameters['orderId'] ?? orderId;
      } catch (_) {
        // 如果解析失败，使用默认值
      }

      final result = await _openPaymentWebView(
        context: _context!,
        paymentUrl: orderInfo,
        orderId: orderId,
      );

      if (result != null && result['result'] == PaymentWebViewResult.success) {
        return PaymentResult(
          success: true,
          errorMessage: null,
        );
      } else if (result != null && result['result'] == PaymentWebViewResult.cancelled) {
        return PaymentResult(
          success: false,
          errorMessage: '用户取消支付',
        );
      } else {
        return PaymentResult(
          success: false,
          errorMessage: '支付失败',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: '打开支付页面失败: $e',
      );
    }
  }
}