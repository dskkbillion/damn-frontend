import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/bloc/seller_order_list_bloc.dart';

/// Displays action buttons specifically for the seller view on an order item card.
class SellerOrderItemCardActionButtons extends StatelessWidget {
  final Order order;

  // TODO: Add callbacks for specific seller actions if needed
  // final VoidCallback? onConfirmAcceptance;
  // final VoidCallback? onReject;
  // final VoidCallback? onDeliver;
  // final VoidCallback? onInviteEvaluation;
  // final VoidCallback? onDeleteRecord;
  // final VoidCallback? onViewLogistics;

  const SellerOrderItemCardActionButtons({
    super.key,
    required this.order,
    // this.onConfirmAcceptance,
    // this.onReject,
    // this.onDeliver,
    // this.onInviteEvaluation,
    // this.onDeleteRecord,
    // this.onViewLogistics,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons(context);
    // Use Wrap for buttons to handle potential overflow if too many
    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 4.0, // Vertical space if buttons wrap
      alignment: WrapAlignment.end, // Align buttons to the right
      children: buttons,
    );
  }

  // Helper method to build the list of buttons based on order state
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Button styles
    final ButtonStyle outlineStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      textStyle: Theme.of(context).textTheme.labelSmall,
      side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
    );
    final ButtonStyle filledStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
       textStyle: Theme.of(context).textTheme.labelSmall,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    final l10n = AppLocalizations.of(context)!;
    // Determine buttons based on state
    switch (order.state) {
      case OrderStatus.awaitingStart:
        // Seller needs to confirm or reject (potentially)
        buttons.add(OutlinedButton(
          onPressed: () async { // Make onPressed async
            // Show confirmation dialog before rejecting
             final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(l10n.order_seller_confirm_reject_title),
                  // TODO: Allow adding a reason in the dialog?
                  content: Text(l10n.order_seller_confirm_reject_content),
                  actions: <Widget>[
                    TextButton(
                      child: Text(l10n.order_dialog_cancel),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: Text(l10n.order_seller_confirm_reject_btn),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ],
                );
              },
            );
             // If confirmed, trigger the event
            if (confirmed == true) {
              print('[SellerButtons] Reject order ${order.id}');
              BlocProvider.of<SellerOrderListBloc>(context).add(RejectOrderRequested(orderId: order.id));
            }
          },
          style: outlineStyle,
          child: Text(l10n.order_seller_reject_order)
        ));
        buttons.add(ElevatedButton(
          onPressed: () async { // Make onPressed async
            // Show confirmation dialog before confirming
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(l10n.order_seller_confirm_accept_title),
                  content: Text(l10n.order_seller_confirm_accept_content),
                  actions: <Widget>[
                    TextButton(
                      child: Text(l10n.order_dialog_cancel),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: Text(l10n.order_seller_confirm_btn),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ],
                );
              },
            );
            // If confirmed, trigger the event
            if (confirmed == true) {
               print('[SellerButtons] Confirm acceptance ${order.id}');
               BlocProvider.of<SellerOrderListBloc>(context).add(ConfirmAcceptanceRequested(orderId: order.id));
            }
           },
           style: filledStyle,
           child: Text(l10n.order_seller_confirm_order)
          ));
        break;
      case OrderStatus.awaitingDelivery:
        // Seller needs to ship
        buttons.add(OutlinedButton(
          onPressed: () {
            context.push('/chat');
          },
          style: outlineStyle,
          child: Text(l10n.order_seller_contact_buyer)
        ));
        buttons.add(ElevatedButton(
          onPressed: () {
            context.push('/seller/orders/${order.id}');
          },
          style: filledStyle,
          child: Text(l10n.order_seller_go_deliver)
          ));
        break;
      case OrderStatus.awaitingConfirmation:
        // Seller has delivered, waiting for buyer confirmation
         buttons.add(OutlinedButton(onPressed: () { print('[SellerButtons] View delivery ${order.id}'); /* TODO: Navigate/Show delivery details */ }, style: outlineStyle, child: Text(l10n.order_seller_view_delivery_content)));
         buttons.add(ElevatedButton(onPressed: () { print('[SellerButtons] Remind confirmation ${order.id}'); /* TODO: Show reminder confirmation? */ }, style: filledStyle, child: Text(l10n.order_seller_remind_buyer)));
        break;
      case OrderStatus.orderCompleted:
        // Order finished, can invite evaluation or delete record
        buttons.add(OutlinedButton(
          onPressed: () async { // Make onPressed async
            // Show confirmation dialog before deleting
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(l10n.order_seller_confirm_delete_title),
                  content: Text(l10n.order_seller_confirm_delete_content),
                  actions: <Widget>[
                    TextButton(
                      child: Text(l10n.order_dialog_cancel),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: Text(l10n.order_seller_confirm_btn),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ],
                );
              },
            );
            // If confirmed, trigger the event
            if (confirmed == true) {
              print('[SellerButtons] Delete record ${order.id}');
              BlocProvider.of<SellerOrderListBloc>(context).add(DeleteSellerRecordRequested(orderId: order.id));
            }
          },
          style: outlineStyle,
          child: Text(l10n.order_seller_delete_record)
          ));
        break;
      case OrderStatus.canceled:
         // Cancelled order, maybe only allow deletion
         buttons.add(OutlinedButton(
          onPressed: () async { // Make onPressed async
            // Show confirmation dialog before deleting
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text(l10n.order_seller_confirm_delete_title),
                  content: Text(l10n.order_seller_confirm_delete_canceled_content),
                  actions: <Widget>[
                    TextButton(
                      child: Text(l10n.order_dialog_cancel),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: Text(l10n.order_seller_confirm_btn),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ],
                );
              },
            );
             // If confirmed, trigger the event
            if (confirmed == true) {
               print('[SellerButtons] Delete cancelled record ${order.id}');
               BlocProvider.of<SellerOrderListBloc>(context).add(DeleteSellerRecordRequested(orderId: order.id));
             }
           },
           style: outlineStyle,
           child: Text(l10n.order_seller_delete_record)
          ));
        break;
      // TODO: Add cases for other relevant seller statuses (e.g., afterSale, sellerSupplementaryMaterials)
      default:
        // Default or other states might just show details or specific actions
        buttons.add(OutlinedButton(onPressed: () { print('[SellerButtons] View details ${order.id}'); /* TODO: Navigate */ }, style: outlineStyle, child: Text(l10n.order_action_view_details)));
        break;
    }

    return buttons;
  }
} 