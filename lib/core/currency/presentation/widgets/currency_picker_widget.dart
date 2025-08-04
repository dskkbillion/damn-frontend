import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/currency.dart';
import '../cubit/currency_cubit.dart';

/// 货币选择器组件
class CurrencyPickerWidget extends StatelessWidget {
  /// 是否显示为下拉菜单样式
  final bool isDropdown;
  
  /// 是否显示货币符号
  final bool showSymbol;
  
  /// 是否显示货币名称
  final bool showName;
  
  /// 自定义样式
  final TextStyle? textStyle;
  
  /// 图标颜色
  final Color? iconColor;
  
  /// 选择回调
  final Function(Currency)? onCurrencyChanged;

  const CurrencyPickerWidget({
    super.key,
    this.isDropdown = true,
    this.showSymbol = true,
    this.showName = false,
    this.textStyle,
    this.iconColor,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        final currentCurrency = state.maybeWhen(
          loaded: (selectedCurrency, _) => selectedCurrency,
          orElse: () => Currency.cny,
        );
        
        if (isDropdown) {
          return _buildDropdown(context, currentCurrency);
        } else {
          return _buildButton(context, currentCurrency);
        }
      },
    );
  }
  
  Widget _buildDropdown(BuildContext context, Currency currentCurrency) {
    return DropdownButton<Currency>(
      value: currentCurrency,
      underline: Container(),
      icon: Icon(Icons.arrow_drop_down, color: iconColor),
      items: Currency.supportedCurrencies.map((currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: _buildCurrencyItem(currency),
        );
      }).toList(),
      onChanged: (Currency? newCurrency) {
        if (newCurrency != null) {
          context.read<CurrencyCubit>().selectCurrency(newCurrency);
          onCurrencyChanged?.call(newCurrency);
        }
      },
    );
  }
  
  Widget _buildButton(BuildContext context, Currency currentCurrency) {
    return InkWell(
      onTap: () => _showCurrencyPicker(context, currentCurrency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyItem(currentCurrency),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: iconColor),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrencyItem(Currency currency) {
    final List<Widget> children = [];
    
    if (showSymbol) {
      children.add(Text(
        currency.symbol,
        style: textStyle?.copyWith(fontWeight: FontWeight.bold),
      ));
    }
    
    if (showName) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 4));
      }
      children.add(Text(
        currency.code,
        style: textStyle,
      ));
    } else if (!showSymbol) {
      children.add(Text(
        currency.code,
        style: textStyle,
      ));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
  
  void _showCurrencyPicker(BuildContext context, Currency currentCurrency) {
    showModalBottomSheet<Currency>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...Currency.supportedCurrencies.map((currency) {
                return ListTile(
                  leading: Text(
                    currency.symbol,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(currency.name),
                  subtitle: Text(currency.code),
                  trailing: currentCurrency.code == currency.code
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<CurrencyCubit>().selectCurrency(currency);
                    onCurrencyChanged?.call(currency);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}