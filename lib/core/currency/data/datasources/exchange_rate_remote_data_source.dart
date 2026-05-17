import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
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

/// 汇率远程数据源实现 — 走 DSKK 后端 `/api/fx/rates`（#348）。
///
/// 后端定时从 Fawaz Currency API 拉 USD 基准汇率缓存进 Redis，前端不再直连 CDN。
/// 响应格式（DSKK 标准包裹）：
/// `{ code:200, msg, data:{ base:"USD", rates:{ "cny":7.12, "eur":0.92, ... } } }`
///
/// 存储/结算币种恒为 USD，本数据源仅服务"展示折算"。
class ExchangeRateRemoteDataSource implements IExchangeRateRemoteDataSource {
  final CoreDioClient _client;

  static const String _ratesPath = '/api/fx/rates';
  static const String _source = 'dskk-fx';

  ExchangeRateRemoteDataSource(this._client);

  /// 拉取 base 对全部目标币的汇率 map。失败抛异常（不静默兜底，让上层缓存/离线策略决定回退）。
  Future<Map<String, double>> _fetchRates(
    String baseCurrency, {
    List<String>? targets,
  }) async {
    final query = <String, dynamic>{'base': baseCurrency.toUpperCase()};
    if (targets != null && targets.isNotEmpty) {
      query['targets'] = targets.map((e) => e.toLowerCase()).join(',');
    }

    final response = await _client.get<Map<String, dynamic>>(
      _ratesPath,
      queryParameters: query,
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('汇率接口 HTTP 异常: ${response.statusCode}');
    }
    final body = response.data!;
    if (body['code'] != 200) {
      throw Exception('汇率接口业务失败: ${body['msg'] ?? 'unknown'}');
    }

    final data = body['data'] as Map<String, dynamic>?;
    final rawRates = data?['rates'] as Map<String, dynamic>?;
    if (rawRates == null || rawRates.isEmpty) {
      throw Exception('汇率接口返回空 rates');
    }

    return rawRates.map(
      (k, v) => MapEntry(k.toLowerCase(), (v as num).toDouble()),
    );
  }

  @override
  Future<ExchangeRate> getExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final rates = await _fetchRates(
        baseCurrency,
        targets: [targetCurrency],
      );
      final rate = rates[targetCurrency.toLowerCase()];
      if (rate == null) {
        throw Exception(
            'Exchange rate not found for ${baseCurrency.toUpperCase()} to ${targetCurrency.toUpperCase()}');
      }
      return ExchangeRate(
        baseCurrency: baseCurrency.toUpperCase(),
        targetCurrency: targetCurrency.toUpperCase(),
        rate: rate,
        updatedAt: DateTime.now(),
        source: _source,
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<ExchangeRate>> getMultipleExchangeRates({
    required String baseCurrency,
    required List<String> targetCurrencies,
  }) async {
    try {
      final rates = await _fetchRates(
        baseCurrency,
        targets: targetCurrencies,
      );
      final now = DateTime.now();
      final result = <ExchangeRate>[];
      for (final target in targetCurrencies) {
        final rate = rates[target.toLowerCase()];
        if (rate != null) {
          result.add(ExchangeRate(
            baseCurrency: baseCurrency.toUpperCase(),
            targetCurrency: target.toUpperCase(),
            rate: rate,
            updatedAt: now,
            source: _source,
          ));
        }
      }
      return result;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<String>> getSupportedCurrencies() async {
    // 后端无独立"支持币种"接口；返回当前缓存的全部目标币 + 基准 USD。
    try {
      final rates = await _fetchRates('USD');
      final currencies = rates.keys.map((k) => k.toUpperCase()).toList()
        ..add('USD');
      return currencies;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }
}
