import 'package:injectable/injectable.dart';

import '../../../core/api/api_client.dart';
import '../config/alipay_config.dart';
import '../config/wechat_config.dart';
import 'i_payment_service.dart';
import 'alipay_payment_service.dart';
import 'wechat_payment_service.dart';

/// 支付服务工厂
/// 根据配置和支付方式动态创建对应的支付服务实例
@Injectable()
class PaymentServiceFactory {
  final ApiClient _apiClient;
  
  // 缓存服务实例
  AlipayPaymentService? _alipayService;
  WechatPaymentService? _wechatService;

  PaymentServiceFactory(this._apiClient);

  /// 获取支付宝支付服务
  Future<IPaymentService> getAlipayService() async {
    _alipayService ??= AlipayPaymentService(_apiClient);
    await _alipayService!.initialize();
    return _alipayService!;
  }

  /// 获取微信支付服务
  Future<IPaymentService> getWechatService() async {
    _wechatService ??= WechatPaymentService(_apiClient);
    await _wechatService!.initialize();
    return _wechatService!;
  }

  /// 根据支付方式获取对应的服务
  Future<IPaymentService> getPaymentService(String paymentMethod) async {
    switch (paymentMethod.toLowerCase()) {
      case 'alipay':
        return await getAlipayService();
      case 'wechat':
        return await getWechatService();
      default:
        throw UnsupportedError('不支持的支付方式: $paymentMethod');
    }
  }

  /// 获取所有可用的支付服务
  Future<List<IPaymentService>> getAvailableServices() async {
    final services = <IPaymentService>[];
    
    try {
      final alipayService = await getAlipayService();
      if (alipayService.isAvailable) {
        services.add(alipayService);
      }
    } catch (e) {
      print('[PaymentServiceFactory] Failed to load Alipay service: $e');
    }
    
    try {
      final wechatService = await getWechatService();
      if (wechatService.isAvailable) {
        services.add(wechatService);
      }
    } catch (e) {
      print('[PaymentServiceFactory] Failed to load Wechat service: $e');
    }
    
    return services;
  }

  /// 检查支付方式是否可用
  Future<bool> isPaymentMethodAvailable(String paymentMethod) async {
    try {
      final service = await getPaymentService(paymentMethod);
      return service.isAvailable;
    } catch (e) {
      print('[PaymentServiceFactory] Payment method $paymentMethod not available: $e');
      return false;
    }
  }

  /// 获取支付方式配置信息
  Future<Map<String, dynamic>> getPaymentMethodInfo(String paymentMethod) async {
    switch (paymentMethod.toLowerCase()) {
      case 'alipay':
        try {
          final config = await AlipayConfig.getInstance();
          return {
            'method': 'alipay',
            'name': config.displayName,
            'icon': config.displayIcon,
            'available': (await getAlipayService()).isAvailable,
            'mock': config.mockPayment,
          };
        } catch (e) {
          return {
            'method': 'alipay',
            'name': '支付宝',
            'icon': 'alipay',
            'available': false,
            'error': e.toString(),
          };
        }
      case 'wechat':
        try {
          final config = await WechatConfig.loadFromAssets();
          return {
            'method': 'wechat',
            'name': config.displayName,
            'icon': config.displayIcon,
            'available': (await getWechatService()).isAvailable,
            'mock': config.mockPayment,
          };
        } catch (e) {
          return {
            'method': 'wechat',
            'name': '微信支付',
            'icon': 'wechat',
            'available': false,
            'error': e.toString(),
          };
        }
      default:
        return {
          'method': paymentMethod,
          'name': paymentMethod,
          'icon': 'unknown',
          'available': false,
          'error': 'Unsupported payment method',
        };
    }
  }

  /// 释放资源
  void dispose() {
    // AlipayPaymentService 没有dispose方法
    _wechatService?.dispose();
    _alipayService = null;
    _wechatService = null;
  }
} 