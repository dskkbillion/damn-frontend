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
  const SellerOrderDetailLoadSuccess({required this.order});

  @override
  List<Object?> get props => [order];
}

/// State representing an error while loading order details.
class SellerOrderDetailLoadFailure extends SellerOrderDetailState {
  final int failedOrderId;
  final String message;
  const SellerOrderDetailLoadFailure({required this.failedOrderId, required this.message});

   @override
  List<Object?> get props => [failedOrderId, message];
}

// TODO: Add states for actions later (e.g., ActionInProgress, ActionSuccess, ActionFailure)
