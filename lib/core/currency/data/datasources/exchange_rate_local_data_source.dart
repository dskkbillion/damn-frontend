import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/exchange_rate.dart';

/// 汇率本地数据源接口
abstract class IExchangeRateLocalDataSource {
  Future<ExchangeRate?> getCachedExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  });
  
  Future<void> cacheExchangeRate(ExchangeRate exchangeRate);
  
  Future<void> clearExpiredRates();
  
  Future<void> clearAllRates();
}

/// 汇率本地数据源实现 - 使用 SharedPreferences
class ExchangeRateLocalDataSource implements IExchangeRateLocalDataSource {
  final SharedPreferences _prefs;
  static const String _cachePrefix = 'exchange_rate_';
  static const String _cacheKeysKey = 'exchange_rate_keys';
  
  ExchangeRateLocalDataSource(this._prefs);
  
  @override
  Future<ExchangeRate?> getCachedExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final key = _getCacheKey(baseCurrency, targetCurrency);
      final cachedData = _prefs.getString(key);
      
      if (cachedData == null) {
        return null;
      }
      
      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      return _exchangeRateFromJson(data);
    } catch (e) {
      // 如果解析失败，返回null而不是抛出异常
      return null;
    }
  }
  
  @override
  Future<void> cacheExchangeRate(ExchangeRate exchangeRate) async {
    try {
      final key = _getCacheKey(exchangeRate.baseCurrency, exchangeRate.targetCurrency);
      final data = _exchangeRateToJson(exchangeRate);
      
      await _prefs.setString(key, jsonEncode(data));
      
      // 保存缓存键以便后续清理
      await _addCacheKey(key);
    } catch (e) {
      // 缓存失败不应该影响主要功能
      print('Failed to cache exchange rate: $e');
    }
  }
  
  @override
  Future<void> clearExpiredRates() async {
    try {
      final cacheKeys = _getCacheKeys();
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      for (final key in cacheKeys) {
        final cachedData = _prefs.getString(key);
        if (cachedData != null) {
          try {
            final data = jsonDecode(cachedData) as Map<String, dynamic>;
            final updatedAt = DateTime.parse(data['updatedAt'] as String);
            
            // 如果汇率超过1小时，标记为过期
            if (now.difference(updatedAt) > const Duration(hours: 1)) {
              keysToRemove.add(key);
            }
          } catch (e) {
            // 解析失败的缓存也应该被清除
            keysToRemove.add(key);
          }
        }
      }
      
      // 移除过期的缓存
      for (final key in keysToRemove) {
        await _prefs.remove(key);
        await _removeCacheKey(key);
      }
    } catch (e) {
      print('Failed to clear expired rates: $e');
    }
  }
  
  @override
  Future<void> clearAllRates() async {
    try {
      final cacheKeys = _getCacheKeys();
      
      for (final key in cacheKeys) {
        await _prefs.remove(key);
      }
      
      await _prefs.remove(_cacheKeysKey);
    } catch (e) {
      print('Failed to clear all rates: $e');
    }
  }
  
  /// 生成缓存键
  String _getCacheKey(String baseCurrency, String targetCurrency) {
    return '$_cachePrefix${baseCurrency.toUpperCase()}_${targetCurrency.toUpperCase()}';
  }
  
  /// 获取所有缓存键
  List<String> _getCacheKeys() {
    final keysJson = _prefs.getString(_cacheKeysKey);
    if (keysJson == null) return [];
    
    try {
      final keys = jsonDecode(keysJson) as List<dynamic>;
      return keys.cast<String>();
    } catch (e) {
      return [];
    }
  }
  
  /// 添加缓存键
  Future<void> _addCacheKey(String key) async {
    final keys = _getCacheKeys();
    if (!keys.contains(key)) {
      keys.add(key);
      await _prefs.setString(_cacheKeysKey, jsonEncode(keys));
    }
  }
  
  /// 移除缓存键
  Future<void> _removeCacheKey(String key) async {
    final keys = _getCacheKeys();
    keys.remove(key);
    await _prefs.setString(_cacheKeysKey, jsonEncode(keys));
  }
  
  /// 将ExchangeRate转换为JSON
  Map<String, dynamic> _exchangeRateToJson(ExchangeRate exchangeRate) {
    return {
      'baseCurrency': exchangeRate.baseCurrency,
      'targetCurrency': exchangeRate.targetCurrency,
      'rate': exchangeRate.rate,
      'updatedAt': exchangeRate.updatedAt.toIso8601String(),
      'source': exchangeRate.source,
    };
  }
  
  /// 从JSON创建ExchangeRate
  ExchangeRate _exchangeRateFromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      baseCurrency: json['baseCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      source: json['source'] as String? ?? 'unknown',
    );
  }
}