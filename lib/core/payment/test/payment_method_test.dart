import 'package:flutter_test/flutter_test.dart';
import '../models/payment_models.dart';

/// 支付方式代码映射测试
/// 验证前端枚举值与后端期望的一致性
void main() {
  group('Payment Method Code Mapping', () {
    test('should have correct payment method codes for backend', () {
      // 验证支付方式代码与后端期望一致
      expect(PaymentMethod.alipay.code, 'alipay');
      expect(PaymentMethod.wechat.code, 'weapp');  // 后端期望微信APP支付为 'weapp'
      expect(PaymentMethod.wallet.code, 'balance'); // 后端期望余额支付为 'balance'
    });

    test('should have correct display names', () {
      // 验证显示名称
      expect(PaymentMethod.alipay.displayName, '支付宝');
      expect(PaymentMethod.wechat.displayName, '微信支付');
      expect(PaymentMethod.wallet.displayName, '余额支付');
    });

    test('should create valid payment request', () {
      // 验证支付请求创建
      final request = PaymentRequest(
        orderId: '123',
        amount: '0.01',
        subject: '测试商品',
        description: '测试描述',
        method: PaymentMethod.wechat,
        scene: PaymentScene.order,
      );

      final json = request.toJson();
      
      // 验证关键字段
      expect(json['orderId'], '123');
      expect(json['method'], 'weapp'); // 确保发送给后端的是 'weapp'
      expect(json['scene'], 'order');
    });
  });
} 