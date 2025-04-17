part of 'seller_order_list_bloc.dart';

/// Defines the events for the [SellerOrderListBloc].

abstract class SellerOrderListEvent extends Equatable {
  const SellerOrderListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered to load the initial list of seller orders,
/// potentially applying a status filter and keyword.
class LoadSellerOrdersRequested extends SellerOrderListEvent {
  final OrderStatus? statusFilter; // Optional filter
  final String? keyword;
  final bool refresh; // Flag to indicate if this is a pull-to-refresh

  const LoadSellerOrdersRequested({
    this.statusFilter,
    this.keyword,
    this.refresh = false, // Default to not a refresh
  });

  @override
  List<Object?> get props => [statusFilter, keyword, refresh];
}

/// Event triggered when the user scrolls to the bottom of the list
/// to load the next page of orders.
class LoadMoreSellerOrders extends SellerOrderListEvent {}

/// Event triggered when the user selects a different status tab.
class SellerOrderStatusFilterChanged extends SellerOrderListEvent {
  final OrderStatus newStatusFilter;

  const SellerOrderStatusFilterChanged({required this.newStatusFilter});

  @override
  List<Object> get props => [newStatusFilter];
}

// Add other events if needed, e.g., SellerOrderSearchSubmitted

/// Event triggered when the seller confirms acceptance of an order.
class ConfirmAcceptanceRequested extends SellerOrderListEvent {
  final int orderId;
  const ConfirmAcceptanceRequested({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

/// Event triggered when the seller rejects an order (or submits refusal demand).
class RejectOrderRequested extends SellerOrderListEvent {
  final int orderId;
  // TODO: Add reason or other parameters if needed for AddOrderDemandParams
  const RejectOrderRequested({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

/// Event triggered when the seller marks an order as delivered.
class DeliverOrderRequested extends SellerOrderListEvent {
  final int orderId;
  // TODO: Add delivery info (content, files) if needed for DeliverOrderParams
  const DeliverOrderRequested({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

/// Event triggered when the seller invites the buyer to evaluate.
class InviteEvaluationRequested extends SellerOrderListEvent {
  final int orderId;
  const InviteEvaluationRequested({required this.orderId});
  @override
  List<Object> get props => [orderId];
}

/// Event triggered when the seller deletes their record of an order.
class DeleteSellerRecordRequested extends SellerOrderListEvent {
  final int orderId;
  const DeleteSellerRecordRequested({required this.orderId});
  @override
  List<Object> get props => [orderId];
}


