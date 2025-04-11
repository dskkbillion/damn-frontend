import 'package:bloc/bloc.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart'; // Import Failure
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_list_use_case.dart';
import 'package:equatable/equatable.dart' hide Order; // Import dartz (hide Order) and Equatable
import 'package:injectable/injectable.dart' hide Order; // Import & hide Order
import 'package:dartz/dartz.dart' hide Order; // Re-add dartz import

part 'order_list_state.dart'; // Declare the state file as a part

/// Manages the state for the Order List page.
@injectable
class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  final GetOrderListUseCase _getOrderListUseCase;

  OrderListBloc({required GetOrderListUseCase getOrderListUseCase})
      : _getOrderListUseCase = getOrderListUseCase,
        super(OrderListInitial()) { // Initial state
    on<LoadOrders>(_onLoadOrders);
    // TODO: Implement handlers for other events (LoadMoreOrders, FilterOrders)
    // on<LoadMoreOrders>(_onLoadMoreOrders);
    // on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(LoadOrders event, Emitter<OrderListState> emit) async {
     emit(OrderListLoading()); // Indicate loading
     // Use the correct Params class defined in the use case file
     final params = GetOrderListParams(page: 1, limit: 10, status: event.status);
     final Either<Failure, List<Order>> result = await _getOrderListUseCase(params);

     result.fold(
       // Ensure Failure types are imported and handled correctly
       (failure) => emit(OrderListError(message: 'Failed to load orders: ${failure.toString()}')),
       (orders) => emit(OrderListLoaded(orders: orders, hasReachedMax: orders.isEmpty)),
     );
  }

   // TODO: Implement handlers for other events (LoadMore, Filter)
}

// --- Events ---
abstract class OrderListEvent extends Equatable {
  const OrderListEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load the initial list of orders, potentially with a filter.
class LoadOrders extends OrderListEvent {
  final OrderStatus? status; // Optional status filter
  const LoadOrders({this.status});
    @override
  List<Object?> get props => [status];
}

// TODO: Define other events like LoadMoreOrders, FilterOrders etc. 