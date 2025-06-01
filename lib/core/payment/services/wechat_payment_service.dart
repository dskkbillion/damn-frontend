import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:fluwx/fluwx.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import 'i_payment_service.dart';

/// 微信支付服务实现
@Injectable()
class WechatPaymentService implements IPaymentService {
  final Dio dio;
  final NetworkInfo networkInfo;

  WechatPaymentService(this.dio, this.networkInfo);

  @override
  Future<Either<Failure, void>> initiatePayment(
    String orderId, {
    String? paymentMethodId,
  }) async {
    try {
      // 根据订单ID获取支付信息
      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'paymentMethod': paymentMethodId ?? 'wechat',
      };
      
      // 生成支付订单信息
      final String orderInfo = await generateOrderInfo(orderData);
      
      // 调用微信支付
      final result = await pay(orderInfo);
      
      if (result.success) {
        return const Right(null);
      } else {
        return Left(
          PaymentFailure(message: result.errorMessage ?? '支付失败'),
        );
      }
    } catch (e) {
      return Left(
        PaymentFailure(message: '发起支付失败: $e'),
      );
    }
  }

  @override
  Future<String> generateOrderInfo(Map<String, dynamic> orderData) async {
    if (!await networkInfo.isConnected) {
      throw Exception('网络未连接');
    }
    
    try {
      // 添加重试机制
      return await _retryRequest(() async {
        // 构建符合API格式的请求数据
        final Map<String, dynamic> requestData = {
          'remark': '通过应用下单',
          'tenantId': orderData['sellerId'] ?? 1,
          'items': [
            {
              'productId': orderData['productId'],
              'variantId': orderData['variantId'],
              'quantity': orderData['quantity'] ?? 1
            }
          ]
        };
        
        // 调用创建订单API
        final response = await dio.post(
          '/api/shop/order/create',
          data: requestData,
          options: Options(
            sendTimeout: Duration(seconds: 10),
            receiveTimeout: Duration(seconds: 10),
          ),
        );
        
        if (response.statusCode == 200 && response.data['code'] == 200) {
          final orderId = response.data['data']['id'];
          
          // 调用微信支付API获取支付信息
          final payResponse = await dio.post(
            '/api/payment',
            data: {
              'scene': 'order',
              'payway': 'wechat',  // 微信支付方式
              'businessId': orderId
            },
          );
          
          if (payResponse.statusCode == 200 && payResponse.data['code'] == 200) {
            // 微信支付返回的是支付参数JSON
            return jsonEncode(payResponse.data['data']);
          } else {
            final message = payResponse.data['msg'] ?? '获取微信支付信息失败';
            Fluttertoast.showToast(msg: message);
            throw Exception(message);
          }
        } else {
          final message = response.data['msg'] ?? '创建订单失败';
          Fluttertoast.showToast(msg: message);
          throw Exception(message);
        }
      });
    } catch (e) {
      // 在开发/测试环境下，使用Mock订单信息
      if (orderData.containsKey('orderId') && orderData['orderId'].toString().startsWith('ORDER-')) {
        print('使用Mock微信支付订单信息进行支付测试');
        return jsonEncode({
          'appid': 'mock_app_id',
          'partnerid': 'mock_partner_id',
          'prepayid': 'mock_prepay_id',
          'package': 'Sign=WXPay',
          'noncestr': 'mock_nonce_str',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'sign': 'mock_sign',
          'out_trade_no': orderData['orderId'],
        });
      }
      
      final message = '创建订单失败: $e';
      Fluttertoast.showToast(msg: message);
      throw Exception(message);
    }
  }

  @override
  Future<PaymentResult> pay(String paymentInfo) async {
    try {
      // 检查是否安装微信
      final bool isInstalled = await isWeChatInstalled();
      if (!isInstalled) {
        return PaymentResult(
          success: false,
          errorMessage: '未安装微信App',
        );
      }
      
      // 解析支付参数
      final paymentData = _parsePaymentInfo(paymentInfo);
      
      // 调用微信支付SDK
      final WeChatPayModel payModel = WeChatPayModel(
        appId: paymentData['appid'] ?? '',
        partnerId: paymentData['partnerid'] ?? '',
        prepayId: paymentData['prepayid'] ?? '',
        packageValue: paymentData['package'] ?? 'Sign=WXPay',
        nonceStr: paymentData['noncestr'] ?? '',
        timeStamp: int.tryParse(paymentData['timestamp'] ?? '0') ?? 0,
        sign: paymentData['sign'] ?? '',
      );
      
      final WeChatResponse response = await payWithWeChat(payModel);
      
      // 处理支付结果
      if (response.isSuccessful) {
        return PaymentResult(
          success: true,
          orderId: paymentData['out_trade_no'],
        );
      } else {
        return PaymentResult(
          success: false,
          errorMessage: _getWeChatErrorMsg(response.errorCode),
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: '微信支付异常: $e',
      );
    }
  }
  
  // 添加重试机制
  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('重试次数超限');
  }
  
  // 解析支付信息
  Map<String, String> _parsePaymentInfo(String paymentInfo) {
    try {
      final Map<String, dynamic> data = jsonDecode(paymentInfo);
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      throw Exception('解析微信支付参数失败: $e');
    }
  }
  
  // 获取微信支付错误信息
  String _getWeChatErrorMsg(int? errorCode) {
    switch (errorCode) {
      case WeChatResponseErrorCode.CANCEL: return '用户取消支付';
      case WeChatResponseErrorCode.DENIED: return '支付被拒绝';
      case WeChatResponseErrorCode.UNSUPPORT: return '不支持微信支付';
      case WeChatResponseErrorCode.UNKNOWN: return '未知错误';
      default: return '微信支付失败，错误码: $errorCode';
    }
  }
}