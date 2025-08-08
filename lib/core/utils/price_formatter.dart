import '../config/region_config.dart';

/// 价格格式化工具类
class PriceFormatter {
  /// 格式化价格显示
  /// [amount] 金额
  /// [showCurrency] 是否显示货币符号，默认为true
  static String format(double amount, {bool showCurrency = true}) {
    final formatted = amount.toStringAsFixed(RegionConfig.defaultCurrency.decimalDigits);
    
    if (showCurrency) {
      final symbol = RegionConfig.currencySymbol;
      // 根据区域调整符号位置
      switch (RegionConfig.currentRegion) {
        case RegionType.domestic:
          return '$symbol$formatted';  // ¥100.00
        case RegionType.international:
          return '$symbol$formatted';  // $100.00
      }
    }
    
    return formatted;
  }
  
  /// 格式化价格范围
  static String formatRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return format(minPrice);
    }
    
    final symbol = RegionConfig.currencySymbol;
    final minFormatted = minPrice.toStringAsFixed(RegionConfig.defaultCurrency.decimalDigits);
    final maxFormatted = maxPrice.toStringAsFixed(RegionConfig.defaultCurrency.decimalDigits);
    
    return '$symbol$minFormatted - $symbol$maxFormatted';
  }
  
  /// 获取货币符号
  static String get currencySymbol => RegionConfig.currencySymbol;
  
  /// 获取货币代码
  static String get currencyCode => RegionConfig.defaultCurrency.code;
}