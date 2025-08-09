import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';

void main() {
  setUpAll(() async {
    // Load environment variables for tests
    await dotenv.load(fileName: '.env');
  });

  group('Payment Methods by Region', () {
    test('Domestic region should have Alipay, WeChat, and Wallet', () {
      // Set to domestic region
      RegionConfig.setRegion(RegionType.domestic);
      
      // Get supported payment methods
      final methods = RegionConfig.supportedPaymentMethods;
      
      // Verify the correct payment methods are available
      expect(methods.length, 3);
      expect(methods.contains(PaymentMethod.alipay), true);
      expect(methods.contains(PaymentMethod.wechat), true);
      expect(methods.contains(PaymentMethod.wallet), true);
      expect(methods.contains(PaymentMethod.stripe), false);
      
      // Verify the currency
      expect(RegionConfig.defaultCurrency.code, 'CNY');
      expect(RegionConfig.defaultCurrency.symbol, '¥');
      
      // Verify individual payment method support
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.alipay), true);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.wechat), true);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.wallet), true);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.stripe), false);
    });
    
    test('International region should have Stripe and Wallet only', () {
      // Set to international region
      RegionConfig.setRegion(RegionType.international);
      
      // Get supported payment methods
      final methods = RegionConfig.supportedPaymentMethods;
      
      // Verify the correct payment methods are available
      expect(methods.length, 2);
      expect(methods.contains(PaymentMethod.stripe), true);
      expect(methods.contains(PaymentMethod.wallet), true);
      expect(methods.contains(PaymentMethod.alipay), false);
      expect(methods.contains(PaymentMethod.wechat), false);
      
      // Verify the currency
      expect(RegionConfig.defaultCurrency.code, 'USD');
      expect(RegionConfig.defaultCurrency.symbol, '\$');
      
      // Verify individual payment method support
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.stripe), true);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.wallet), true);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.alipay), false);
      expect(RegionConfig.isPaymentMethodSupported(PaymentMethod.wechat), false);
    });
    
    test('Features should be correctly configured by region', () {
      // Test domestic features
      RegionConfig.setRegion(RegionType.domestic);
      expect(RegionConfig.isFeatureEnabled('enableWechatShare'), true);
      expect(RegionConfig.isFeatureEnabled('enableWechatLogin'), true);
      expect(RegionConfig.isFeatureEnabled('enableAlipay'), true);
      expect(RegionConfig.isFeatureEnabled('showICPLicense'), true);
      expect(RegionConfig.isFeatureEnabled('enableGoogleLogin'), false);
      expect(RegionConfig.isFeatureEnabled('enableAppleLogin'), false);
      
      // Test international features
      RegionConfig.setRegion(RegionType.international);
      expect(RegionConfig.isFeatureEnabled('enableWechatShare'), false);
      expect(RegionConfig.isFeatureEnabled('enableWechatLogin'), false);
      expect(RegionConfig.isFeatureEnabled('enableAlipay'), false);
      expect(RegionConfig.isFeatureEnabled('showICPLicense'), false);
      expect(RegionConfig.isFeatureEnabled('enableGoogleLogin'), true);
      expect(RegionConfig.isFeatureEnabled('enableAppleLogin'), true);
    });
  });
}