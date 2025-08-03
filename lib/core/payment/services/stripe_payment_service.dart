import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/error/failures.dart';
import '../models/payment_models.dart' as models;
import 'i_payment_service.dart';

/// Stripe支付服务实现
/// 使用支付链接方式，后端返回支付URL，前端跳转到该URL完成支付
@Injectable(as: IPaymentService)
class StripePaymentService implements IPaymentService {
  final ApiClient _apiClient;
  bool _isInitialized = false;

  StripePaymentService(this._apiClient);

  @override
  Future<models.PaymentResponse> createPayment(models.PaymentRequest request) async {
    try {
      // 1. 调用后端创建Stripe支付会话
      final response = await _createPaymentSession(request);
      if (!response.success) {
        return response;
      }
      
      // 2. 跳转到Stripe支付页面
      final paymentUrl = response.data;
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        // 直接打开支付URL
        await _launchPaymentUrl(paymentUrl);
        
        // 返回成功状态，表示支付链接已打开
        return models.PaymentResponse(
          success: true,
          data: paymentUrl,
          orderId: request.orderId,
          message: '正在跳转到Stripe支付页面',
          resultType: models.PaymentResultType.processing,
        );
      } else {
        return models.PaymentResponse.failure(
          message: '未获取到支付链接',
          orderId: request.orderId,
        );
      }
    } catch (e) {
      print('Stripe支付异常: $e');
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
      print('取消Stripe支付失败: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    try {
      _isInitialized = true;
      print('Stripe支付服务初始化成功');
    } catch (e) {
      print('Stripe支付服务初始化失败: $e');
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
    };

    final response = await _apiClient.dio.post('/api/payment', data: requestData);

    // 后端返回格式: {"msg":"支付成功","code":200,"data":"https://checkout.stripe.com/..."}
    if (response.statusCode == 200 && response.data['code'] == 200) {
      // data字段直接就是Stripe的支付链接
      final stripeUrl = response.data['data'];
      if (stripeUrl != null && stripeUrl.toString().startsWith('http')) {
        return models.PaymentResponse.success(
          data: stripeUrl,
          orderId: request.orderId,
          message: response.data['msg'] ?? '获取支付链接成功',
        );
      } else {
        return models.PaymentResponse.failure(
          message: '返回的支付链接格式无效',
          orderId: request.orderId,
        );
      }
    } else {
      return models.PaymentResponse.failure(
        message: response.data['msg'] ?? '创建支付会话失败',
        code: response.data['code'],
        orderId: request.orderId,
      );
    }
  }

  /// 启动支付URL
  Future<void> _launchPaymentUrl(String url) async {
    try {
      print('[StripePaymentService] 尝试打开支付URL: $url');
      final uri = Uri.parse(url);
      
      // 首先检查是否可以启动URL
      final canLaunch = await canLaunchUrl(uri);
      print('[StripePaymentService] canLaunchUrl结果: $canLaunch');
      
      if (canLaunch) {
        // 尝试在外部浏览器中打开
        final launched = await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        print('[StripePaymentService] launchUrl结果: $launched');
        
        if (!launched) {
          throw Exception('launchUrl返回false');
        }
      } else {
        // 如果不能直接启动，尝试使用platformDefault模式
        print('[StripePaymentService] 尝试使用platformDefault模式');
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        
        if (!launched) {
          throw Exception('无法使用任何模式打开URL');
        }
      }
    } catch (e) {
      print('[StripePaymentService] 打开支付页面失败: $e');
      throw Exception('无法打开支付页面: $url, 错误: $e');
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
        print('获取订单信息失败，使用默认金额: $e');
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
          },
        );
        
        if (payResponse.statusCode == 200 && payResponse.data['code'] == 200) {
          return payResponse.data['data']; // 返回Stripe支付URL
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
      // 对于Stripe，orderInfo就是支付URL
      await _launchPaymentUrl(orderInfo);
      
      // 由于是跳转到外部页面，这里返回处理中状态
      return PaymentResult(
        success: false,
        errorMessage: '正在处理支付，请在浏览器中完成',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: '打开支付页面失败: $e',
      );
    }
  }
}