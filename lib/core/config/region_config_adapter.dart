import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dskk_flutter_refactor/core/config/unified_region_config.dart';
import 'package:dskk_flutter_refactor/core/currency/domain/entities/currency.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';

/// Adapter to make RegionConfig work with UnifiedRegionConfig
/// This allows gradual migration of existing code
class RegionConfigAdapter {
  /// Initialize the adapter to redirect RegionConfig calls to UnifiedRegionConfig
  static void initializeAdapter() {
    // This would typically use method interception or proxy pattern
    // For now, we'll document the migration path
    AppLogger.d('[RegionConfigAdapter] Initialized - RegionConfig calls will use UnifiedRegionConfig');
  }
  
  /// Create a compatibility layer for RegionConfig
  /// This can be used to patch RegionConfig methods to use UnifiedRegionConfig
  static RegionConfigCompat createCompatLayer() {
    return RegionConfigCompat();
  }
}

/// Compatibility layer that mimics RegionConfig interface but uses UnifiedRegionConfig
class RegionConfigCompat {
  /// Get current region (always returns international for unified)
  RegionType get currentRegion => RegionType.international;
  
  /// Set region (no-op in unified mode)
  void setRegion(RegionType region) {
    AppLogger.d('[RegionConfigCompat] setRegion called with $region - ignored in unified mode');
  }
  
  /// Get default currency (always USD in unified)
  Currency get defaultCurrency => UnifiedRegionConfig.defaultCurrency;
  
  /// Get supported currencies
  List<Currency> get supportedCurrencies => UnifiedRegionConfig.supportedCurrencies;
  
  /// Get supported payment methods in unified mode.
  List<PaymentMethod> get supportedPaymentMethods => UnifiedRegionConfig.supportedPaymentMethods;
  
  /// Check if payment method is supported in unified mode.
  bool isPaymentMethodSupported(PaymentMethod method) => 
    UnifiedRegionConfig.isPaymentMethodSupported(method);
  
  /// Check if currency is supported
  bool isCurrencySupported(Currency currency) => 
    UnifiedRegionConfig.isCurrencySupported(currency);
  
  /// Get currency symbol
  String get currencySymbol => UnifiedRegionConfig.currencySymbol;
  
  /// Format price
  String formatPrice(double amount) => UnifiedRegionConfig.formatPrice(amount);
  
  /// Get features
  Map<String, bool> get features => UnifiedRegionConfig.features;
  
  /// Check if feature is enabled
  bool isFeatureEnabled(String feature) => UnifiedRegionConfig.isFeatureEnabled(feature);
  
  /// Get API base URL
  String get apiBaseUrl => UnifiedRegionConfig.apiBaseUrl;
  
  /// Get model base URL
  String get modelBaseUrl => UnifiedRegionConfig.modelBaseUrl;
}
