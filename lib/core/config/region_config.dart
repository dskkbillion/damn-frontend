import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/currency/domain/entities/currency.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';

/// 区域类型
enum RegionType {
  domestic('domestic', '国服'),
  international('international', '国际服');

  const RegionType(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// 区域配置类
class RegionConfig {
  static RegionType _currentRegion = RegionType.domestic;
  
  /// 设置当前区域
  static void setRegion(RegionType region) {
    _currentRegion = region;
    print('[RegionConfig] Region set to: ${region.displayName}');
  }
  
  /// 获取当前区域
  static RegionType get currentRegion => _currentRegion;
  
  /// 获取默认货币
  static Currency get defaultCurrency {
    switch (_currentRegion) {
      case RegionType.domestic:
        return Currency.cny;  // 人民币
      case RegionType.international:
        return Currency.usd;  // 美元
    }
  }
  
  /// 获取支持的货币列表
  static List<Currency> get supportedCurrencies {
    switch (_currentRegion) {
      case RegionType.domestic:
        return [Currency.cny];  // 国服只支持人民币
      case RegionType.international:
        return [Currency.usd];  // 国际服只支持美元
    }
  }
  
  /// 获取支持的支付方式
  static List<PaymentMethod> get supportedPaymentMethods {
    switch (_currentRegion) {
      case RegionType.domestic:
        return [
          PaymentMethod.alipay,
          PaymentMethod.wechat,
          PaymentMethod.wallet,
        ];  // 国服：支付宝、微信、余额
      case RegionType.international:
        return [
          PaymentMethod.stripe,
          PaymentMethod.wallet,
        ];  // 国际服：Stripe信用卡、余额
    }
  }
  
  /// 检查支付方式是否支持
  static bool isPaymentMethodSupported(PaymentMethod method) {
    return supportedPaymentMethods.contains(method);
  }
  
  /// 检查货币是否支持
  static bool isCurrencySupported(Currency currency) {
    return supportedCurrencies.contains(currency);
  }
  
  /// 获取货币符号
  static String get currencySymbol => defaultCurrency.symbol;
  
  /// 格式化价格显示
  static String formatPrice(double amount) {
    final symbol = currencySymbol;
    final formatted = amount.toStringAsFixed(defaultCurrency.decimalDigits);
    
    // 根据区域调整符号位置
    switch (_currentRegion) {
      case RegionType.domestic:
        return '$symbol$formatted';  // ¥100.00
      case RegionType.international:
        return '$symbol$formatted';  // $100.00
    }
  }
  
  /// 获取区域特定的功能开关
  static Map<String, bool> get features {
    switch (_currentRegion) {
      case RegionType.domestic:
        return {
          'enableWechatShare': true,
          'enableWechatLogin': true,
          'enableAlipay': true,
          'showICPLicense': true,
        };
      case RegionType.international:
        return {
          'enableWechatShare': false,
          'enableWechatLogin': false,
          'enableAlipay': false,
          'showICPLicense': false,
          'enableGoogleLogin': true,
          'enableAppleLogin': true,
        };
    }
  }
  
  /// 获取功能是否启用
  static bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }
  
  /// 获取API基础地址
  static String get apiBaseUrl {
    switch (_currentRegion) {
      case RegionType.domestic:
        return dotenv.env['BACKEND_BASE_URL'] ?? 'https://app.duoshaokankan.com/prod-api';
      case RegionType.international:
        return dotenv.env['INTERNATIONAL_API_URL'] ?? 
               dotenv.env['BACKEND_BASE_URL'] ?? 
               'https://app.duoshaokankan.com/prod-api';
    }
  }
  
  /// 获取模型服务地址
  static String get modelBaseUrl {
    switch (_currentRegion) {
      case RegionType.domestic:
        return dotenv.env['MODEL_BASE_URL'] ?? 'http://47.113.230.11:5107';
      case RegionType.international:
        return dotenv.env['INTERNATIONAL_MODEL_URL'] ?? 
               dotenv.env['MODEL_BASE_URL'] ?? 
               'http://47.113.230.11:5107';
    }
  }
}