import 'package:dio/dio.dart';
import '../../domain/entities/exchange_rate.dart';

/// 汇率远程数据源接口
abstract class IExchangeRateRemoteDataSource {
  Future<ExchangeRate> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  });
  
  Future<List<ExchangeRate>> getMultipleExchangeRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  });
  
  Future<List<String>> getSupportedCurrencies();
}

/// 汇率远程数据源实现 - 使用 Fawaz Ahmed's Currency API
class ExchangeRateRemoteDataSource implements IExchangeRateRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';
  
  ExchangeRateRemoteDataSource(this._dio);
  
  @override
  Future<ExchangeRate> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/currencies/${baseCurrency.toLowerCase()}.json',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data[baseCurrency.toLowerCase()] as Map<String, dynamic>;
        final rate = rates[targetCurrency.toLowerCase()] as double?;
        
        if (rate == null) {
          throw Exception('Exchange rate not found for ${baseCurrency.toUpperCase()} to ${targetCurrency.toUpperCase()}');
        }
        
        return ExchangeRate(
          baseCurrency: baseCurrency.toUpperCase(),
          targetCurrency: targetCurrency.toUpperCase(),
          rate: rate,
          updatedAt: DateTime.now(),
          source: 'fawaz-currency-api',
        );
      } else {
        throw Exception('Failed to fetch exchange rate: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<ExchangeRate>> getMultipleExchangeRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/currencies/${baseCurrency.toLowerCase()}.json',
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),  
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data[baseCurrency.toLowerCase()] as Map<String, dynamic>;
        
        final List<ExchangeRate> exchangeRates = [];
        final now = DateTime.now();
        
        for (final targetCurrency in targetCurrencies) {
          final rate = rates[targetCurrency.toLowerCase()] as double?;
          if (rate != null) {
            exchangeRates.add(ExchangeRate(
              baseCurrency: baseCurrency.toUpperCase(),
              targetCurrency: targetCurrency.toUpperCase(),
              rate: rate,
              updatedAt: now,
              source: 'fawaz-currency-api',
            ));
          }
        }
        
        return exchangeRates;
      } else {
        throw Exception('Failed to fetch exchange rates: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
  
  @override
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/currencies.json',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data.keys.map((key) => key.toString().toUpperCase()).toList();
      } else {
        throw Exception('Failed to fetch supported currencies: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}