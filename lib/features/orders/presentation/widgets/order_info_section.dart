import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import '../../domain/entities/order.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

/// 订单信息组件
class OrderInfoSection extends StatelessWidget {
  final Order order;

  const OrderInfoSection({
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
                  Icons.receipt_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).order_info_title,
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
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(context, l10n.order_info_order_number, order.orderSn ?? 'N/A'),
                    _buildInfoRow(context, l10n.order_info_order_time, _formatDateTime(order.createdAt)),
                    if (order.paymentInfo.payTime != null)
                      _buildInfoRow(context, l10n.order_info_pay_time, _formatDateTime(order.paymentInfo.payTime)),
                    if (order.completeTime != null)
                      _buildInfoRow(context, l10n.order_info_complete_time, _formatDateTime(order.completeTime)),
                    if (order.buyerRemark != null && order.buyerRemark!.isNotEmpty)
                      _buildInfoRow(context, l10n.order_info_remark, order.buyerRemark!),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }
}