import 'package:equatable/equatable.dart';

/// 汇率实体
class ExchangeRate extends Equatable {
  /// 基础货币代码
  final String baseCurrency;
  
  /// 目标货币代码
  final String targetCurrency;
  
  /// 汇率值 (1 基础货币 = rate 目标货币)
  final double rate;
  
  /// 汇率更新时间
  final DateTime updatedAt;
  
  /// 汇率来源
  final String source;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.updatedAt,
    this.source = 'unknown',
  });

  @override
  List<Object?> get props => [
    baseCurrency,
    targetCurrency,
    rate,
    updatedAt,
    source,
  ];
  
  /// 检查汇率是否过期
  bool isExpired({Duration validDuration = const Duration(hours: 1)}) {
    return DateTime.now().difference(updatedAt) > validDuration;
  }
  
  /// 创建逆向汇率 (如 CNY->USD 变为 USD->CNY)
  ExchangeRate reverse() {
    return ExchangeRate(
      baseCurrency: targetCurrency,
      targetCurrency: baseCurrency,
      rate: 1.0 / rate,
      updatedAt: updatedAt,
      source: source,
    );
  }
  
  /// 格式化汇率显示
  String formatRate({int precision = 4}) {
    return rate.toStringAsFixed(precision);
  }
}