import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/i_exchange_rate_repository.dart';
import '../datasources/exchange_rate_remote_data_source.dart';
import '../datasources/exchange_rate_local_data_source.dart';

/// 汇率仓库实现
class ExchangeRateRepositoryImpl implements IExchangeRateRepository {
  final IExchangeRateRemoteDataSource _remoteDataSource;
  final IExchangeRateLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  
  ExchangeRateRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
  );
  
  @override
  Future<Either<Failure, ExchangeRate>> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      // 首先检查缓存
      final cachedRate = await _localDataSource.getCachedExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      
      // 如果有有效的缓存，直接返回
      if (cachedRate != null && !cachedRate.isExpired()) {
        return Right(cachedRate);
      }
      
      // 检查网络连接
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // 无网络连接时，返回缓存的汇率（即使过期）
        if (cachedRate != null) {
          return Right(cachedRate);
        }
        return const Left(NetworkFailure(message: 'No internet connection and no cached data available'));
      }
      
      // 从远程获取最新汇率
      final exchangeRate = await _remoteDataSource.getExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      
      // 缓存新获取的汇率
      await _localDataSource.cacheExchangeRate(exchangeRate);
      
      return Right(exchangeRate);
    } catch (e) {
      // 网络请求失败时，尝试返回缓存的汇率
      final cachedRate = await _localDataSource.getCachedExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      
      if (cachedRate != null) {
        return Right(cachedRate);
      }
      
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ExchangeRate>>> getMultipleExchangeRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  }) async {
    try {
      // 检查网络连接
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // 无网络连接时，尝试从缓存获取
        final List<ExchangeRate> cachedRates = [];
        for (final targetCurrency in targetCurrencies) {
          final cachedRate = await _localDataSource.getCachedExchangeRate(
            baseCurrency: baseCurrency,
            targetCurrency: targetCurrency,
          );
          if (cachedRate != null) {
            cachedRates.add(cachedRate);
          }
        }
        
        if (cachedRates.isNotEmpty) {
          return Right(cachedRates);
        }
        return const Left(NetworkFailure(message: 'No internet connection and no cached data available'));
      }
      
      // 从远程获取汇率
      final exchangeRates = await _remoteDataSource.getMultipleExchangeRates(
        baseCurrency: baseCurrency,
        targetCurrencies: targetCurrencies,
      );
      
      // 缓存所有获取的汇率
      for (final rate in exchangeRates) {
        await _localDataSource.cacheExchangeRate(rate);
      }
      
      return Right(exchangeRates);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, ExchangeRate?>> getCachedExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final cachedRate = await _localDataSource.getCachedExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      return Right(cachedRate);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> cacheExchangeRate(ExchangeRate exchangeRate) async {
    try {
      await _localDataSource.cacheExchangeRate(exchangeRate);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> clearExpiredRates() async {
    try {
      await _localDataSource.clearExpiredRates();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<String>>> getSupportedCurrencies() async {
    try {
      // 检查网络连接
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // 无网络时返回本地支持的货币列表
        return const Right(['CNY', 'USD', 'EUR', 'GBP', 'JPY']);
      }
      
      final currencies = await _remoteDataSource.getSupportedCurrencies();
      return Right(currencies);
    } catch (e) {
      // 请求失败时返回本地支持的货币列表
      return const Right(['CNY', 'USD', 'EUR', 'GBP', 'JPY']);
    }
  }
}