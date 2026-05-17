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

  // 以下币种与后端 /api/fx/rates 返回集合对齐（#348）。
  // VND/KRW/IDR 为 0 小数位币种。
  static const Currency vnd = Currency(
    code: 'VND',
    name: 'Vietnamese Dong',
    symbol: '₫',
    decimalDigits: 0,
  );

  static const Currency krw = Currency(
    code: 'KRW',
    name: 'South Korean Won',
    symbol: '₩',
    decimalDigits: 0,
  );

  static const Currency thb = Currency(
    code: 'THB',
    name: 'Thai Baht',
    symbol: '฿',
  );

  static const Currency idr = Currency(
    code: 'IDR',
    name: 'Indonesian Rupiah',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static const Currency sgd = Currency(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: r'S$',
  );

  /// 支持的货币列表（与后端 /api/fx/rates 目标币对齐）
  static const List<Currency> supportedCurrencies = [
    cny,
    usd,
    eur,
    gbp,
    jpy,
    vnd,
    krw,
    thb,
    idr,
    sgd,
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