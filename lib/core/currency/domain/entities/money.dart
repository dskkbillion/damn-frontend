import 'package:equatable/equatable.dart';
import 'currency.dart';

/// 货币金额实体 - 包含金额和货币信息
class Money extends Equatable {
  /// 金额
  final double amount;
  
  /// 货币
  final Currency currency;

  const Money({
    required this.amount,
    required this.currency,
  });

  @override
  List<Object?> get props => [amount, currency];
  
  /// 从人民币金额创建
  factory Money.cny(double amount) {
    return Money(amount: amount, currency: Currency.cny);
  }
  
  /// 从美元金额创建
  factory Money.usd(double amount) {
    return Money(amount: amount, currency: Currency.usd);
  }
  
  /// 货币转换
  Money convertTo(Currency targetCurrency, double exchangeRate) {
    if (currency.code == targetCurrency.code) {
      return this;
    }
    
    return Money(
      amount: amount * exchangeRate,
      currency: targetCurrency,
    );
  }
  
  /// 格式化显示
  String format({bool showSymbol = true, int? decimalDigits}) {
    final digits = decimalDigits ?? currency.decimalDigits;
    final formattedAmount = amount.toStringAsFixed(digits);
    
    if (showSymbol) {
      return '${currency.symbol}$formattedAmount';
    } else {
      return '$formattedAmount ${currency.code}';
    }
  }
  
  /// 简化格式 (自动选择合适的精度)
  String formatCompact({bool showSymbol = true}) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      final formatted = millions.toStringAsFixed(1);
      return showSymbol ? '${currency.symbol}${formatted}M' : '${formatted}M ${currency.code}';
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      final formatted = thousands.toStringAsFixed(1);
      return showSymbol ? '${currency.symbol}${formatted}K' : '${formatted}K ${currency.code}';
    } else {
      return format(showSymbol: showSymbol);
    }
  }
  
  /// 检查是否为零
  bool get isZero => amount == 0.0;
  
  /// 检查是否为正数
  bool get isPositive => amount > 0.0;
  
  /// 检查是否为负数
  bool get isNegative => amount < 0.0;
}