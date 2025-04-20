import 'package:flutter/material.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_summary.dart';

/// 购物车摘要组件
class CartSummaryWidget extends StatelessWidget {
  /// 购物车摘要数据
  final CartSummary summary;
  
  /// 应用的优惠券
  final Coupon? appliedCoupon;
  
  /// 结算按钮点击回调
  final VoidCallback onCheckout;
  
  /// 是否可以结算
  final bool isCheckoutEnabled;

  const CartSummaryWidget({
    Key? key,
    required this.summary,
    this.appliedCoupon,
    required this.onCheckout,
    this.isCheckoutEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '订单摘要',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // 商品小计
            _buildSummaryRow(
              label: '商品小计',
              value: '¥${summary.subtotal.toStringAsFixed(2)}',
            ),
            // 优惠券折扣
            if (appliedCoupon != null) ...[
              _buildSummaryRow(
                label: '优惠券折扣',
                value: '-¥${summary.discountAmount.toStringAsFixed(2)}',
                valueColor: Colors.red,
              ),
              _buildSummaryRow(
                label: '优惠券',
                value: appliedCoupon!.code,
                valueStyle: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
            // 运费
            if (summary.shippingEstimate != null)
              _buildSummaryRow(
                label: '运费',
                value: '¥${summary.shippingEstimate!.toStringAsFixed(2)}',
              ),
            // 税费
            if (summary.taxEstimate != null)
              _buildSummaryRow(
                label: '税费',
                value: '¥${summary.taxEstimate!.toStringAsFixed(2)}',
              ),
            const Divider(height: 24.0),
            // 总计
            _buildSummaryRow(
              label: '总计',
              value: '¥${summary.total.toStringAsFixed(2)}',
              labelStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              valueStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16.0),
            // 结算按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCheckoutEnabled ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  '结算 (${summary.totalQuantity}件商品)',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建摘要行
  Widget _buildSummaryRow({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ?? const TextStyle(fontSize: 14.0),
          ),
          Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}