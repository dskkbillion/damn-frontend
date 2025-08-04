import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/currency.dart';
import '../entities/money.dart';
import '../entities/exchange_rate.dart';
import '../repositories/i_exchange_rate_repository.dart';

/// 货币服务 - 处理货币转换和格式化的核心业务逻辑
class CurrencyService {
  final IExchangeRateRepository _exchangeRateRepository;
  
  CurrencyService(this._exchangeRateRepository);
  
  /// 将金额从一种货币转换为另一种货币
  Future<Either<Failure, Money>> convertMoney({
    required Money sourceMoney,
    required Currency targetCurrency,
    bool useCache = true,
  }) async {
    // 如果是相同货币，直接返回
    if (sourceMoney.currency.code == targetCurrency.code) {
      return Right(sourceMoney);
    }
    
    // 优先使用缓存
    if (useCache) {
      final cachedResult = await _exchangeRateRepository.getCachedExchangeRate(
        baseCurrency: sourceMoney.currency.code,
        targetCurrency: targetCurrency.code,
      );
      
      await cachedResult.fold(
        (failure) => null,
        (cachedRate) async {
          if (cachedRate != null && !cachedRate.isExpired()) {
            return Right(_convertWithRate(sourceMoney, targetCurrency, cachedRate));
          }
        },
      );
    }
    
    // 获取最新汇率
    final rateResult = await _exchangeRateRepository.getExchangeRate(
      baseCurrency: sourceMoney.currency.code,
      targetCurrency: targetCurrency.code,
    );
    
    return rateResult.fold(
      (failure) => Left(failure),
      (exchangeRate) async {
        // 缓存新获取的汇率
        await _exchangeRateRepository.cacheExchangeRate(exchangeRate);
        
        return Right(_convertWithRate(sourceMoney, targetCurrency, exchangeRate));
      },
    );
  }
  
  /// 批量转换多个金额到目标货币
  Future<Either<Failure, List<Money>>> convertMultipleMoney({
    required List<Money> sourceMoneyList,
    required Currency targetCurrency,
    bool useCache = true,
  }) async {
    final List<Money> convertedList = [];
    
    for (final money in sourceMoneyList) {
      final result = await convertMoney(
        sourceMoney: money,
        targetCurrency: targetCurrency,
        useCache: useCache,
      );
      
      final convertedMoney = result.fold(
        (failure) => money, // 转换失败时返回原始金额
        (converted) => converted,
      );
      
      convertedList.add(convertedMoney);
    }
    
    return Right(convertedList);
  }
  
  /// 获取货币的显示汇率 (用于UI显示)
  Future<Either<Failure, String>> getDisplayExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    final rateResult = await _exchangeRateRepository.getExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );
    
    return rateResult.fold(
      (failure) => Left(failure),
      (exchangeRate) => Right('1 $baseCurrency = ${exchangeRate.formatRate()} $targetCurrency'),
    );
  }
  
  /// 检查货币是否支持
  bool isCurrencySupported(String currencyCode) {
    return Currency.fromCode(currencyCode) != null;
  }
  
  /// 获取支持的货币列表
  List<Currency> getSupportedCurrencies() {
    return Currency.supportedCurrencies;
  }
  
  /// 使用汇率进行转换的私有方法
  Money _convertWithRate(Money sourceMoney, Currency targetCurrency, ExchangeRate exchangeRate) {
    return sourceMoney.convertTo(targetCurrency, exchangeRate.rate);
  }
  
  /// 格式化价格显示 (包含货币符号)
  String formatPrice(double amount, Currency currency) {
    final money = Money(amount: amount, currency: currency);
    return money.format();
  }
  
  /// 格式化紧凑价格显示 (K, M 等单位)
  String formatPriceCompact(double amount, Currency currency) {
    final money = Money(amount: amount, currency: currency);
    return money.formatCompact();
  }
}