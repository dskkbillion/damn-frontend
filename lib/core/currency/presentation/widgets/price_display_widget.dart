import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/money.dart';
import '../cubit/currency_cubit.dart';

/// 智能价格显示组件 — #348 双显：主 USD + 副本币（按用户选择币种折算）。
///
/// 存储/结算币种恒为 USD（见 #348 产品决策），故 [sourceCurrency] 默认 USD。
/// 汇率未就绪 / 无折算结果时，优雅降级为仅显示 USD 主行（不报错、不留空）。
///
/// 折算结果由 [CurrencyCubit] 按需缓存。商品价格通常不在 cubit 的预加载列表，
/// 故本组件在 loaded 状态主动触发一次 convertPrice 补算（自驱动，幂等）。
class PriceDisplayWidget extends StatefulWidget {
  /// 原始价格（USD，数据库存储币种恒为 USD）
  final double price;

  /// 原始货币（默认 USD）
  final Currency sourceCurrency;

  /// 主行文本样式（USD）
  final TextStyle? style;

  /// 副行文本样式（折算本币）。为空时由 [style] 缩小弱化派生。
  final TextStyle? secondaryStyle;

  /// 是否显示货币符号
  final bool showSymbol;

  /// 是否使用紧凑格式 (K, M 等单位)
  final bool useCompactFormat;

  /// 加载时的占位符
  final Widget? loadingWidget;

  /// 错误时的回退显示（默认仍显示 USD 主行）
  final Widget? errorWidget;

  const PriceDisplayWidget({
    super.key,
    required this.price,
    this.sourceCurrency = Currency.usd,
    this.style,
    this.secondaryStyle,
    this.showSymbol = true,
    this.useCompactFormat = false,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<PriceDisplayWidget> createState() => _PriceDisplayWidgetState();
}

class _PriceDisplayWidgetState extends State<PriceDisplayWidget> {
  Money get _sourceMoney =>
      Money(amount: widget.price, currency: widget.sourceCurrency);

  /// 在 loaded 且副币 != 源币时，确保该价格已被折算（缓存 miss 则触发补算）。
  /// convertPrice 内部带缓存且成功后会 emit，故重复调用幂等、不会无限循环。
  void _ensureConverted(Currency selected) {
    if (selected.code == widget.sourceCurrency.code) return;
    final cubit = context.read<CurrencyCubit>();
    cubit.convertPrice(
      amount: widget.price,
      sourceCurrency: widget.sourceCurrency,
      targetCurrency: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildPrimaryOnly(),
          loading: () => widget.loadingWidget ?? _buildLoadingWidget(),
          loaded: (selectedCurrency, convertedPrices) =>
              _buildDualPrice(selectedCurrency, convertedPrices),
          error: (message) => widget.errorWidget ?? _buildPrimaryOnly(),
        );
      },
    );
  }

  /// 双显：主行 USD 原价，副行折算本币。
  /// 副币 == 源币时退化为仅主行（无意义的 "$2.00 / $2.00" 不展示）。
  /// 缓存未命中时先显主行并触发补算，补算完成 cubit emit 会重建出副行。
  Widget _buildDualPrice(
    Currency selectedCurrency,
    Map<String, Money> convertedPrices,
  ) {
    if (selectedCurrency.code == widget.sourceCurrency.code) {
      return _buildPrimaryOnly();
    }

    final priceKey =
        '${widget.sourceCurrency.code}_${selectedCurrency.code}_${widget.price}';
    final convertedMoney = convertedPrices[priceKey];
    if (convertedMoney == null) {
      // 缓存 miss：下一帧触发补算，避免在 build 中同步改状态
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureConverted(selectedCurrency);
      });
      return _buildPrimaryOnly();
    }

    final primaryText = widget.useCompactFormat
        ? _sourceMoney.formatCompact(showSymbol: widget.showSymbol)
        : _sourceMoney.format(showSymbol: widget.showSymbol);
    final secondaryText = widget.useCompactFormat
        ? convertedMoney.formatCompact(showSymbol: widget.showSymbol)
        : convertedMoney.format(showSymbol: widget.showSymbol);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(primaryText, style: widget.style),
        const SizedBox(height: 2),
        Text(
          '≈ $secondaryText',
          style: widget.secondaryStyle ??
              (widget.style ?? const TextStyle()).copyWith(
                fontSize: ((widget.style?.fontSize ?? 14) * 0.78),
                color: (widget.style?.color ?? Colors.grey)
                    .withValues(alpha: 0.65),
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }

  Widget _buildPrimaryOnly() {
    final text = widget.useCompactFormat
        ? _sourceMoney.formatCompact(showSymbol: widget.showSymbol)
        : _sourceMoney.format(showSymbol: widget.showSymbol);
    return Text(text, style: widget.style);
  }

  Widget _buildLoadingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _sourceMoney.format(showSymbol: widget.showSymbol),
          style: widget.style?.copyWith(
            color: widget.style?.color?.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: widget.style?.color?.withValues(alpha: 0.6) ??
                Colors.grey,
          ),
        ),
      ],
    );
  }
}
