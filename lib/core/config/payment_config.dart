/// 支付配置管理
class PaymentConfig {
  // 支付宝配置
  static const String alipayAppId = String.fromEnvironment(
    'ALIPAY_APP_ID',
    defaultValue: '',
  );
  static const String alipayPrivateKey = String.fromEnvironment(
    'ALIPAY_PRIVATE_KEY',
    defaultValue: '',
  );
  static const String alipayPublicKey = String.fromEnvironment(
    'ALIPAY_PUBLIC_KEY',
    defaultValue: '',
  );
  
  // 微信支付配置
  static const String wechatAppId = String.fromEnvironment(
    'WECHAT_APP_ID',
    defaultValue: '',
  );
  static const String wechatMerchantId = String.fromEnvironment(
    'WECHAT_MERCHANT_ID',
    defaultValue: '',
  );
  static const String wechatApiKey = String.fromEnvironment(
    'WECHAT_API_KEY',
    defaultValue: '',
  );
  
  // 支付超时配置
  static const Duration paymentTimeout = Duration(minutes: 5);
  static const Duration networkTimeout = Duration(seconds: 30);
  
  // 重试配置
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // 验证配置
  static bool get isAlipayConfigured => 
    alipayAppId.isNotEmpty && alipayPrivateKey.isNotEmpty;
    
  static bool get isWechatConfigured => 
    wechatAppId.isNotEmpty && wechatMerchantId.isNotEmpty;
  
  // 获取可用的支付方式
  static List<String> get availablePaymentMethods {
    final methods = <String>[];
    
    // 支付宝始终可用（使用服务端配置）
    methods.add('alipay');
    
    // 微信支付始终可用（使用服务端配置）
    methods.add('wechat');
    
    return methods;
  }
  
  // 获取默认支付方式
  static String get defaultPaymentMethod => 'alipay';
  
  // 开发环境配置
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
  
  // 测试环境Mock配置
  static const bool useMockPayment = bool.fromEnvironment(
    'USE_MOCK_PAYMENT',
    defaultValue: false,
  );
  
  /// 打印配置信息（仅在调试模式下）
  static void printConfig() {
    if (isDebugMode) {
      print('[PaymentConfig] === 支付配置信息 ===');
      print('[PaymentConfig] 支付宝已配置: $isAlipayConfigured');
      print('[PaymentConfig] 微信支付已配置: $isWechatConfigured');
      print('[PaymentConfig] 可用支付方式: $availablePaymentMethods');
      print('[PaymentConfig] 默认支付方式: $defaultPaymentMethod');
      print('[PaymentConfig] Mock支付: $useMockPayment');
      print('[PaymentConfig] ================');
    }
  }
}