import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 订单价格详情组件
class OrderPriceDetailsSection extends StatelessWidget {
  final Order order;

  const OrderPriceDetailsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_price_title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 内容部分
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow(context, AppLocalizations.of(context).order_price_total, '¥${order.priceSummary.totalPrice.toStringAsFixed(2)}'),
                if (order.priceSummary.deliveryPrice > 0)
                  _buildPriceRow(context, AppLocalizations.of(context).order_price_shipping, '¥${order.priceSummary.deliveryPrice.toStringAsFixed(2)}'),
                if (order.priceSummary.discountPrice > 0)
                  _buildPriceRow(context, AppLocalizations.of(context).order_price_discount, '-¥${order.priceSummary.discountPrice.toStringAsFixed(2)}'),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).order_price_paid,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¥${order.priceSummary.payPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建价格行
  Widget _buildPriceRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}