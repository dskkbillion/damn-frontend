import 'package:equatable/equatable.dart';

/// 货币实体
class Currency extends Equatable {
  /// 货币代码 (如: CNY, USD, EUR)
  final String code;
  
  /// 货币名称 (如: Chinese Yuan, US Dollar)
  final String name;
  
  /// 货币符号 (如: ¥, $, €)
  final String symbol;
  
  /// 是否为基础货币（存储在数据库中的货币）
  final bool isBaseCurrency;
  
  /// 货币精度（小数位数）
  final int decimalDigits;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.isBaseCurrency = false,
    this.decimalDigits = 2,
  });

  @override
  List<Object?> get props => [code, name, symbol, isBaseCurrency, decimalDigits];
  
  /// 常用货币定义
  static const Currency cny = Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    isBaseCurrency: true,
    decimalDigits: 2,
  );
  
  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar', 
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static const Currency eur = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    decimalDigits: 2,
  );
  
  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    decimalDigits: 2,
  );
  
  static const Currency jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    decimalDigits: 0,
  );
  
  /// 支持的货币列表
  static const List<Currency> supportedCurrencies = [
    cny,
    usd,
    eur,
    gbp,
    jpy,
  ];
  
  /// 根据代码获取货币
  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.code == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
}