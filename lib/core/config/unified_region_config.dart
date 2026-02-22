import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/currency/domain/entities/currency.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';

/// Configuration mode for the application
enum ConfigMode {
  /// Production mode - uses production APIs and no test credentials
  production('production'),
  /// Development mode - uses development APIs and injects test credentials
  development('development');

  const ConfigMode(this.value);
  final String value;
  
  static ConfigMode fromString(String value) {
    return ConfigMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ConfigMode.production,
    );
  }
}

/// API endpoint configuration
class ApiEndpoints {
  final String primary;
  final String? secondary;
  final String modelService;
  
  const ApiEndpoints({
    required this.primary,
    this.secondary,
    required this.modelService,
  });
}

/// Unified region configuration that supports all features
class UnifiedRegionConfig {
  static ConfigMode _mode = ConfigMode.production;
  static late ApiEndpoints _endpoints;
  static bool _isInitialized = false;
  
  /// Initialize the configuration from environment
  static Future<void> initialize({ConfigMode? mode}) async {
    if (_isInitialized) return;
    
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Set mode from parameter or environment
    _mode = mode ?? ConfigMode.fromString(
      dotenv.env['CONFIG_MODE'] ?? 'production'
    );
    
    // Configure endpoints
    _endpoints = ApiEndpoints(
      primary: dotenv.env['BACKEND_BASE_URL'] ?? '',
      secondary: dotenv.env['INTERNATIONAL_API_URL'],
      modelService: dotenv.env['MODEL_BASE_URL'] ?? '',
    );
    
    if (_endpoints.primary.isEmpty) {
      throw Exception('BACKEND_BASE_URL is required in .env file');
    }
    
    if (_endpoints.modelService.isEmpty) {
      throw Exception('MODEL_BASE_URL is required in .env file');
    }
    
    _isInitialized = true;
    
    AppLogger.d('[UnifiedRegionConfig] Initialized');
    AppLogger.d('  Mode: ${_mode.value}');
    AppLogger.d('  Primary API: ${_endpoints.primary}');
    AppLogger.d('  Secondary API: ${_endpoints.secondary ?? "Not configured"}');
    AppLogger.d('  Model Service: ${_endpoints.modelService}');
    AppLogger.d('  Currency: USD (universal)');
    AppLogger.d('  Payment Methods: All enabled');
    AppLogger.d('  Login Methods: All enabled');
  }
  
  /// Get current configuration mode
  static ConfigMode get mode => _mode;
  
  /// Check if in development mode
  static bool get isDevelopment => _mode == ConfigMode.development;
  
  /// Get the primary API endpoint
  static String get apiBaseUrl => _endpoints.primary;
  
  /// Get the secondary API endpoint (for multi-region support)
  static String? get secondaryApiUrl => _endpoints.secondary;
  
  /// Get the model service endpoint
  static String get modelBaseUrl => _endpoints.modelService;
  
  /// Get default currency - Always USD for unified version
  static Currency get defaultCurrency => Currency.usd;
  
  /// Get supported currencies - USD as universal currency
  static List<Currency> get supportedCurrencies => [Currency.usd];
  
  /// Get all available payment methods
  static List<PaymentMethod> get supportedPaymentMethods => [
    PaymentMethod.alipay,
    PaymentMethod.wechat,
    PaymentMethod.stripe,
  ];
  
  /// Check if a payment method is available (all are in unified mode)
  static bool isPaymentMethodSupported(PaymentMethod method) => true;
  
  /// Check if a currency is supported
  static bool isCurrencySupported(Currency currency) {
    return currency == Currency.usd;
  }
  
  /// Get currency symbol
  static String get currencySymbol => Currency.usd.symbol;
  
  /// Format price display with USD
  static String formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(Currency.usd.decimalDigits);
    return '\$${formatted}';
  }
  
  /// Get all features enabled (unified version has everything)
  static Map<String, bool> get features => {
    // Payment features
    'enableWechatPay': true,
    'enableAlipay': true,
    'enableStripe': true,
    
    // Login features
    'enableWechatLogin': true,
    'enableGoogleLogin': true,
    'enableAppleLogin': true,
    
    // Social features
    'enableWechatShare': true,
    
    // Legal/Compliance (can be toggled based on user location if needed)
    'showICPLicense': false,  // Not needed for international/unified version
    
    // Development features
    'enableTestCredentials': isDevelopment,
    'enableDebugLogging': isDevelopment,
  };
  
  /// Check if a feature is enabled
  static bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }
  
  /// Get test credentials for development mode
  static Map<String, String>? get testCredentials {
    if (!isDevelopment) return null;
    
    return {
      'userToken': 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjllYWQ5YWJjLWMxZmEtNGM3ZC04ODllLWJjM2EzNjg4MDQxNSJ9.GgGSkCr4YG_Hf-stG8NuYFRZeebOO24vkhYQ_i8EVZzvIj9VO3VB7PdnpV6VlM7-TBJydQSdKy1mUI9jwsaKRw',
      'userId': '13819198810',
      'commonUserId': '10319',
      'referId': '10319',
    };
  }
  
  /// Get available API endpoints for user selection
  static List<ApiEndpointOption> get availableEndpoints {
    final endpoints = <ApiEndpointOption>[];
    
    endpoints.add(ApiEndpointOption(
      name: 'Primary Server',
      url: _endpoints.primary,
      description: 'Main API server',
    ));
    
    if (_endpoints.secondary != null && _endpoints.secondary!.isNotEmpty) {
      endpoints.add(ApiEndpointOption(
        name: 'International Server',
        url: _endpoints.secondary!,
        description: 'International API server',
      ));
    }
    
    return endpoints;
  }
  
  /// Switch to a different API endpoint at runtime
  static void switchApiEndpoint(String url) {
    if (url == _endpoints.primary || url == _endpoints.secondary) {
      // This would require updating the DI container with new URL
      // Implementation depends on how the HTTP client is configured
      AppLogger.d('[UnifiedRegionConfig] Switching to API: $url');
    }
  }
}

/// API endpoint option for user selection
class ApiEndpointOption {
  final String name;
  final String url;
  final String description;
  
  const ApiEndpointOption({
    required this.name,
    required this.url,
    required this.description,
  });
}