import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/entities/chat_room.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/bloc/seller_order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

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

  Future<void> _openSellerChat(BuildContext context) async {
    final buyerId = order.buyer?.id;
    final sellerId = order.tenant?.id;
    final productId = order.items.isNotEmpty ? order.items.first.productId : null;

    if (buyerId == null || sellerId == null || productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缺少订单关联信息，无法定位聊天室')),
      );
      return;
    }

    final chatRepository = GetIt.instance<IChatRepository>();
    final result = await chatRepository.getChatRooms();

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开聊天室失败: ${failure.message}')),
        );
      },
      (chatRooms) {
        final room = chatRooms.cast<ChatRoom?>().firstWhere(
          (room) =>
              room != null &&
              ((room.participant1.referId == buyerId && room.participant2.referId == sellerId) ||
               (room.participant1.referId == sellerId && room.participant2.referId == buyerId)) &&
              room.productId == productId.toString(),
          orElse: () => null,
        );

        if (room == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('未找到该订单对应聊天室，请在卖家聊天列表中查找“${order.items.first.productName}”'),
            ),
          );
          return;
        }

        context.go('/chat/refactored/${room.id}');
      },
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

    // 判断是否为轻咨询订单
    final isLightConsultation = OrderStatusMapper.isLightConsultationOrder(order);
    
    if (isLightConsultation) {
      // 轻咨询模式：简化按钮
      switch (order.state) {
        case OrderStatus.awaitingPayment:
          // 待付款状态，卖家一般不需要操作
          buttons.add(OutlinedButton(
            onPressed: () {
              context.push('/chat');
            }, 
            style: outlineStyle, 
            child: const Text('联系买家')
          ));
          break;
          
        // 待交付状态组（多个状态映射）
        case OrderStatus.awaitingSubmission:
        case OrderStatus.buyAwaitingSubmission:
        case OrderStatus.awaitingStart:
        case OrderStatus.awaitingDelivery:
        case OrderStatus.awaitingConfirmation:
          buttons.add(ElevatedButton(
            onPressed: () {
              // 导航到订单详情页进行交付操作
              context.push('/seller/orders/${order.id}');
            }, 
            style: filledStyle, 
            child: const Text('交付')
          ));
          buttons.add(OutlinedButton(
            onPressed: () {
              context.push('/chat');
            }, 
            style: outlineStyle, 
            child: const Text('联系买家')
          ));
          break;
          
        case OrderStatus.awaitingEvaluation:
          // 等待评价，可以提醒
          buttons.add(OutlinedButton(
            onPressed: () {
              AppLogger.d('[SellerButtons] Invite evaluation ${order.id}');
            }, 
            style: outlineStyle, 
            child: const Text('邀请评价')
          ));
          break;
          
        case OrderStatus.orderCompleted:
        case OrderStatus.canceled:
          // 已完成或已取消，查看详情
          buttons.add(OutlinedButton(
            onPressed: () {
              context.push('/seller/orders/${order.id}');
            }, 
            style: outlineStyle, 
            child: const Text('查看')
          ));
          break;
          
        case OrderStatus.applyingForMediation:
        case OrderStatus.afterSale:
        case OrderStatus.AfterSaleRejection:
        case OrderStatus.sellerSupplementaryMaterials:
        case OrderStatus.applyForRefuse:
          buttons.add(OutlinedButton(
            onPressed: () {
              context.push('/seller/orders/${order.id}');
            }, 
            style: outlineStyle, 
            child: const Text('查看订单')
          ));
          buttons.add(OutlinedButton(
            onPressed: () => _openSellerChat(context), 
            style: outlineStyle, 
            child: const Text('去聊天室沟通')
          ));
          break;
          
        default:
          buttons.add(OutlinedButton(
            onPressed: () {
              context.push('/seller/orders/${order.id}');
            }, 
            style: outlineStyle, 
            child: const Text('查看')
          ));
          break;
      }
    } else {
      // 原有复杂模式
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
              AppLogger.d('[SellerButtons] Reject order ${order.id}'); 
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
               AppLogger.d('[SellerButtons] Confirm acceptance ${order.id}'); 
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
         buttons.add(OutlinedButton(onPressed: () { AppLogger.d('[SellerButtons] View delivery ${order.id}'); /* TODO: Navigate/Show delivery details */ }, style: outlineStyle, child: const Text('查看交付')));
         buttons.add(ElevatedButton(onPressed: () { AppLogger.d('[SellerButtons] Remind confirmation ${order.id}'); /* TODO: Show reminder confirmation? */ }, style: filledStyle, child: const Text('提醒确认')));
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
              AppLogger.d('[SellerButtons] Delete record ${order.id}'); 
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
               AppLogger.d('[SellerButtons] Delete cancelled record ${order.id}'); 
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
        buttons.add(OutlinedButton(onPressed: () { AppLogger.d('[SellerButtons] View details ${order.id}'); /* TODO: Navigate */ }, style: outlineStyle, child: const Text('查看详情')));
        break;
      }
    }

    return buttons;
  }
} 
