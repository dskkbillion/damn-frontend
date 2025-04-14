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
