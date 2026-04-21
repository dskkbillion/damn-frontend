import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';

import '../../../domain/entities/order.dart';

/// 卖家订单费用拆分组件
/// 仅当 platformFee != null 时显示（即卖家视角且后端返回了佣金数据）
class SellerOrderFeeBreakdown extends StatelessWidget {
  final Order order;

  const SellerOrderFeeBreakdown({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // 仅卖家视角展示，买家侧 platformFee 为 null
    if (order.platformFee == null) return const SizedBox.shrink();

    final payPrice = order.priceSummary.payPrice;
    final platformFee = order.platformFee!;
    final sellerIncome = order.sellerIncome ?? (payPrice - platformFee);
    final feeRate = order.feeRate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '收入明细',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRow('成交价', '\$${payPrice.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildRow(
            '平台佣金${feeRate != null ? "（${(feeRate * 100).toStringAsFixed(0)}%）" : ""}',
            '-\$${platformFee.toStringAsFixed(2)}',
            valueColor: AppColors.error,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildRow(
            '实收金额',
            '\$${sellerIncome.toStringAsFixed(2)}',
            isBold: true,
            valueColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
