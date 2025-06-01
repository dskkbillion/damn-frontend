import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../core/network/network_info.dart';
import 'i_payment_service.dart';
import 'alipay_payment_service.dart';
import 'wechat_payment_service.dart';

/// 支付服务工厂
class PaymentServiceFactory {
  static IPaymentService create(String paymentMethod) {
    final dio = GetIt.instance<Dio>();
    final networkInfo = GetIt.instance<NetworkInfo>();
    
    switch (paymentMethod) {
      case 'alipay':
        return AlipayPaymentService(dio, networkInfo);
      case 'wechat':
        return WechatPaymentService(dio, networkInfo);
      default:
        throw UnsupportedError('不支持的支付方式: $paymentMethod');
    }
  }
  
  static List<PaymentMethod> getAvailablePaymentMethods() {
    return [
      PaymentMethod(
        id: 'alipay',
        name: '支付宝',
        icon: 'assets/icons/alipay.png',
        enabled: true,
      ),
      PaymentMethod(
        id: 'wechat',
        name: '微信支付',
        icon: 'assets/icons/wechat.png',
        enabled: true,
      ),
    ];
  }
  
  /// 检查支付方式是否可用
  static Future<bool> isPaymentMethodAvailable(String paymentMethod) async {
    try {
      switch (paymentMethod) {
        case 'alipay':
          // 这里可以添加支付宝可用性检查
          return true;
        case 'wechat':
          // 这里可以添加微信可用性检查
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}

/// 支付方式数据模型
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final bool enabled;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.enabled,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'PaymentMethod{id: $id, name: $name, enabled: $enabled}';
  }
}