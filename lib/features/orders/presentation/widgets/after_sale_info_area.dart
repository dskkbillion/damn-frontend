import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_dimensions.dart';

/// Widget displaying information related to the after-sale process.
class AfterSaleInfoArea extends StatelessWidget {
  final Order order;

  const AfterSaleInfoArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    String title;
    String message;
    IconData iconData = Icons.support_agent_outlined;
    Widget? detailsSection; // Section for state-specific details
    List<Widget> actionButtons = []; // List for action buttons

    // --- Determine content based on state ---
    switch (order.state) {
      case OrderStatus.afterSale:
        title = '售后处理中';
        message = '您的售后申请正在处理中，卖家将在xx小时内处理，请耐心等待。';
        iconData = Icons.hourglass_bottom_outlined;
        // Placeholder details for refund processing
        detailsSection = _buildRefundDetailsPlaceholder(context, '处理中', '${RegionConfig.currencySymbol}50.00');
        // Placeholder actions
        actionButtons = [
          TextButton(onPressed: () {}, child: const Text('联系卖家')),
          TextButton(onPressed: () {}, child: const Text('取消申请')),
        ];
        break;
      case OrderStatus.applyingForMediation:
        title = '平台介入处理中';
        message = '平台客服已介入处理，将在xx工作日内给出处理结果，请留意通知。';
        iconData = Icons.gavel_outlined;
        // Placeholder details for mediation
        detailsSection = Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spacingLg),
          child: Text('您可以补充凭证或耐心等待平台处理结果。', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        );
        actionButtons = [
          TextButton(onPressed: () {}, child: const Text('联系平台客服')),
          TextButton(onPressed: () {}, child: const Text('补充凭证')),
        ];
        break;
      case OrderStatus.AfterSaleRejection:
        title = '售后申请已驳回';
        message = '抱歉，您的售后申请未通过审核。';
        iconData = Icons.cancel_outlined;
        // Placeholder for rejection reason
        detailsSection = _buildRejectionDetailsPlaceholder(context, '原因：凭证不足或不符合退款条件。');
        actionButtons = [
          TextButton(onPressed: () {}, child: const Text('联系卖家')),
          TextButton(onPressed: () {}, child: const Text('申请平台介入')),
        ];
        break;
      default:
        title = '售后状态';
        message = '当前订单处于售后流程中。';
        iconData = Icons.help_outline;
    }

    return Card(
      // 使用统一Card主题
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              children: [
                Icon(iconData, size: 20, color: colorScheme.primary),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(message, style: textTheme.bodyMedium),

            // --- State Specific Details ---
            if (detailsSection != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              const Divider(),
              const SizedBox(height: AppDimensions.spacingLg),
              detailsSection,
            ],

            // --- Action Buttons ---
            if (actionButtons.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              const Divider(),
              const SizedBox(height: AppDimensions.spacingSm),
              Wrap(
                spacing: AppDimensions.spacingSm,
                children: actionButtons,
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Placeholder Details ---

  Widget _buildRefundDetailsPlaceholder(BuildContext context, String status, String amount) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(context, '退款状态:', status, valueColor: AppColors.warning),
        const SizedBox(height: AppDimensions.spacingSm),
        _buildDetailRow(context, '退款金额:', amount, valueStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRejectionDetailsPlaceholder(BuildContext context, String reason) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('驳回原因:', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(reason, style: textTheme.bodyMedium?.copyWith(color: AppColors.error)),
      ],
    );
  }

  // Helper for consistent detail row display
  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? valueColor, TextStyle? valueStyle}) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: valueStyle ?? textTheme.bodyMedium?.copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}
