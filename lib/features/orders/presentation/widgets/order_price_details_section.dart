import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// 订单价格详情组件
class OrderPriceDetailsSection extends StatelessWidget {
  final Order order;

  const OrderPriceDetailsSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      tintOpacity: 0.62,
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
                _buildPriceRow(context, AppLocalizations.of(context).order_price_total, RegionConfig.formatPrice(order.priceSummary.totalPrice)),
                if (order.priceSummary.deliveryPrice > 0)
                  _buildPriceRow(context, AppLocalizations.of(context).order_price_shipping, RegionConfig.formatPrice(order.priceSummary.deliveryPrice)),
                if (order.priceSummary.discountPrice > 0)
                  _buildPriceRow(context, AppLocalizations.of(context).order_price_discount, '-${RegionConfig.formatPrice(order.priceSummary.discountPrice)}'),
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
                      RegionConfig.formatPrice(order.priceSummary.payPrice),
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
