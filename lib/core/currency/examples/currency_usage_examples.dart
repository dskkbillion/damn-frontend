import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Import currency modules
import '../domain/entities/currency.dart';
import '../presentation/cubit/currency_cubit.dart';
import '../presentation/widgets/price_display_widget.dart';
import '../presentation/widgets/currency_picker_widget.dart';

/// 多币种功能使用示例
class CurrencyUsageExamples extends StatelessWidget {
  const CurrencyUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<CurrencyCubit>(),
      child: const CurrencyExamplesContent(),
    );
  }
}

class CurrencyExamplesContent extends StatelessWidget {
  const CurrencyExamplesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('多币种功能示例'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 货币选择器示例
            _buildSection(
              title: '货币选择器',
              child: const CurrencyPickerWidget(
                showSymbol: true,
                showName: true,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 价格显示示例
            _buildSection(
              title: '智能价格显示',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceExample('商品价格: ', 99.99),
                  const SizedBox(height: 8),
                  _buildPriceExample('服务费: ', 299.0),
                  const SizedBox(height: 8),
                  _buildPriceExample('总计: ', 398.99),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 紧凑格式示例
            _buildSection(
              title: '紧凑格式显示',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactPriceExample('基础套餐: ', 1599.0),
                  const SizedBox(height: 8),
                  _buildCompactPriceExample('高级套餐: ', 15999.0),
                  const SizedBox(height: 8),
                  _buildCompactPriceExample('企业套餐: ', 159999.0),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 带转换指示器的示例
            _buildSection(
              title: '带转换指示器',
              child: Column(
                crossAxisors: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('原价: '),
                      PriceDisplayWidget(
                        price: 199.99,
                        showConversionIndicator: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 汇率信息显示
            _buildSection(
              title: '汇率信息',
              child: BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Text('选择货币查看汇率'),
                    loading: () => const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('获取汇率中...'),
                      ],
                    ),
                    loaded: (selectedCurrency, _) => FutureBuilder<String?>(
                      future: context.read<CurrencyCubit>().getExchangeRateText(
                        baseCurrency: 'CNY',
                        targetCurrency: selectedCurrency.code,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const Text('汇率获取中...');
                      },
                    ),
                    error: (message) => Text(
                      '汇率获取失败: $message',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    );
  }
  
  Widget _buildPriceExample(String label, double price) {
    return Row(
      children: [
        Text(label),
        PriceDisplayWidget(
          price: price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompactPriceExample(String label, double price) {
    return Row(
      children: [
        Text(label),
        PriceDisplayWidget(
          price: price,
          useCompactFormat: true,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

/// 如何在现有页面中集成多币种功能的示例
class OrderDetailsWithCurrencyExample extends StatelessWidget {
  const OrderDetailsWithCurrencyExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<CurrencyCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('订单详情 - 多币种'),
          actions: [
            // 在AppBar中添加货币选择器
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: const CurrencyPickerWidget(
                isDropdown: true,
                showSymbol: true,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单商品价格显示
              _buildOrderItem('Flutter 开发服务', 2999.0),
              _buildOrderItem('UI 设计', 1599.0),
              _buildOrderItem('项目管理', 999.0),
              
              const Divider(height: 32),
              
              // 价格汇总
              _buildPriceSummary(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOrderItem(String name, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          PriceDisplayWidget(
            price: price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceSummary() {
    return Column(
      children: [
        _buildSummaryRow('小计', 5597.0),
        _buildSummaryRow('优惠', -100.0),
        _buildSummaryRow('运费', 0.0),
        const Divider(),
        _buildSummaryRow(
          '总计',
          5497.0,
          isTotal: true,
        ),
      ],
    );
  }
  
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          PriceDisplayWidget(
            price: amount.abs(),
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: amount < 0 ? Colors.red : (isTotal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}