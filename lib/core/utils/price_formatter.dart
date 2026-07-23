/// 价格格式化工具类
class PriceFormatter {
  /// 格式化价格显示
  /// [amount] 金额
  /// [showCurrency] 是否显示货币符号，默认为true
  static String format(double amount, {bool showCurrency = true}) {
    final formatted = amount.round().toString();
    return showCurrency ? '$formatted 积分' : formatted;
  }

  /// 格式化价格范围
  static String formatRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return format(minPrice);
    }

    final minFormatted = minPrice.round();
    final maxFormatted = maxPrice.round();
    return '$minFormatted - $maxFormatted 积分';
  }

  /// 获取货币符号
  static String get currencySymbol => '';

  /// 获取货币代码
  static String get currencyCode => 'credits';
}
