part of 'seller_order_detail_bloc.dart';

abstract class SellerOrderDetailState extends Equatable {
  const SellerOrderDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
class SellerOrderDetailInitial extends SellerOrderDetailState {}

/// State indicating the order detail is being loaded.
class SellerOrderDetailLoading extends SellerOrderDetailState {
  final int loadingOrderId; // Track which order ID is being loaded
  const SellerOrderDetailLoading({required this.loadingOrderId});

  @override
  List<Object?> get props => [loadingOrderId];
}

/// State representing successfully loaded order details.
class SellerOrderDetailLoadSuccess extends SellerOrderDetailState {
  final Order order;
  final List<OrderMaterials>? materials;
  final List<OrderDelivery>? deliveries;
  
  const SellerOrderDetailLoadSuccess({
    required this.order,
    this.materials,
    this.deliveries,
  });

  @override
  List<Object?> get props => [order, materials, deliveries];
}

/// State representing an error while loading order details.
class SellerOrderDetailLoadFailure extends SellerOrderDetailState {
  final int failedOrderId;
  final String message;
  const SellerOrderDetailLoadFailure({required this.failedOrderId, required this.message});

   @override
  List<Object?> get props => [failedOrderId, message];
}

// --- Action States ---

/// State indicating a seller action on the order is in progress.
/// Contains the currently loaded order data.
class SellerOrderDetailActionInProgress extends SellerOrderDetailState {
  final Order order;
  // TODO: Add action type if needed for specific UI feedback
  const SellerOrderDetailActionInProgress({required this.order});
  @override List<Object?> get props => [order];
}

/// State indicating a seller action succeeded.
/// Contains the (potentially updated) order data and a success message.
class SellerOrderDetailActionSuccess extends SellerOrderDetailState {
  final Order order; // The order state *after* the action
  final String message;
  // TODO: Add action type that succeeded
  const SellerOrderDetailActionSuccess({required this.order, required this.message});
  @override List<Object?> get props => [order, message];
}

/// State indicating a seller action failed.
/// Contains the order data (before the failed action) and an error message.
class SellerOrderDetailActionFailure extends SellerOrderDetailState {
  final Order order; // The order state *before* the action failed
  final String message;
   // TODO: Add action type that failed
  const SellerOrderDetailActionFailure({required this.order, required this.message});
  @override List<Object?> get props => [order, message];
}







