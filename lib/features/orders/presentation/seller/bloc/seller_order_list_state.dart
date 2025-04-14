part of 'seller_order_list_bloc.dart';

// Imports must be in the main library file (seller_order_list_bloc.dart)
// import 'package:equatable/equatable.dart';
// import '../../../domain/entities/order.dart';
// import '../../../domain/entities/order_status.dart';

/// Defines the various states for the [SellerOrderListBloc].

abstract class SellerOrderListState extends Equatable {
  const SellerOrderListState();

  @override
  List<Object?> get props => [];
}

/// Initial state, indicating nothing has been loaded yet.
class SellerOrderListInitial extends SellerOrderListState {}

/// State indicating that the seller's order list is currently being loaded.
/// This could be the initial load or a refresh.
class SellerOrderListLoading extends SellerOrderListState {
  // Keep previous state to show old data while loading more
  final SellerOrderListSuccess? previousState;
  const SellerOrderListLoading({this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// State representing successfully loaded seller orders.
class SellerOrderListSuccess extends SellerOrderListState {
  final List<Order> orders;
  final OrderStatus? currentStatusFilter;
  final bool hasReachedMax;

  const SellerOrderListSuccess({
    required this.orders,
    this.currentStatusFilter,
    this.hasReachedMax = false,
  });

  SellerOrderListSuccess copyWith({
    List<Order>? orders,
    OrderStatus? currentStatusFilter,
    bool? hasReachedMax,
  }) {
    return SellerOrderListSuccess(
      orders: orders ?? this.orders,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [orders, currentStatusFilter, hasReachedMax];

  @override
  String toString() =>
      'SellerOrderListSuccess { orders: ${orders.length}, status: $currentStatusFilter, hasReachedMax: $hasReachedMax }';
}

/// State representing an error that occurred while loading the seller's order list.
class SellerOrderListFailure extends SellerOrderListState {
  final String message;
  // Keep previous state to show old data if loading more failed
  final SellerOrderListSuccess? previousState;

  const SellerOrderListFailure({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

// --- States for specific item actions ---

/// State indicating an action on a specific order item is in progress.
/// Contains the previous successful state to keep displaying the list.
class SellerOrderListActionInProgress extends SellerOrderListState {
  final SellerOrderListSuccess previousState;
  // Optionally add which action is in progress if needed for UI differentiation
  // final SellerListActionType actionType;

  const SellerOrderListActionInProgress({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// State indicating an action on a specific order item failed.
/// Contains the previous successful state and the error message.
class SellerOrderListActionFailure extends SellerOrderListState {
  final SellerOrderListSuccess previousState;
  final String message;
   // Optionally add which action failed
  // final SellerListActionType actionType;

  const SellerOrderListActionFailure({
    required this.previousState,
    required this.message,
  });

  @override
  List<Object?> get props => [previousState, message];
}

// Optional: Define an enum for action types if needed later
// enum SellerListActionType { confirmAcceptance, reject, deliver, deleteRecord, inviteEvaluation }


