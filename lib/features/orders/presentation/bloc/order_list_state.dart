part of 'order_list_bloc.dart';

/// Defines the various states for the [OrderDetailBloc].

/// Base class for Order List states.
abstract class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any loading has occurred.
class OrderListInitial extends OrderListState {}

/// State indicating that the order list is currently being loaded.
class OrderListLoading extends OrderListState {}

/// State representing successfully loaded orders.
class OrderListLoaded extends OrderListState {
  final List<Order> orders;
  final bool hasReachedMax; // Flag to indicate if more orders can be loaded

  const OrderListLoaded({required this.orders, this.hasReachedMax = false});

  @override
  List<Object?> get props => [orders, hasReachedMax];

  // Optional: Add copyWith method for easier state updates during pagination etc.
   OrderListLoaded copyWith({
    List<Order>? orders,
    bool? hasReachedMax,
  }) {
    return OrderListLoaded(
      orders: orders ?? this.orders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// State representing an error during loading.
class OrderListError extends OrderListState {
  final String message;
  const OrderListError({required this.message});

  @override
  List<Object?> get props => [message];
} 