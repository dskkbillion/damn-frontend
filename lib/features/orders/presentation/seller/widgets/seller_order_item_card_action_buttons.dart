import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                  title: const Text('确认拒绝'),
                  // TODO: Allow adding a reason in the dialog?
                  content: const Text('您确定要拒绝接受此订单吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: const Text('确认拒绝'), // More specific confirmation
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
          child: const Text('拒绝接单')
        ));
        buttons.add(ElevatedButton(
          onPressed: () async { // Make onPressed async
            // Show confirmation dialog before confirming
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('确认接单'),
                  content: const Text('您确定要接受此订单吗？'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    TextButton(
                      child: const Text('确认'),
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
           child: const Text('确认接单')
          ));
        break;
      case OrderStatus.awaitingDelivery:
        // Seller needs to ship
        buttons.add(OutlinedButton(
          onPressed: () {
            // 跳转到聊天列表页面
            // TODO: 后续实现直接跳转到与买家关于该商品的聊天室
            context.push('/chat');
          }, 
          style: outlineStyle, 
          child: const Text('联系买家')
        ));
        buttons.add(ElevatedButton(
          onPressed: () {
            // 导航到订单详情页进行交付操作
            context.push('/seller/orders/${order.id}');
          }, 
          style: filledStyle, 
          child: const Text('去交付')
          ));
        break;
      case OrderStatus.awaitingConfirmation:
        // Seller has delivered, waiting for buyer confirmation
         buttons.add(OutlinedButton(onPressed: () { print('[SellerButtons] View delivery ${order.id}'); /* TODO: Navigate/Show delivery details */ }, style: outlineStyle, child: const Text('查看交付')));
         buttons.add(ElevatedButton(onPressed: () { print('[SellerButtons] Remind confirmation ${order.id}'); /* TODO: Show reminder confirmation? */ }, style: filledStyle, child: const Text('提醒确认')));
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
                  title: const Text('确认删除'),
                  content: const Text('您确定要删除这条订单记录吗？此操作无法撤销。'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(dialogContext).pop(false), // Return false
                    ),
                    TextButton(
                      child: const Text('确认'),
                      onPressed: () => Navigator.of(dialogContext).pop(true), // Return true
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
          child: const Text('删除记录')
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
                  title: const Text('确认删除'),
                  content: const Text('您确定要删除这条已取消的订单记录吗？此操作无法撤销。'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(dialogContext).pop(false), // Return false
                    ),
                    TextButton(
                      child: const Text('确认'),
                      onPressed: () => Navigator.of(dialogContext).pop(true), // Return true
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
           child: const Text('删除记录')
          ));
        break;
      // TODO: Add cases for other relevant seller statuses (e.g., afterSale, sellerSupplementaryMaterials)
      default:
        // Default or other states might just show details or specific actions
        buttons.add(OutlinedButton(onPressed: () { print('[SellerButtons] View details ${order.id}'); /* TODO: Navigate */ }, style: outlineStyle, child: const Text('查看详情')));
        break;
    }

    return buttons;
  }
} 