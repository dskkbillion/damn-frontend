import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/price_formatter.dart';
import '../../domain/entities/currency.dart';

/// 积分 MVP 的统一价格组件。
///
/// 保留原构造参数以兼容现有调用方，但不再做货币换算或双币展示。
class PriceDisplayWidget extends StatefulWidget {
  /// 商品积分价格
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
  @override
  Widget build(BuildContext context) {
    return Text(
      PriceFormatter.format(widget.price, showCurrency: widget.showSymbol),
      style: widget.style,
    );
  }
}
