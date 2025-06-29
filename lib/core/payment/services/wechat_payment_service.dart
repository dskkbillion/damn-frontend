import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../core/api/api_client.dart';
import '../../../core/error/failures.dart';
import '../config/wechat_config.dart';
import '../models/payment_models.dart' as models;
import 'i_payment_service.dart';

/// 微信支付服务
/// 服务端托管模式：后端处理所有签名和密钥管理，客户端只负责调用SDK和展示结果
@Injectable(as: IPaymentService)
class WechatPaymentService implements IPaymentService {
  final ApiClient _apiClient;
  WechatConfig? _config;
  
  bool _isInitialized = false;
  Function(WeChatResponse)? _responseSubscriber;

  WechatPaymentService(this._apiClient);

  @override
  String get paymentMethod => 'wechat';

  @override
  bool get isAvailable => _isServiceAvailable();

  @override
  Future<void> initialize() async {
    try {
      // 加载配置
      await _ensureConfigLoaded();
      
      // 初始化微信SDK（简化版）
      await _initializeWechatSDK();
      
      print('[WechatPaymentService] 微信支付服务初始化成功（服务端托管模式）');
    } catch (e) {
      print('[WechatPaymentService] 微信支付服务初始化失败: $e');
    }
  }

  /// 确保配置已加载
  Future<void> _ensureConfigLoaded() async {
    _config ??= await WechatConfig.loadFromAssets();
  }

  /// 检查服务是否可用
  bool _isServiceAvailable() {
    if (_config?.mockPayment == true) {
      return true;
    }
    
    if (_config?.appConfig.isValid != true) {
      return false;
    }
    
    return _isInitialized;
  }

  /// 初始化微信SDK
  Future<void> _initializeWechatSDK() async {
    try {
      if (_config == null) {
        await _ensureConfigLoaded();
      }
      
      if (_config!.mockPayment) {
        _isInitialized = true;
        print('[WechatPaymentService] Mock mode initialized');
        return;
      }
      
      print('[WechatPaymentService] Initializing Wechat SDK...');
      print('[WechatPaymentService] AppId: ${_config!.appId}');
      print('[WechatPaymentService] UniversalLink: ${_config!.universalLink}');
      
      // 注册微信SDK
      final fluwx = Fluwx();
      await fluwx.registerApi(
        appId: _config!.appId,
        universalLink: _config!.universalLink,
      );
      
      // 检查微信是否安装
      final isInstalled = await fluwx.isWeChatInstalled;
      print('[WechatPaymentService] WeChat installed: $isInstalled');
      
      if (!isInstalled) {
        print('[WechatPaymentService] WeChat is not installed');
        _isInitialized = false;
        return;
      }
      
      // 设置支付结果监听
      _setupResponseListener();
      
      _isInitialized = true;
      print('[WechatPaymentService] SDK initialized successfully');
    } catch (e) {
      print('[WechatPaymentService] Failed to initialize SDK: $e');
      _isInitialized = false;
    }
  }

  /// 设置响应监听器
  void _setupResponseListener() {
    _removeResponseListener();
    final fluwx = Fluwx();
    _responseSubscriber = (response) {
      print('[WechatPaymentService] Received WeChat response: ${response.runtimeType}');
      _handleWeChatResponse(response);
    };
    fluwx.addSubscriber(_responseSubscriber!);
  }

  /// 处理微信响应
  void _handleWeChatResponse(WeChatResponse response) {
    if (response is WeChatPaymentResponse) {
      print('[WechatPaymentService] Payment response - errCode: ${response.errCode}, errStr: ${response.errStr}');
      // 支付结果会通过Completer传递到调用方
    } else {
      print('[WechatPaymentService] Non-payment response: ${response.runtimeType}');
    }
  }

  /// 移除响应监听器
  void _removeResponseListener() {
    if (_responseSubscriber != null) {
      final fluwx = Fluwx();
      fluwx.removeSubscriber(_responseSubscriber!);
      _responseSubscriber = null;
    }
  }

  @override
  Future<models.PaymentResponse> createPayment(models.PaymentRequest request) async {
    try {
      // 确保配置已加载
      await _ensureConfigLoaded();
      
      // 开发环境模拟支付
      if (_config?.mockPayment == true) {
        return await _mockPayment(request);
      }
      
      // 检查服务是否可用
      if (!_isServiceAvailable()) {
        return models.PaymentResponse.failure(
          message: '微信支付服务暂不可用，请稍后重试',
          orderId: request.orderId,
          resultType: models.PaymentResultType.failed,
        );
      }

      print('[WechatPaymentService] Initiating payment for order: ${request.orderId}');

      // 1. 调用后端API获取支付参数
      final paymentData = await _createPaymentOrder(request);
      if (!paymentData.success) {
        return paymentData;
      }

      // 2. 解析支付参数
      final paymentInfo = _parsePaymentInfo(paymentData.data!);
      if (paymentInfo == null) {
        return models.PaymentResponse.failure(
          message: '支付参数解析失败',
          orderId: request.orderId,
          resultType: models.PaymentResultType.failed,
        );
      }

      // 3. 调用微信支付（当前返回Mock结果）
      final result = await _callWechatPay(paymentInfo, request.orderId);
      return result;

    } catch (e) {
      print('[WechatPaymentService] Payment initiation failed: $e');
      return models.PaymentResponse.failure(
        message: '发起支付失败: ${e.toString()}',
        orderId: request.orderId,
        resultType: models.PaymentResultType.failed,
      );
    }
  }

  /// 创建支付订单
  Future<models.PaymentResponse> _createPaymentOrder(models.PaymentRequest request) async {
    final requestData = {
      'businessId': int.tryParse(request.orderId) ?? 0,
      'scene': request.scene.code,
      'payway': request.method.code,
    };

    final response = await _apiClient.dio.post('/api/payment', data: requestData);

    if (response.statusCode == 200 && response.data['code'] == 200) {
      return models.PaymentResponse.success(
        data: response.data['data'],
        orderId: request.orderId,
        paymentId: null,
        message: response.data['msg'],
      );
    } else {
      return models.PaymentResponse.failure(
        message: response.data['msg'] ?? '创建支付订单失败',
        code: response.data['code'],
        orderId: request.orderId,
        resultType: models.PaymentResultType.failed,
      );
    }
  }

  /// 解析后端返回的支付参数
  Map<String, dynamic>? _parsePaymentInfo(String paymentData) {
    try {
      return json.decode(paymentData) as Map<String, dynamic>;
    } catch (e) {
      print('[WechatPaymentService] Failed to parse payment info: $e');
      return null;
    }
  }

  /// 调用微信支付
  Future<models.PaymentResponse> _callWechatPay(
    Map<String, dynamic> paymentInfo, 
    String orderId,
  ) async {
    try {
      print('[WechatPaymentService] Calling WeChat pay with info: $paymentInfo');

      final completer = Completer<models.PaymentResponse>();
      
      // 设置支付监听器
      _setupPaymentListener(completer, orderId);

      final fluwx = Fluwx();
      
      // 调用微信支付
      await fluwx.pay(
        which: Payment(
          appId: paymentInfo['appid'] ?? _config!.appId,
          partnerId: paymentInfo['partnerid'] ?? '',
          prepayId: paymentInfo['prepayid'] ?? '',
          packageValue: paymentInfo['package'] ?? 'Sign=WXPay',
          nonceStr: paymentInfo['noncestr'] ?? '',
          timestamp: int.tryParse(paymentInfo['timestamp']?.toString() ?? '0') ?? 0,
          sign: paymentInfo['sign'] ?? '',
        ),
      );

      // 等待支付结果，设置5分钟超时
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          _removeResponseListener();
                     return models.PaymentResponse.failure(
             message: '支付超时，请稍后重试',
             orderId: orderId,
             resultType: models.PaymentResultType.unknown,
           );
        },
      );

    } catch (e) {
      print('[WechatPaymentService] WeChat pay call failed: $e');
      _removeResponseListener();
      return models.PaymentResponse.failure(
        message: '调用微信支付失败: ${e.toString()}',
        orderId: orderId,
        resultType: models.PaymentResultType.failed,
      );
    }
  }

  /// 设置支付监听器
  void _setupPaymentListener(
    Completer<models.PaymentResponse> completer,
    String orderId,
  ) {
    _removeResponseListener();
    final fluwx = Fluwx();
    
    _responseSubscriber = (response) {
      if (response is WeChatPaymentResponse) {
        _removeResponseListener();
        
        print('[WechatPaymentService] Payment result - errCode: ${response.errCode}, errStr: ${response.errStr}');
        
        switch (response.errCode) {
          case 0:
            // 支付成功
            completer.complete(models.PaymentResponse.success(
              data: 'wechat_payment_success',
              orderId: orderId,
                             paymentId: null, // 微信支付响应中没有直接的transactionId字段
              message: '微信支付成功',
            ));
            break;
          case -2:
            // 用户取消
                         completer.complete(models.PaymentResponse.failure(
               message: '用户取消支付',
               orderId: orderId,
               resultType: models.PaymentResultType.userCancelled,
             ));
            break;
          case -1:
            // 支付失败
            completer.complete(models.PaymentResponse.failure(
              message: response.errStr ?? '支付失败',
              orderId: orderId,
              resultType: models.PaymentResultType.failed,
            ));
            break;
          default:
            // 其他错误
            completer.complete(models.PaymentResponse.failure(
              message: response.errStr ?? '支付发生未知错误',
              orderId: orderId,
              resultType: models.PaymentResultType.failed,
            ));
            break;
        }
      }
    };
    
    fluwx.addSubscriber(_responseSubscriber!);
  }

  /// 处理Mock支付
  Future<models.PaymentResponse> _mockPayment(models.PaymentRequest request) async {
    await Future.delayed(const Duration(seconds: 2)); // 模拟网络延迟
    
    if (kDebugMode) {
      Fluttertoast.showToast(msg: '[Mock] 微信支付成功');
    }
    
    return models.PaymentResponse.success(
      data: 'mock_wechat_payment_success',
      orderId: request.orderId,
      message: '[Mock] 微信支付成功',
    );
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
        message: '查询失败: ${e.toString()}',
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
      print('[WechatPaymentService] 取消支付失败: $e');
      return false;
    }
  }

  /// 解析支付状态
  models.PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'success':
        return models.PaymentStatus.success;
      case 'failed':
        return models.PaymentStatus.failed;
      case 'cancelled':
        return models.PaymentStatus.cancelled;
      case 'processing':
        return models.PaymentStatus.processing;
      case 'timeout':
        return models.PaymentStatus.timeout;
      default:
        return models.PaymentStatus.pending;
    }
  }

  @override
  void dispose() {
    print('[WechatPaymentService] Service disposed');
  }

  // 实现缺失的接口方法
  @override
  Future<Either<Failure, void>> initiatePayment(
    String orderId, {
    String? paymentMethodId,
  }) async {
    try {
      final request = models.PaymentRequest(
        orderId: orderId,
        method: models.PaymentMethod.wechat,
        scene: models.PaymentScene.order,
        amount: '0.01', // 默认金额，实际应该从订单获取
        subject: '订单支付',
        description: '微信支付订单',
      );
      final result = await createPayment(request);
      
      if (result.success) {
        return const Right(null);
      } else {
        return Left(PaymentFailure(message: result.message ?? '支付失败'));
      }
    } catch (e) {
      return Left(PaymentFailure(message: '支付异常: ${e.toString()}'));
    }
  }

  @override
  Future<String> generateOrderInfo(Map<String, dynamic> orderData) async {
    // 微信支付不需要像支付宝那样生成订单信息字符串
    // 这里返回JSON字符串
    return json.encode(orderData);
  }

  @override
  Future<PaymentResult> pay(String orderInfo) async {
    try {
      final orderData = json.decode(orderInfo) as Map<String, dynamic>;
      final orderId = orderData['orderId']?.toString() ?? '';
      
      final request = models.PaymentRequest(
        orderId: orderId,
        method: models.PaymentMethod.wechat,
        scene: models.PaymentScene.order,
        amount: orderData['amount']?.toString() ?? '0.01',
        subject: orderData['subject']?.toString() ?? '订单支付',
        description: orderData['description']?.toString() ?? '微信支付订单',
      );
      
      final result = await createPayment(request);
      
      return PaymentResult(
        success: result.success,
        orderId: result.success ? orderId : null,
        errorMessage: result.success ? null : result.message,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: '支付异常: ${e.toString()}',
      );
    }
  }
} 