import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/money.dart';
import '../cubit/currency_cubit.dart';

/// 智能价格显示组件 - 自动根据用户选择的货币显示价格
class PriceDisplayWidget extends StatelessWidget {
  /// 原始价格（人民币）
  final double price;
  
  /// 原始货币（默认为人民币）
  final Currency sourceCurrency;
  
  /// 文本样式
  final TextStyle? style;
  
  /// 是否显示货币符号
  final bool showSymbol;
  
  /// 是否使用紧凑格式 (K, M 等单位)
  final bool useCompactFormat;
  
  /// 是否显示转换指示器
  final bool showConversionIndicator;
  
  /// 加载时的占位符
  final Widget? loadingWidget;
  
  /// 错误时的回退显示
  final Widget? errorWidget;

  const PriceDisplayWidget({
    super.key,
    required this.price,
    this.sourceCurrency = Currency.cny,
    this.style,
    this.showSymbol = true,
    this.useCompactFormat = false,
    this.showConversionIndicator = false,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildPriceText(
            Money(amount: price, currency: sourceCurrency),
            false,
          ),
          loading: () => loadingWidget ?? _buildLoadingWidget(),
          loaded: (selectedCurrency, convertedPrices) => _buildConvertedPrice(
            selectedCurrency,
            convertedPrices,
          ),
          error: (message) => errorWidget ?? _buildErrorWidget(),
        );
      },
    );
  }
  
  Widget _buildConvertedPrice(Currency selectedCurrency, Map<String, Money> convertedPrices) {
    final priceKey = '${sourceCurrency.code}_${selectedCurrency.code}_$price';
    final convertedMoney = convertedPrices[priceKey];
    
    if (convertedMoney != null) {
      return _buildPriceText(convertedMoney, true);
    } else {
      // 如果没有转换结果，显示原始价格
      return _buildPriceText(
        Money(amount: price, currency: sourceCurrency),
        false,
      );
    }
  }
  
  Widget _buildPriceText(Money money, bool isConverted) {
    final priceText = useCompactFormat 
        ? money.formatCompact(showSymbol: showSymbol)
        : money.format(showSymbol: showSymbol);
    
    if (showConversionIndicator && isConverted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(priceText, style: style),
          const SizedBox(width: 4),
          Icon(
            Icons.swap_horiz,
            size: 12,
            color: style?.color?.withOpacity(0.6) ?? Colors.grey,
          ),
        ],
      );
    }
    
    return Text(priceText, style: style);
  }
  
  Widget _buildLoadingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Money(amount: price, currency: sourceCurrency).format(showSymbol: showSymbol),
          style: style?.copyWith(color: style?.color?.withOpacity(0.5)),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: style?.color?.withOpacity(0.6) ?? Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorWidget() {
    return Text(
      Money(amount: price, currency: sourceCurrency).format(showSymbol: showSymbol),
      style: style,
    );
  }
}