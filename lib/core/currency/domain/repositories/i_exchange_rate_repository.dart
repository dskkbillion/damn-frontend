import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exchange_rate.dart';

/// 汇率数据仓库接口
abstract class IExchangeRateRepository {
  /// 获取指定货币对的汇率
  Future<Either<Failure, ExchangeRate>> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  });
  
  /// 获取多个货币对的汇率
  Future<Either<Failure, List<ExchangeRate>>> getMultipleExchangeRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  });
  
  /// 获取缓存的汇率
  Future<Either<Failure, ExchangeRate?>> getCachedExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  });
  
  /// 缓存汇率
  Future<Either<Failure, void>> cacheExchangeRate(ExchangeRate exchangeRate);
  
  /// 清除过期的缓存汇率
  Future<Either<Failure, void>> clearExpiredRates();
  
  /// 获取支持的货币列表
  Future<Either<Failure, List<String>>> getSupportedCurrencies();
}