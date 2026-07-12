import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

/// Widget displaying information related to the after-sale process.
class AfterSaleInfoArea extends StatelessWidget {
  final Order order;

  const AfterSaleInfoArea({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final l10n = AppLocalizations.of(context);
    String title;
    String message;
    IconData iconData = Icons.support_agent_outlined;
    Widget? detailsSection; // Section for state-specific details
    List<Widget> actionButtons = []; // List for action buttons

    // --- Determine content based on state ---
    switch (order.state) {
      case OrderStatus.afterSale:
        title = l10n.order_after_sale_processing;
        message = l10n.order_after_sale_processing_msg;
        iconData = Icons.hourglass_bottom_outlined;
        // Placeholder details for refund processing
        detailsSection = _buildRefundDetailsPlaceholder(context, l10n.order_platform_intervention_processing, '${RegionConfig.currencySymbol}50.00');
        // Placeholder actions
        actionButtons = [
          TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_contact_seller)),
          TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_cancel_apply)),
        ];
        break;
      case OrderStatus.applyingForMediation:
        title = l10n.order_after_sale_mediation;
        message = l10n.order_after_sale_mediation_msg;
        iconData = Icons.gavel_outlined;
        // Placeholder details for mediation
        detailsSection = Padding(
           padding: const EdgeInsets.only(top: 16.0),
           child: Text(l10n.order_after_sale_add_evidence_tip, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        );
         actionButtons = [
          TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_contact_platform)),
          TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_add_evidence)),
        ];
        break;
      case OrderStatus.AfterSaleRejection:
        title = l10n.order_after_sale_rejected;
        message = l10n.order_after_sale_rejected_msg;
        iconData = Icons.cancel_outlined;
        // Placeholder for rejection reason
        detailsSection = _buildRejectionDetailsPlaceholder(context, l10n.order_after_sale_reject_reason_detail);
        actionButtons = [
          TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_contact_seller)),
           TextButton(onPressed: () {}, child: Text(l10n.order_after_sale_apply_intervention)),
        ];
        break;
      default:
        title = l10n.order_after_sale_default_title;
        message = l10n.order_after_sale_default_msg;
        iconData = Icons.help_outline;
    }

    return GlassCard(
        padding: const EdgeInsets.all(16.0),
        borderRadius: BorderRadius.circular(12),
        tintOpacity: 0.62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // --- Header --- 
             Row(
               children: [
                 Icon(iconData, size: 20, color: colorScheme.primary),
                 const SizedBox(width: 8),
                 Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
               ],
             ),
             const SizedBox(height: 12),
             Text(message, style: textTheme.bodyMedium),
             
             // --- State Specific Details --- 
             if (detailsSection != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                detailsSection,
             ],

             // --- Action Buttons --- 
             if (actionButtons.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                 Wrap(
                   spacing: 8.0,
                   children: actionButtons,
                 )
             ]
          ],
      ),
    );
  }

 // --- Helper Widgets for Placeholder Details --- 

 Widget _buildRefundDetailsPlaceholder(BuildContext context, String status, String amount) {
   final textTheme = Theme.of(context).textTheme;
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       _buildDetailRow(context, AppLocalizations.of(context).order_after_sale_refund_status, status, valueColor: AppColors.warning),
       const SizedBox(height: 8),
       _buildDetailRow(context, AppLocalizations.of(context).order_after_sale_refund_amount, amount, valueStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
     ],
   );
 }

 Widget _buildRejectionDetailsPlaceholder(BuildContext context, String reason) {
    final textTheme = Theme.of(context).textTheme;
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(AppLocalizations.of(context).order_after_sale_reject_reason, style: textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
       const SizedBox(height: 4),
       Text(reason, style: textTheme.bodyMedium?.copyWith(color: Colors.red[700])), 
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
