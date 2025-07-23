part of 'seller_order_detail_bloc.dart';

abstract class SellerOrderDetailEvent extends Equatable {
  const SellerOrderDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request loading the details of a specific order.
class LoadSellerOrderDetail extends SellerOrderDetailEvent {
  final int orderId;
  const LoadSellerOrderDetail({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// TODO: Add events for seller actions later (e.g., ConfirmAcceptance, Reject, Deliver)

// --- Seller Action Events ---

/// Event to confirm acceptance of the order.
class SellerConfirmAcceptanceRequested extends SellerOrderDetailEvent {
  final int orderId;
  const SellerConfirmAcceptanceRequested({required this.orderId});
  @override List<Object?> get props => [orderId];
}

/// Event to reject the order (add a refusal demand).
class SellerRejectRequested extends SellerOrderDetailEvent {
  final AddOrderDemandParams params;
  // TODO: Add reason parameters later if needed from UI
  const SellerRejectRequested({required this.params});
   @override List<Object?> get props => [params];
}

/// Event to mark the order as delivered.
class SellerDeliverRequested extends SellerOrderDetailEvent {
  final int orderId;
  final DeliverOrderParams params;

  const SellerDeliverRequested({required this.orderId, required this.params});
   @override List<Object?> get props => [orderId, params];
}

// 移除邀请评价事件
// /// Event to invite the buyer for evaluation.
// class SellerInviteEvaluationRequested extends SellerOrderDetailEvent {
//   final int orderId;
//   const SellerInviteEvaluationRequested({required this.orderId});
//    @override List<Object?> get props => [orderId];
// }

/// Event to delete the seller's record of the order.
class SellerDeleteRecordRequested extends SellerOrderDetailEvent {
  final int orderId;
  const SellerDeleteRecordRequested({required this.orderId});
   @override List<Object?> get props => [orderId];
}




