import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/money.dart';
import '../../domain/services/currency_service.dart';
import '../../../config/region_config.dart';

part 'currency_cubit.freezed.dart';
part 'currency_state.dart';

/// 货币管理 Cubit
class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyService _currencyService;
  
  Currency _selectedCurrency = RegionConfig.defaultCurrency;
  final Map<String, Money> _convertedPricesCache = {};
  
  CurrencyCubit(this._currencyService) : super(const CurrencyState.initial());
  
  /// 获取当前选择的货币
  Currency get selectedCurrency => _selectedCurrency;
  
  /// 选择货币
  Future<void> selectCurrency(Currency currency) async {
    if (_selectedCurrency.code == currency.code) return;
    
    _selectedCurrency = currency;
    emit(const CurrencyState.loading());
    
    try {
      // 如果选择的是基础货币（人民币），直接返回loaded状态
      if (currency.isBaseCurrency) {
        emit(CurrencyState.loaded(_selectedCurrency, _convertedPricesCache));
        return;
      }
      
      // 预加载一些常用的汇率转换
      await _preloadCommonConversions();
      
      emit(CurrencyState.loaded(_selectedCurrency, _convertedPricesCache));
    } catch (e) {
      emit(CurrencyState.error('Failed to load currency data: $e'));
    }
  }
  
  /// 转换特定价格
  Future<Money?> convertPrice({
    required double amount,
    required Currency sourceCurrency,
    Currency? targetCurrency,
  }) async {
    final target = targetCurrency ?? _selectedCurrency;
    
    // 生成缓存键
    final cacheKey = '${sourceCurrency.code}_${target.code}_$amount';
    
    // 检查缓存
    if (_convertedPricesCache.containsKey(cacheKey)) {
      return _convertedPricesCache[cacheKey];
    }
    
    try {
      final sourceMoney = Money(amount: amount, currency: sourceCurrency);
      final result = await _currencyService.convertMoney(
        sourceMoney: sourceMoney,
        targetCurrency: target,
      );
      
      return result.fold(
        (failure) => null,
        (convertedMoney) {
          _convertedPricesCache[cacheKey] = convertedMoney;
          // 折算成功后无条件 emit loaded，确保 UI 拿到新缓存。
          // 原 `if (state is CurrencyLoaded)` 会在 state 非 loaded 时丢更新，
          // 导致 widget 自驱动补算成功但界面不刷新（#348 双显不显示根因）。
          emit(CurrencyState.loaded(_selectedCurrency, _convertedPricesCache));
          return convertedMoney;
        },
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 批量转换价格
  Future<void> convertMultiplePrices({
    required List<double> amounts,
    required Currency sourceCurrency,
    Currency? targetCurrency,
  }) async {
    final target = targetCurrency ?? _selectedCurrency;
    
    if (sourceCurrency.code == target.code) return;
    
    try {
      final sourceMoneyList = amounts.map((amount) => 
        Money(amount: amount, currency: sourceCurrency)
      ).toList();
      
      final result = await _currencyService.convertMultipleMoney(
        sourceMoneyList: sourceMoneyList,
        targetCurrency: target,
      );
      
      result.fold(
        (failure) => null,
        (convertedMoneyList) {
          for (int i = 0; i < amounts.length; i++) {
            final cacheKey = '${sourceCurrency.code}_${target.code}_${amounts[i]}';
            _convertedPricesCache[cacheKey] = convertedMoneyList[i];
          }
          // 无条件 emit loaded：与 convertPrice 一致，避免 state 非 loaded 时丢更新
          emit(CurrencyState.loaded(_selectedCurrency, _convertedPricesCache));
        },
      );
    } catch (e) {
      // 静默处理错误，不影响UI
    }
  }
  
  /// 获取汇率显示文本
  Future<String?> getExchangeRateText({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final result = await _currencyService.getDisplayExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      
      return result.fold(
        (failure) => null,
        (rateText) => rateText,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 清除价格转换缓存
  void clearCache() {
    _convertedPricesCache.clear();
    if (state is CurrencyLoaded) {
      emit(CurrencyState.loaded(_selectedCurrency, _convertedPricesCache));
    }
  }
  
  /// 预加载常用转换（提升用户体验）
  Future<void> _preloadCommonConversions() async {
    final commonPrices = [10.0, 50.0, 100.0, 500.0, 1000.0];
    
    // Use the base currency for the current region
    final baseCurrency = RegionConfig.defaultCurrency;
    
    // Only preload if we're converting to a different currency
    if (baseCurrency.code != _selectedCurrency.code) {
      await convertMultiplePrices(
        amounts: commonPrices,
        sourceCurrency: baseCurrency,
        targetCurrency: _selectedCurrency,
      );
    }
  }
  
  /// 获取支持的货币列表
  List<Currency> getSupportedCurrencies() {
    return _currencyService.getSupportedCurrencies();
  }
  
  /// 格式化价格显示
  String formatPrice(double amount, Currency currency) {
    return _currencyService.formatPrice(amount, currency);
  }
  
  /// 格式化紧凑价格显示
  String formatPriceCompact(double amount, Currency currency) {
    return _currencyService.formatPriceCompact(amount, currency);
  }
}